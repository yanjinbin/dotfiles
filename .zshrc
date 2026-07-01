# =============================================================================
#  ~/.zshrc
#  Last synced: 2026-07
#  注意：本文件已隐去真实主机名/IP/密钥路径等隐私信息，克隆后请按需替换占位符
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
  gcma
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# zsh-autosuggestions 灰色提示颜色（默认 fg=8 太暗看不见，改亮）
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=245'

# -----------------------------------------------------------------------------
# PATH 配置
# -----------------------------------------------------------------------------
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

# rust镜像
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"

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

# SSH（真实主机/密钥路径为隐私信息，请在本机 .zshrc.local 或此处按需填写）
# alias loginaliyun='ssh -i ~/.ssh/<your_key> <user>@<your_server_ip>'

# ipv6 开关（仅限 Wi-Fi）
alias ipv6off="networksetup -setv6off Wi-Fi && echo '✅ IPv6 已关闭'"
alias ipv6on="networksetup -setv6automatic Wi-Fi && echo '✅ IPv6 已恢复'"

# AI CLI 快捷别名
alias cx="codex -c model_reasoning_effort="high" --dangerously-bypass-approvals-and-sandbox -c model_reasoning_summary="detailed" -c model_supports_reasoning_summaries=true"
alias cc="claude --dangerously-skip-permissions"


proxyon() {
  export http_proxy="http://127.0.0.1:7890"
  export https_proxy="http://127.0.0.1:7890"
  export all_proxy="socks5h://127.0.0.1:7890"
  echo "🔌 proxy on → 127.0.0.1:7890"
  env | grep -i proxy
}

proxyoff() {
  unset http_proxy https_proxy all_proxy
  echo "❌ proxy off"
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

# Claude Code 权限模式快捷别名
alias claude-bypass="claude --permission-mode bypassPermissions"
alias claude-auto="claude --permission-mode auto"
alias claude-edit="claude --permission-mode acceptEdits"
alias claude-plan="claude --permission-mode plan"
alias claude-ask="claude --permission-mode dontAsk"

# -----------------------------------------------------------------------------
# 实用函数
# -----------------------------------------------------------------------------
ai() {
  case "$1" in
    upgrade) _ai_upgrade ;;
    *) echo "Usage: ai upgrade" ;;
  esac
}

_ai_upgrade() {
  local RESET='\033[0m'
  local BOLD='\033[1m'
  local DIM='\033[2m'
  local GREEN='\033[38;5;120m'
  local RED='\033[38;5;203m'
  local YELLOW='\033[38;5;221m'

  _banner() {
    echo ""
    printf '\033[38;5;213m  ✦ \033[38;5;183mA\033[38;5;153mI\033[38;5;123m \033[38;5;120mC\033[38;5;121mL\033[38;5;122mI\033[38;5;148m \033[38;5;214mU\033[38;5;208mp\033[38;5;203md\033[38;5;204ma\033[38;5;205mt\033[38;5;206me\033[38;5;213m ✦\033[0m'
    echo ""
  }

  _spin() {
    local pid=$1 msg=$2
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local colors=('\033[38;5;213m' '\033[38;5;183m' '\033[38;5;153m' '\033[38;5;123m' '\033[38;5;120m')
    local i=0 c=0
    while kill -0 "$pid" 2>/dev/null; do
      printf "\r  ${colors[c]}${frames[i]}${RESET}  ${msg}"
      i=$(( (i+1) % ${#frames[@]} ))
      c=$(( (c+1) % ${#colors[@]} ))
      sleep 0.08
    done
  }

  _run() {
    local label=$1; shift
    local log
    log=$(mktemp)
    { "$@" >"$log" 2>&1; } &
    local pid=$!
    _spin $pid "$label"
    wait $pid
    local ok=$?
    rm -f "$log"
    [[ $ok -eq 0 ]] \
      && printf "\r  ${GREEN}✔${RESET}  ${BOLD}${label}${RESET}\n" \
      || printf "\r  ${RED}✘${RESET}  ${BOLD}${label}${RESET} ${DIM}(failed)${RESET}\n"
  }

  _row() {
    local icon=$1 name=$2 before=$3 after=$4
    if [[ "$before" == "$after" ]]; then
      printf "  %s  %-18s ${DIM}%-24s${RESET} ${YELLOW}↔${RESET} ${DIM}%s${RESET}\n" "$icon" "$name" "$before" "already latest"
    else
      printf "  %s  %-18s ${DIM}%-24s${RESET} ${GREEN}→${RESET} ${GREEN}${BOLD}%s${RESET}\n" "$icon" "$name" "$before" "$after"
    fi
  }

  # Antigravity agy 更新：非 npm 包，重跑官方 install 脚本拉最新二进制
  _update_agy() {
    curl -fsSL https://antigravity.google/cli/install.sh | bash
  }

  setopt LOCAL_OPTIONS NO_NOTIFY NO_MONITOR 2>/dev/null
  set +m 2>/dev/null

  local c_before x_before a_before
  c_before=$(claude --version 2>/dev/null || echo "—")
  x_before=$(codex --version 2>/dev/null || echo "—")
  a_before=$(agy --version 2>/dev/null || echo "—")

  _banner

  printf "  ${DIM}%s${RESET}\n" "·················································"
  _run "Anthropic claude " claude update
  _run "OpenAI codex     " npm update -g @openai/codex
  _run "Antigravity agy  " _update_agy
  printf "  ${DIM}%s${RESET}\n" "·················································"

  echo ""

  local c_after x_after a_after
  c_after=$(claude --version 2>/dev/null || echo "—")
  x_after=$(codex --version 2>/dev/null || echo "—")
  a_after=$(agy --version 2>/dev/null || echo "—")

  _row "🦀" "Anthropic claude" "$c_before" "$c_after"
  _row "🐙" "OpenAI codex"     "$x_before" "$x_after"
  _row "🛸" "Antigravity agy"  "$a_before" "$a_after"

  echo ""
  printf "  \033[38;5;213m✨\033[38;5;183m✨\033[38;5;153m✨\033[0m  ${DIM}all done!${RESET}\n"
  echo ""
}


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

# -----------------------------------------------------------------------------
# 其他工具集成 & 环境变量
# -----------------------------------------------------------------------------
# APP_IDENTITY：具体项目/工作标识，克隆本文件后请替换为自己的项目名
export APP_IDENTITY="Local Development"

# gcma（自定义 oh-my-zsh 插件，见 custom/plugins/gcma）默认使用的 AI agent
# agy = Antigravity，默认模型见插件内 default_model（Gemini 3.1 Pro (High)）
export GCMA_DEFAULT_AGENT=agy

export PATH="$HOME/.local/bin:$PATH"

# opencode CLI
export PATH="$HOME/.opencode/bin:$PATH"

# iTerm2 shell 集成（非 iTerm2 环境下该文件不存在，安全跳过）
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<

# >>> otty shell integration >>>
# Added by Otty — toggle in Settings > Shell > Shell Integration.
# Inert unless launched by Otty (it sets $OTTY_SHELL_INTEGRATION).
if [ -n "$OTTY_SHELL_INTEGRATION" ] && [ -r "$OTTY_SHELL_INTEGRATION/otty-integration.zsh" ]; then
  . "$OTTY_SHELL_INTEGRATION/otty-integration.zsh"
fi
# <<< otty shell integration <<<
