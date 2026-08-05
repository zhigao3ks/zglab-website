#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${ZGLAB_DEPLOY_CONFIG:-${SCRIPT_DIR}/deploy.env}"
USER_CONFIG_FILE="${XDG_CONFIG_HOME:-${HOME}/.config}/zglab/deploy.env"

if [[ -f "${CONFIG_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${CONFIG_FILE}"
  set +a
elif [[ -f "${USER_CONFIG_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${USER_CONFIG_FILE}"
  set +a
fi

DEPLOY_SERVER="${DEPLOY_SERVER:-ubuntu@124.223.48.17}"
WEBSITE_REMOTE_ROOT="${WEBSITE_REMOTE_ROOT:-/var/www/zglab.fun}"
TOOLS_REMOTE_ROOT="${TOOLS_REMOTE_ROOT:-/var/www/tools.zglab.fun}"
REMOTE_STAGE_ROOT="${REMOTE_STAGE_ROOT:-/tmp/zglab-release}"
REMOTE_BACKUP_ROOT="${REMOTE_BACKUP_ROOT:-/var/backups/zglab-release}"

printf '将初始化服务器 %s 的统一发布目录。\n' "${DEPLOY_SERVER}"
printf '该操作只需执行一次，并会要求一次 sudo 认证。\n\n'

ssh "${DEPLOY_SERVER}" bash -s -- \
  "${WEBSITE_REMOTE_ROOT}" \
  "${TOOLS_REMOTE_ROOT}" \
  "${REMOTE_STAGE_ROOT}" \
  "${REMOTE_BACKUP_ROOT}" <<'REMOTE'
set -Eeuo pipefail

website_root="$1"
tools_root="$2"
stage_root="$3"
backup_root="$4"
remote_user="$(id -un)"
remote_group="$(id -gn)"
nginx_group='www-data'

sudo -v

missing_packages=()
command -v rsync >/dev/null 2>&1 || missing_packages+=(rsync)
command -v curl >/dev/null 2>&1 || missing_packages+=(curl)
if ((${#missing_packages[@]} > 0)); then
  sudo apt-get update
  sudo apt-get install -y "${missing_packages[@]}"
fi

getent group "${nginx_group}" >/dev/null 2>&1 || {
  echo "服务器不存在 ${nginx_group} 用户组，停止初始化。" >&2
  exit 1
}

sudo install -d -o "${remote_user}" -g "${nginx_group}" -m 2755 \
  "${website_root}" \
  "${tools_root}"
sudo install -d -o "${remote_user}" -g "${nginx_group}" -m 2750 \
  "${backup_root}"
sudo install -d -o "${remote_user}" -g "${remote_group}" -m 0700 \
  "${stage_root}"

sudo chown -R "${remote_user}:${nginx_group}" "${website_root}" "${tools_root}" "${backup_root}"
sudo find "${website_root}" "${tools_root}" -type d -exec chmod 2755 {} +
sudo find "${website_root}" "${tools_root}" -type f -exec chmod 0644 {} +
sudo find "${backup_root}" -type d -exec chmod 2750 {} +
sudo find "${backup_root}" -type f -exec chmod 0640 {} +
sudo chown -R "${remote_user}:${remote_group}" "${stage_root}"
sudo chmod 0700 "${stage_root}"

sudo nginx -t

printf '\n初始化完成。\n'
printf '部署用户：%s\n' "${remote_user}"
printf '主站目录：%s\n' "${website_root}"
printf '工具站目录：%s\n' "${tools_root}"
printf '统一备份目录：%s\n' "${backup_root}"
printf '临时上传目录：%s\n' "${stage_root}"
REMOTE
