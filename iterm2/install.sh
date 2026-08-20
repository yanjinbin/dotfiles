#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PREFS_DOMAIN="com.googlecode.iterm2"
PREFS_FILE="${HOME}/Library/Preferences/${PREFS_DOMAIN}.plist"
BACKUP_FILE="${PREFS_FILE}.bak-$(date +%Y%m%d-%H%M%S)"

if pgrep -x iTerm2 >/dev/null 2>&1; then
  echo "请先退出 iTerm2，再重新运行：$0"
  exit 1
fi

if [[ -f "$PREFS_FILE" ]]; then
  cp -p "$PREFS_FILE" "$BACKUP_FILE"
  echo "已备份现有偏好：$BACKUP_FILE"
fi

defaults import "$PREFS_DOMAIN" "$SCRIPT_DIR/com.googlecode.iterm2.plist"
killall cfprefsd >/dev/null 2>&1 || true

echo "iTerm2 偏好已导入。首次启动前请确认 MesloLGS Nerd Font 已安装。"
