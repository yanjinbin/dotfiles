#!/bin/bash

# Homebrew 备份和恢复脚本

# 备份路径
BREWFILE_PATH=~/Brewfile
LOG_FILE=~/brew_backup_restore.log

# 创建日志文件
touch $LOG_FILE

# 日志函数
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# 检查 Homebrew 是否已安装
if ! command -v brew &> /dev/null; then
    log "Homebrew 未安装，请先安装 Homebrew。"
    exit 1
fi

# 导出所有已安装的包、cask 和 tap 到 Brewfile
log "正在导出所有已安装的 Homebrew 依赖..."
brew bundle dump --file="$BREWFILE_PATH" --force 2>>$LOG_FILE
if [[ $? -eq 0 ]]; then
    log "已将依赖导出至 $BREWFILE_PATH"
else
    log "导出失败，请检查错误日志。"
    exit 1
fi

# 显示 Brewfile 内容
log "已生成的 Brewfile 内容如下："
cat "$BREWFILE_PATH" | tee -a $LOG_FILE

# 提供恢复命令
log "如需恢复依赖，请运行以下命令："
log "brew bundle install --file=$BREWFILE_PATH"

# 安装 ohmyzsh（如果未安装）
if ! command -v zsh &> /dev/null; then
    log "Zsh 未安装，尝试安装 Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 2>>$LOG_FILE
    if [[ $? -eq 0 ]]; then
        log "Oh My Zsh 安装成功"
    else
        log "Oh My Zsh 安装失败"
    fi
else
    log "Zsh 已安装，跳过 Oh My Zsh 安装"
fi

# 安装 nvm（如果未安装）
if ! command -v nvm &> /dev/null; then
    log "nvm 未安装，安装中..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash 2>>$LOG_FILE
    if [[ $? -eq 0 ]]; then
        log "nvm 安装成功"
    else
        log "nvm 安装失败"
    fi
else
    log "nvm 已安装，跳过安装"
fi

# 安装 tmux（如果未安装）
if ! command -v tmux &> /dev/null; then
    log "tmux 未安装，安装中..."
    bash <(curl -L https://zellij.dev/launch) 2>>$LOG_FILE
    if [[ $? -eq 0 ]]; then
        log "tmux 安装成功"
    else
        log "tmux 安装失败"
    fi
else
    log "tmux 已安装，跳过安装"
fi

# 配置 pyenv（如果未安装）
if ! command -v pyenv &> /dev/null; then
    log "pyenv 未安装，安装中..."
    curl https://pyenv.run | bash 2>>$LOG_FILE
    if [[ $? -eq 0 ]]; then
        log "pyenv 安装成功"
    else
        log "pyenv 安装失败"
    fi
else
    log "pyenv 已安装，跳过安装"
fi

# 更新 .zshrc 设置 pyenv 环境变量
if ! grep -q 'pyenv' ~/.zshrc; then
    log "配置 pyenv 环境变量..."
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
    echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc
    log ".zshrc 更新成功"
else
    log ".zshrc 已包含 pyenv 配置，跳过更新"
fi

# 安装 pnpm（如果未安装）
if ! command -v pnpm &> /dev/null; then
    log "pnpm 未安装，安装中..."
    curl -fsSL https://get.pnpm.io/install.sh | sh 2>>$LOG_FILE
    if [[ $? -eq 0 ]]; then
        log "pnpm 安装成功"
    else
        log "pnpm 安装失败"
    fi
else
    log "pnpm 已安装，跳过安装"
fi

log "备份和安装ohmyzsh, pyenv, nvm, pnpm,tmux完成。"
