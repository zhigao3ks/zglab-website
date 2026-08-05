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

fail() {
  printf '初始化失败：%s\n' "$*" >&2
  exit 1
}

for command_name in ssh mktemp; do
  command -v "${command_name}" >/dev/null 2>&1 || fail "缺少本地命令 ${command_name}"
done

validate_remote_path() {
  local variable_name="$1"
  local value="$2"
  local required_prefix="$3"

  [[ "${value}" == "${required_prefix}"* ]] || fail "${variable_name} 必须位于 ${required_prefix} 下"
  [[ "${value}" =~ ^/[A-Za-z0-9._/-]+$ ]] || fail "${variable_name} 含不受支持的字符"
  [[ ! "${value}" =~ (^|/)\.{1,2}(/|$) ]] || fail "${variable_name} 含危险路径片段"
  [[ "${value}" != *//* ]] || fail "${variable_name} 含重复斜杠"
  [[ "${value}" != "${required_prefix%/}" && "${value}" != "${required_prefix}" ]] || fail "${variable_name} 不能是根目录"
}

validate_remote_path WEBSITE_REMOTE_ROOT "${WEBSITE_REMOTE_ROOT}" /var/www/
validate_remote_path TOOLS_REMOTE_ROOT "${TOOLS_REMOTE_ROOT}" /var/www/
validate_remote_path REMOTE_STAGE_ROOT "${REMOTE_STAGE_ROOT}" /tmp/
validate_remote_path REMOTE_BACKUP_ROOT "${REMOTE_BACKUP_ROOT}" /var/backups/

printf '将初始化服务器 %s 的统一发布目录。\n' "${DEPLOY_SERVER}"
printf '该操作只需执行一次，并会要求一次 sudo 认证。\n\n'

local_script="$(mktemp)"
remote_script="/tmp/zglab-bootstrap-${USER:-user}-$$.sh"

cleanup() {
  rm -f -- "${local_script}"
  ssh "${DEPLOY_SERVER}" "rm -f -- '${remote_script}'" >/dev/null 2>&1 || true
}
trap cleanup EXIT

cat >"${local_script}" <<'REMOTE'
#!/usr/bin/env bash
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

chmod 600 "${local_script}"

printf '正在上传一次性初始化脚本……\n'
ssh "${DEPLOY_SERVER}" "umask 077; cat > '${remote_script}'" <"${local_script}"

printf '正在执行服务器初始化……\n'
# 初始化脚本已经保存为远程文件，TTY 的标准输入只用于 sudo 密码，
# 避免把脚本文本与密码输入复用在同一个终端流中。
ssh -t "${DEPLOY_SERVER}" \
  "bash '${remote_script}' '${WEBSITE_REMOTE_ROOT}' '${TOOLS_REMOTE_ROOT}' '${REMOTE_STAGE_ROOT}' '${REMOTE_BACKUP_ROOT}'"
