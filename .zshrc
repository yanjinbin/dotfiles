# =============================================================================
#  ~/.zshrc
#  Last optimized: 2026-04
# =============================================================================

# -----------------------------------------------------------------------------
# Powerlevel10k 即时提示（需放最顶部）
# 若用 robbyrussell 主题可注释此块
# -----------------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -----------------------------------------------------------------------------
# Oh My Zsh 核心配置
# -----------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME="robbyrussell"
# 若切换到 p10k，改为：
ZSH_THEME="powerlevel10k/powerlevel10k"

# 历史记录时间戳
HIST_STAMPS="yyyy-mm-dd"

# 插件列表（注意：zsh-syntax-highlighting 必须放最后）
plugins=(
  git
  uv
  pnpm
  docker-compose
  z
  you-should-use
  tmux
  zsh-autosuggestions
  gcma
  zsh-syntax-highlighting   # ⚠️ 必须最后一个
)

source "$ZSH/oh-my-zsh.sh"

# -----------------------------------------------------------------------------
# PATH 配置
# -----------------------------------------------------------------------------
# pnpm
# pnpm
export PNPM_HOME="${HOME}/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


# Maven
export MAVEN_HOME="$HOME/apache-maven-3.6.3"

# Go（修复：GOBIN 需显式定义，否则 $GOBIN 为空）
export GOPATH="$HOME/GolandProjects"
export GOBIN="$GOPATH/bin"
export GOPROXY="https://mirrors.tencent.com/go/"

# fnm (Node.js 版本管理)
FNM_PATH="/opt/homebrew/opt/fnm/bin"

# 统一 PATH 声明（避免多次 export PATH）
export PATH="$PNPM_HOME:$MAVEN_HOME/bin:$GOBIN:$FNM_PATH:$PATH"

# fnm 环境初始化
[[ -d "$FNM_PATH" ]] && eval "$(fnm env --shell zsh)"

# -----------------------------------------------------------------------------
# eza — 现代 ls 替代
# -----------------------------------------------------------------------------
alias ls='eza --icons --color=auto'
alias ll='eza -l  --icons --group-directories-first'
alias lla='eza -la --icons --group-directories-first'
alias llg='eza -l  --icons --git --group-directories-first'   # 带 Git 状态
alias llag='eza -la --icons --git --group-directories-first'
alias lld='eza -l  --icons --only-dirs'
alias llf='eza -l  --icons --only-files'

# 树形视图（lt=2层, lt3=3层, lt4=4层）
alias lt='eza  -T -L 2 --icons'
alias lt3='eza -T -L 3 --icons'
alias lt4='eza -T -L 4 --icons'

# -----------------------------------------------------------------------------
# uv — Python 包管理
# -----------------------------------------------------------------------------
alias ur='uv run python'
alias ua='uv add'
alias us='uv sync'
alias uvp='uv pip'

# -----------------------------------------------------------------------------
# Git 快捷
# -----------------------------------------------------------------------------
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'
alias gp='git push'
alias gpl='git pull'

# -----------------------------------------------------------------------------
# 系统 & 工具
# -----------------------------------------------------------------------------
alias c='clear'
alias y='yazi'
alias t='history | tail -100'
alias wattage='system_profiler SPPowerDataType | grep Wattage -C 5'
alias myip="curl -s http://ip-api.com/json | jq -r '\"\(.country) \(.regionName) \(.city) \(.isp) \(.query)\"'"

# SSH
alias loginaliyun='ssh -i ~/.ssh/aliyun_rsa root@121.41.102.247'

# ipv6 开关（仅限 Wi-Fi）
alias ipv6off="networksetup -setv6off Wi-Fi && echo '✅ IPv6 已关闭'"
alias ipv6on="networksetup -setv6automatic Wi-Fi && echo '✅ IPv6 已恢复'"

proxyon() {
  export http_proxy="http://127.0.0.1:7890"
  export https_proxy="http://127.0.0.1:7890"
  export all_proxy="socks5h://127.0.0.1:7890"
  echo "Proxy enabled:"
  env | grep -i proxy
}

proxyoff() {
  unset http_proxy https_proxy all_proxy
  echo "Proxy disabled"
  env | grep -i proxy
}
# Claude Code 遥测开关
claude-privacy-on() {
  export DISABLE_TELEMETRY=1
  export DISABLE_ERROR_REPORTING=1
  export CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1
  export DISABLE_FEEDBACK_COMMAND=1
  export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
  echo "🔒 隐私模式已开启（遥测/反馈/非必要流量：已关闭）"
}

claude-privacy-off() {
  unset DISABLE_TELEMETRY
  unset DISABLE_ERROR_REPORTING
  unset CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY
  unset DISABLE_FEEDBACK_COMMAND
  unset CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
  echo "🔓 隐私模式已关闭（遥测/反馈/非必要流量：已恢复默认）"
}

claude-privacy-status() {
  echo "DISABLE_TELEMETRY=${DISABLE_TELEMETRY:-0}"
  echo "DISABLE_ERROR_REPORTING=${DISABLE_ERROR_REPORTING:-0}"
  echo "CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=${CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY:-0}"
  echo "DISABLE_FEEDBACK_COMMAND=${DISABLE_FEEDBACK_COMMAND:-0}"
  echo "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=${CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC:-0}"
}

alias claudeon='claude-privacy-off'
alias claudeoff='claude-privacy-on'



# -----------------------------------------------------------------------------
# 实用函数
# -----------------------------------------------------------------------------

# mkdir 后自动 cd 进入
mkcd() { mkdir -p "$1" && cd "$1"; }

# 万能解压
extract() {
  case "$1" in
    *.tar.gz|*.tgz)  tar xzf "$1"  ;;
    *.tar.bz2|*.tbz) tar xjf "$1"  ;;
    *.tar.xz)        tar xJf "$1"  ;;
    *.tar)           tar xf  "$1"  ;;
    *.zip)           unzip   "$1"  ;;
    *.gz)            gunzip  "$1"  ;;
    *.rar)           unrar x "$1"  ;;
    *.7z)            7z x    "$1"  ;;
    *)               echo "不支持的格式: $1" ;;
  esac
}

# 快速查找文件
ff() { find . -name "*$1*" 2>/dev/null; }

# 端口占用查询
port() { lsof -i :"$1"; }

# >>>> p10k configure start >>>>
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# <<<< p10k configure end <<<<

export APP_IDENTITY="BloomBar Development"

# Added by Antigravity
export PATH="/Users/yanjinbin/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity
export PATH="/Users/yanjinbin/.antigravity/antigravity/bin:$PATH"
