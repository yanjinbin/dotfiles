#!/usr/bin/env bash

# Homebrew backup and restore helper.
# - Dumps current Homebrew taps, brews, casks and App Store apps with a timestamp.
# - Keeps ~/Brewfile as the latest copy for `brew bundle install`.
# - Uses fnm instead of nvm, uv instead of pyenv.

set -u

BREWFILE_BACKUP_DIR="${HOME}/Brewfile.backups"
BREWFILE_LATEST="${HOME}/Brewfile"
LOG_FILE="${HOME}/brew_backup_restore.log"
TIMESTAMP="$(date +'%Y%m%d_%H%M%S')"
BREWFILE_TIMESTAMPED="${BREWFILE_BACKUP_DIR}/Brewfile.${TIMESTAMP}"

touch "$LOG_FILE"

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

append_zshrc_once() {
    local marker="$1"
    local content="$2"

    touch "${HOME}/.zshrc"
    if ! grep -Fq "$marker" "${HOME}/.zshrc"; then
        log "写入 ${marker} 到 ~/.zshrc ..."
        {
            printf '\n%s\n' "$marker"
            printf '%s\n' "$content"
        } >> "${HOME}/.zshrc"
    else
        log "~/.zshrc 已包含 ${marker}，跳过"
    fi
}

install_brew_formula_if_missing() {
    local formula="$1"

    if ! command -v "$formula" >/dev/null 2>&1; then
        log "${formula} 未安装，正在通过 Homebrew 安装..."
        if brew install "$formula" 2>>"$LOG_FILE"; then
            log "${formula} 安装成功"
        else
            log "${formula} 安装失败，请检查 ${LOG_FILE}"
            return 1
        fi
    else
        log "${formula} 已安装，跳过安装"
    fi
}

if ! command -v brew >/dev/null 2>&1; then
    log "Homebrew 未安装，请先安装 Homebrew。"
    exit 1
fi

mkdir -p "$BREWFILE_BACKUP_DIR"

log "正在导出所有已安装的 Homebrew 依赖..."
if brew bundle dump --file="$BREWFILE_TIMESTAMPED" --force 2>>"$LOG_FILE"; then
    cp "$BREWFILE_TIMESTAMPED" "$BREWFILE_LATEST"
    log "已将依赖导出至 ${BREWFILE_TIMESTAMPED}（同步至 ${BREWFILE_LATEST}）"
else
    log "导出失败，请检查 ${LOG_FILE}"
    exit 1
fi

log "已生成的 Brewfile 内容如下："
cat "$BREWFILE_TIMESTAMPED" | tee -a "$LOG_FILE"

log "如需恢复依赖，请运行以下命令："
log "brew bundle install --file=${BREWFILE_LATEST}"

if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
    log "Oh My Zsh 未安装，安装中..."
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>>"$LOG_FILE"; then
        log "Oh My Zsh 安装成功"
    else
        log "Oh My Zsh 安装失败，请检查 ${LOG_FILE}"
    fi
else
    log "Oh My Zsh 已安装，跳过安装"
fi

if command -v nvm >/dev/null 2>&1 || [[ -d "${HOME}/.nvm" ]]; then
    log "检测到 nvm；本脚本不再安装或配置 nvm。请确认迁移完成后再手动清理 ~/.nvm 和 shell 配置。"
fi

install_brew_formula_if_missing "fnm"
append_zshrc_once "# fnm" 'if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --use-on-cd --shell zsh)"
fi'

if command -v fnm >/dev/null 2>&1; then
    log "正在通过 fnm 安装 Node.js LTS..."
    eval "$(fnm env --shell bash)"
    if fnm install --lts --use 2>>"$LOG_FILE"; then
        INSTALLED_NODE_VERSION="$(fnm current 2>>"$LOG_FILE")"
        fnm default "$INSTALLED_NODE_VERSION" 2>>"$LOG_FILE"
        log "Node.js LTS 已安装并设置为 fnm 默认版本"
    else
        log "Node.js LTS 安装或默认版本设置失败，请检查 ${LOG_FILE}"
    fi
fi

install_brew_formula_if_missing "tmux"
install_brew_formula_if_missing "zellij"

install_brew_formula_if_missing "uv"
append_zshrc_once "# uv" 'export PATH="$HOME/.local/bin:$PATH"'

install_brew_formula_if_missing "pnpm"

echo ""
echo "=================================================="
echo "  本次 Brewfile 备份："
echo "  ${BREWFILE_TIMESTAMPED}"
echo ""
echo "  最新副本："
echo "  ${BREWFILE_LATEST}"
echo ""
echo "  全部历史备份："
ls -1t "${BREWFILE_BACKUP_DIR}/" | while read -r f; do
    echo "  - ${BREWFILE_BACKUP_DIR}/${f}"
done
echo "=================================================="
echo ""
log "备份和安装 Oh My Zsh、uv、fnm、pnpm、tmux、zellij 完成。"
