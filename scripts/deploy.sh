#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${SOURCE_DIR:-${PROJECT_ROOT}/dist}"
DEPLOY_DIR="${DEPLOY_DIR:-/var/www/zglab.fun}"
BACKUP_ROOT="${BACKUP_ROOT:-/var/backups/zglab.fun}"
DEPLOY_USE_SUDO="${DEPLOY_USE_SUDO:-1}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"

on_error() {
  printf '部署失败：请检查上方错误信息。现有备份不会被删除。\n' >&2
}
trap on_error ERR

if [[ ! -d "${SOURCE_DIR}" ]]; then
  printf '部署失败：未找到构建目录 %s，请先运行 npm run build。\n' "${SOURCE_DIR}" >&2
  exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
  printf '部署失败：系统未安装 rsync。\n' >&2
  exit 1
fi

SUDO=()
if [[ "$(id -u)" -ne 0 && "${DEPLOY_USE_SUDO}" != "0" ]]; then
  SUDO=(sudo)
fi

"${SUDO[@]}" mkdir -p "${DEPLOY_DIR}" "${BACKUP_ROOT}"

if "${SUDO[@]}" find "${DEPLOY_DIR}" -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
  "${SUDO[@]}" mkdir -p "${BACKUP_DIR}"
  "${SUDO[@]}" rsync --archive "${DEPLOY_DIR}/" "${BACKUP_DIR}/"
  printf '已备份当前站点到 %s\n' "${BACKUP_DIR}"
else
  printf '部署目录为空，本次无需创建内容备份。\n'
fi

"${SUDO[@]}" rsync --archive --delete "${SOURCE_DIR}/" "${DEPLOY_DIR}/"

printf '部署完成：%s -> %s\n' "${SOURCE_DIR}" "${DEPLOY_DIR}"
printf '历史备份保留在：%s\n' "${BACKUP_ROOT}"
