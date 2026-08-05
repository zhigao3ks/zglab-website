#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WEBSITE_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
PROJECTS_ROOT="${PROJECTS_ROOT:-$(dirname -- "${WEBSITE_DIR}")}"
TOOLS_DIR="${TOOLS_DIR:-${PROJECTS_ROOT}/zglab-tools}"
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
WEBSITE_URL="${WEBSITE_URL:-https://zglab.fun}"
TOOLS_URL="${TOOLS_URL:-https://tools.zglab.fun}"
WEBSITE_REMOTE_ROOT="${WEBSITE_REMOTE_ROOT:-/var/www/zglab.fun}"
TOOLS_REMOTE_ROOT="${TOOLS_REMOTE_ROOT:-/var/www/tools.zglab.fun}"
REMOTE_STAGE_ROOT="${REMOTE_STAGE_ROOT:-/tmp/zglab-release}"
REMOTE_BACKUP_ROOT="${REMOTE_BACKUP_ROOT:-/var/backups/zglab-release}"
BACKUP_KEEP="${BACKUP_KEEP:-10}"
DEPLOY_PULL="${DEPLOY_PULL:-1}"

WEBSITE_HEALTH_BODY='zglab-site-ok'
TOOLS_HEALTH_BODY='zglab-tools-ok'

usage() {
  cat <<'USAGE'
用法：bash ops/deploy-all.sh [--no-pull]

默认流程：
  1. 检查 zglab-website 与 zglab-tools 均处于干净的 main 分支。
  2. 对两个仓库执行 git pull --ff-only。
  3. 完成检查、测试和静态构建。
  4. 复用同一条 SSH 控制连接上传并发布两个站点。
  5. 健康检查失败时同时回滚两个站点。

选项：
  --no-pull  不从远端拉取，直接发布当前本地 main 提交。
  -h, --help 显示帮助。
USAGE
}

while (($# > 0)); do
  case "$1" in
    --no-pull)
      DEPLOY_PULL=0
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      printf '不支持的参数：%s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

fail() {
  printf '发布失败：%s\n' "$*" >&2
  exit 1
}

for command_name in git npm rsync ssh curl; do
  command -v "${command_name}" >/dev/null 2>&1 || fail "缺少本地命令 ${command_name}"
done

[[ -d "${WEBSITE_DIR}/.git" ]] || fail "主站仓库不存在：${WEBSITE_DIR}"
[[ -d "${TOOLS_DIR}/.git" ]] || fail "工具站仓库不存在：${TOOLS_DIR}"
[[ "${BACKUP_KEEP}" =~ ^[1-9][0-9]*$ ]] || fail 'BACKUP_KEEP 必须是大于 0 的整数'
[[ "${DEPLOY_PULL}" == '0' || "${DEPLOY_PULL}" == '1' ]] || fail 'DEPLOY_PULL 只能是 0 或 1'

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

check_repository() {
  local name="$1"
  local directory="$2"
  local branch

  branch="$(git -C "${directory}" branch --show-current)"
  [[ "${branch}" == 'main' ]] || fail "${name} 当前分支为 ${branch:-detached HEAD}，只能从 main 发布"

  if [[ -n "$(git -C "${directory}" status --porcelain)" ]]; then
    git -C "${directory}" status --short >&2
    fail "${name} 存在未提交修改"
  fi
}

update_repository() {
  local name="$1"
  local directory="$2"

  if [[ "${DEPLOY_PULL}" == '1' ]]; then
    printf '\n[%s] 拉取 main 最新提交\n' "${name}"
    git -C "${directory}" fetch origin main
    git -C "${directory}" pull --ff-only origin main
  fi
}

check_repository '主站' "${WEBSITE_DIR}"
check_repository '工具站' "${TOOLS_DIR}"
update_repository '主站' "${WEBSITE_DIR}"
update_repository '工具站' "${TOOLS_DIR}"
check_repository '主站' "${WEBSITE_DIR}"
check_repository '工具站' "${TOOLS_DIR}"

WEBSITE_COMMIT="$(git -C "${WEBSITE_DIR}" rev-parse HEAD)"
TOOLS_COMMIT="$(git -C "${TOOLS_DIR}" rev-parse HEAD)"

printf '\n[1/4] 构建主页与博客\n'
(
  cd "${WEBSITE_DIR}"
  npm ci
  npm run format:check
  npm run check
  npm run build
)

[[ -f "${WEBSITE_DIR}/dist/index.html" ]] || fail '主站构建产物缺少 dist/index.html'
[[ "$(tr -d '\r\n' < "${WEBSITE_DIR}/dist/health.txt")" == "${WEBSITE_HEALTH_BODY}" ]] || \
  fail '主站构建产物缺少有效的 dist/health.txt'

printf '\n[2/4] 构建并测试工具站\n'
(
  cd "${TOOLS_DIR}"
  npm ci
  npm run format:check
  npm run lint
  npm run check
  npm run test
  PUBLIC_SITE_URL="${TOOLS_URL}" npm run build
)

[[ -f "${TOOLS_DIR}/dist/index.html" ]] || fail '工具站构建产物缺少 dist/index.html'
[[ "$(tr -d '\r\n' < "${TOOLS_DIR}/dist/health.txt")" == "${TOOLS_HEALTH_BODY}" ]] || \
  fail '工具站构建产物缺少有效的 dist/health.txt'

RELEASE_ID="$(date -u +'%Y%m%dT%H%M%SZ')-${WEBSITE_COMMIT:0:7}-${TOOLS_COMMIT:0:7}"
REMOTE_RELEASE_DIR="${REMOTE_STAGE_ROOT%/}/${RELEASE_ID}"
CONTROL_DIR="${XDG_RUNTIME_DIR:-/tmp}/zglab-deploy-${UID}"
CONTROL_PATH="${CONTROL_DIR}/%C"
mkdir -p "${CONTROL_DIR}"
chmod 700 "${CONTROL_DIR}"

SSH_OPTIONS=(
  -o ControlMaster=auto
  -o ControlPersist=10m
  -o "ControlPath=${CONTROL_PATH}"
)
RSYNC_SSH="ssh -o ControlMaster=auto -o ControlPersist=10m -o ControlPath=${CONTROL_PATH}"

close_control_connection() {
  ssh "${SSH_OPTIONS[@]}" -O exit "${DEPLOY_SERVER}" >/dev/null 2>&1 || true
}
trap close_control_connection EXIT

printf '\n[3/4] 建立一次 SSH 认证并上传两个站点\n'
ssh "${SSH_OPTIONS[@]}" "${DEPLOY_SERVER}" bash -s -- "${REMOTE_RELEASE_DIR}" <<'REMOTE_PREPARE'
set -Eeuo pipefail
release_dir="$1"
mkdir -p "${release_dir}/website" "${release_dir}/tools"
REMOTE_PREPARE

rsync -az --delete --chmod=D755,F644 -e "${RSYNC_SSH}" \
  "${WEBSITE_DIR}/dist/" "${DEPLOY_SERVER}:${REMOTE_RELEASE_DIR}/website/"
rsync -az --delete --chmod=D755,F644 -e "${RSYNC_SSH}" \
  "${TOOLS_DIR}/dist/" "${DEPLOY_SERVER}:${REMOTE_RELEASE_DIR}/tools/"

printf '\n[4/4] 同步发布、健康检查与失败回滚\n'
ssh "${SSH_OPTIONS[@]}" "${DEPLOY_SERVER}" bash -s -- \
  "${REMOTE_RELEASE_DIR}" \
  "${WEBSITE_REMOTE_ROOT}" \
  "${TOOLS_REMOTE_ROOT}" \
  "${REMOTE_BACKUP_ROOT}" \
  "${RELEASE_ID}" \
  "${BACKUP_KEEP}" \
  "${WEBSITE_URL}" \
  "${TOOLS_URL}" \
  "${WEBSITE_HEALTH_BODY}" \
  "${TOOLS_HEALTH_BODY}" <<'REMOTE_DEPLOY'
set -Eeuo pipefail
umask 022

release_dir="$1"
website_root="$2"
tools_root="$3"
backup_root="$4"
release_id="$5"
backup_keep="$6"
website_url="${7%/}"
tools_url="${8%/}"
website_health_body="$9"
tools_health_body="${10}"
backup_dir="${backup_root%/}/${release_id}"
website_backup="${backup_dir}/website"
tools_backup="${backup_dir}/tools"
website_had_previous=false
tools_had_previous=false
published=false

cleanup() {
  rm -rf -- "${release_dir}"
}

restore_site() {
  local target="$1"
  local backup="$2"
  local had_previous="$3"

  if [[ "${had_previous}" == true ]]; then
    rsync -a --delete --chmod=D755,F644 "${backup}/" "${target}/"
  else
    find "${target}" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
  fi
}

rollback() {
  local status=$?
  if [[ "${published}" == true ]]; then
    echo '健康检查失败，正在同时回滚主页和工具站。' >&2
    restore_site "${website_root}" "${website_backup}" "${website_had_previous}" || true
    restore_site "${tools_root}" "${tools_backup}" "${tools_had_previous}" || true
  fi
  cleanup || true
  exit "${status}"
}
trap rollback ERR

for command_name in rsync curl find sort; do
  command -v "${command_name}" >/dev/null 2>&1 || {
    echo "远程服务器缺少命令：${command_name}" >&2
    exit 1
  }
done

for directory in "${website_root}" "${tools_root}" "${backup_root}"; do
  [[ -d "${directory}" && -w "${directory}" && -x "${directory}" ]] || {
    echo "部署目录不存在或当前用户无写权限：${directory}" >&2
    echo '请先运行 bash ops/bootstrap-server.sh。' >&2
    exit 1
  }
done

[[ -f "${release_dir}/website/index.html" ]] || { echo '远程主站暂存目录缺少 index.html' >&2; exit 1; }
[[ -f "${release_dir}/tools/index.html" ]] || { echo '远程工具站暂存目录缺少 index.html' >&2; exit 1; }
[[ "$(tr -d '\r\n' < "${release_dir}/website/health.txt")" == "${website_health_body}" ]] || {
  echo '远程主站 health.txt 无效' >&2
  exit 1
}
[[ "$(tr -d '\r\n' < "${release_dir}/tools/health.txt")" == "${tools_health_body}" ]] || {
  echo '远程工具站 health.txt 无效' >&2
  exit 1
}

mkdir "${backup_dir}"
mkdir "${website_backup}" "${tools_backup}"

shopt -s nullglob dotglob
website_entries=("${website_root}"/*)
tools_entries=("${tools_root}"/*)
shopt -u nullglob dotglob

if ((${#website_entries[@]} > 0)); then
  website_had_previous=true
  rsync -a "${website_root}/" "${website_backup}/"
fi
if ((${#tools_entries[@]} > 0)); then
  tools_had_previous=true
  rsync -a "${tools_root}/" "${tools_backup}/"
fi

published=true
rsync -a --delete --chmod=D755,F644 "${release_dir}/website/" "${website_root}/"
rsync -a --delete --chmod=D755,F644 "${release_dir}/tools/" "${tools_root}/"

check_health() {
  local url="$1"
  local expected="$2"
  local response_file
  local status
  local body

  response_file="$(mktemp)"
  status="$(curl --silent --show-error --max-time 20 --output "${response_file}" --write-out '%{http_code}' "${url}/health.txt")"
  body="$(tr -d '\r\n' < "${response_file}")"
  rm -f -- "${response_file}"

  [[ "${status}" == '200' ]] || {
    echo "健康检查失败：${url}/health.txt 返回 HTTP ${status}" >&2
    return 1
  }
  [[ "${body}" == "${expected}" ]] || {
    echo "健康检查失败：${url}/health.txt 正文不匹配" >&2
    return 1
  }
}

check_health "${website_url}" "${website_health_body}"
check_health "${tools_url}" "${tools_health_body}"

mapfile -d '' backup_directories < <(
  find "${backup_root}" -mindepth 1 -maxdepth 1 -type d -name '20??????T??????Z-*' -print0 | sort -z -r
)
for ((index = backup_keep; index < ${#backup_directories[@]}; index += 1)); do
  candidate="${backup_directories[$index]}"
  [[ "$(dirname -- "${candidate}")" == "${backup_root%/}" ]] || {
    echo "拒绝清理越界备份目录：${candidate}" >&2
    exit 1
  }
  rm -rf -- "${candidate}"
done

cleanup
trap - ERR
printf '两个站点发布成功。\n'
printf '本次备份：%s\n' "${backup_dir}"
printf '备份保留上限：%s\n' "${backup_keep}"
REMOTE_DEPLOY

printf '\n发布完成\n'
printf '主页：%s (%s)\n' "${WEBSITE_URL}" "${WEBSITE_COMMIT}"
printf '工具：%s (%s)\n' "${TOOLS_URL}" "${TOOLS_COMMIT}"
