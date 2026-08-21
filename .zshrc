# =============================================================================
#  ~/.zshrc
#  Last optimized: 2026-08-20
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

# zsh-jj：只启用 Jujutsu 的 vcs_info 后端，保留现有 Powerlevel10k、
# p10k-jj-status、Oh My Zsh jj 别名和动态补全。
# 不 source zsh-jj.plugin.zsh，因为它会重设 PROMPT。
typeset -U fpath
autoload -Uz vcs_info
# 用户级命令补全（例如 Otty）；必须在 Oh My Zsh 初始化前加入。
fpath=("${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions" $fpath)
if [[ -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-jj/functions" ]]; then
  fpath+=("${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-jj/functions")
  zstyle ':vcs_info:*' enable jj
  # zstyle ':vcs_info:*' enable jj git  # Git 后端保留为注释，不启用
fi

# ZSH_THEME="robbyrussell"
# 若切换到 p10k，改为：
ZSH_THEME="powerlevel10k/powerlevel10k"


# 历史记录时间戳
HIST_STAMPS="yyyy-mm-dd"

# 插件列表（注意：zsh-syntax-highlighting 必须放最后）
plugins=(
  # 仅保留 gst 等 Git aliases；P10k 的 Git vcs segment 仍在 ~/.p10k.zsh 中关闭
  git
  jj
  uv
  docker-compose
  z
  you-should-use
  tmux
  opencodex
  # Git commit 工作流插件，保留为注释
  # gcma
  jjma
  p10k-jj-status
  zsh-autosuggestions
  zsh-syntax-highlighting
)


source "$ZSH/oh-my-zsh.sh"

# zsh-autosuggestions 灰色提示颜色（默认 fg=8 太暗看不见，改亮）
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=245'

# -----------------------------------------------------------------------------
# PATH 配置（path 与 PATH 自动同步，并按首次出现顺序去重）
# -----------------------------------------------------------------------------
export PNPM_HOME="${HOME}/Library/pnpm"
export MAVEN_HOME="$HOME/apache-maven-3.6.3"
export GOPATH="$HOME/GolandProjects"
export GOBIN="$GOPATH/bin"
export GOPROXY="https://mirrors.tencent.com/go/"

# Rust 镜像
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"

# fnm（Node.js 版本管理）
FNM_PATH="/opt/homebrew/opt/fnm/bin"

typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/.opencode/bin"
  "$PNPM_HOME"
  "$MAVEN_HOME/bin"
  "$GOBIN"
  "$FNM_PATH"
  $path
)
export PATH

# fnm 环境初始化
if [[ -x "$FNM_PATH/fnm" ]]; then
  # 重载配置前移除旧 multishell 入口，避免 PATH 持续累积。
  path=( ${path:#${XDG_STATE_HOME:-$HOME/.local/state}/fnm_multishells/*/bin} )
  eval "$("$FNM_PATH/fnm" env --shell zsh)"
fi

# -----------------------------------------------------------------------------
# eza — 现代 ls 替代
# -----------------------------------------------------------------------------
alias ls='eza --icons --color=auto'
alias ll='eza -l  --icons --group-directories-first'
alias lla='eza -la --icons --group-directories-first'
# alias llg='eza -l  --icons --git --group-directories-first'   # Git 状态，已停用
# alias llag='eza -la --icons --git --group-directories-first'  # Git 状态，已停用
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
# Git 快捷（JJ-only：保留为注释，不启用）
# -----------------------------------------------------------------------------
# alias gs='git status'
# alias gd='git diff'
# alias gl='git log --oneline --graph --decorate -20'
# alias gp='git push'
# alias gpl='git pull'

# -----------------------------------------------------------------------------
# 系统 & 工具
# -----------------------------------------------------------------------------
alias c='clear'
alias y='yazi'
alias t='history | tail -100'
alias wattage='system_profiler SPPowerDataType | grep Wattage -C 5'
alias myip="curl -s http://ip-api.com/json | jq -r '\"\(.country) \(.regionName) \(.city) \(.isp) \(.query)\"'"


# -----------------------------------------------------------------------------
# IPv6 开关（仅限 Wi-Fi）
# -----------------------------------------------------------------------------
alias ipv6off="networksetup -setv6off Wi-Fi && echo '✅ IPv6 已关闭'"
alias ipv6on="networksetup -setv6automatic Wi-Fi && echo '✅ IPv6 已恢复'"
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && echo "DNS flushed"'

# 快速更新 Neovim 插件和 Mason
alias nvup='nvim --headless "+Lazy! sync" +qa && nvim --headless "+MasonUpdate" +qa'


# ==========================================================
# 🌍 时区切换
# ==========================================================


# 默认时区（所有新终端窗口生效）
# 使用 tz 命令可临时切换：tz jp / tz sg / tz la / tz system
# 2026-08-13: 恢复系统默认时区，不再默认使用洛杉矶；需要时用 tz 命令临时切换
unset TZ

# 通用时区切换
_tz_switch() {
    if [[ -z "$1" ]]; then
        unset TZ
        local title="🖥️ 系统默认时区"
    else
        export TZ="$1"
        local title="$2"
    fi

    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " $title"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🕒 TZ        : ${TZ:-System Default}"
    echo "🌏 时区缩写  : $(date +%Z)"
    echo "📅 当前时间  : $(date '+%Y-%m-%d %H:%M:%S %a')"
    echo
}

# 主命令
tz() {
    case "$1" in
        jp|tokyo)
            _tz_switch "Asia/Tokyo" "🇯🇵 东京时区"
            ;;
        sg|singapore)
            _tz_switch "Asia/Singapore" "🇸🇬 新加坡时区"
            ;;
        la|us|california|losangeles)
            _tz_switch "America/Los_Angeles" "🇺🇸 美国洛杉矶（加州）时区"
            ;;
        system|default|reset)
            _tz_switch
            ;;
        *)
            cat <<'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 🌍 时区切换
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

用法：
  tz <参数>

参数：

  jp        🇯🇵 东京
  sg        🇸🇬 新加坡
  la        🇺🇸 洛杉矶（加州）
  system    🖥️ 恢复系统默认时区

示例：

  tz jp
  tz sg
  tz la
  tz system

EOF
            ;;
    esac
}

# 兼容旧命令（可选）
alias tokyo_time='tz jp'
alias singapore_time='tz sg'
alias la_time='tz la'
alias system_time='tz system'


# ==========================================================
# 🔌 终端代理
# ==========================================================

proxyon() {
  export http_proxy="http://127.0.0.1:7890"
  export https_proxy="$http_proxy"
  export all_proxy="socks5h://127.0.0.1:7890"

  export HTTP_PROXY="$http_proxy"
  export HTTPS_PROXY="$https_proxy"
  export ALL_PROXY="$all_proxy"

  echo "🔌 终端代理已开启 → 127.0.0.1:7890"
}

proxyoff() {
  unset http_proxy https_proxy all_proxy
  unset HTTP_PROXY HTTPS_PROXY ALL_PROXY

  echo "🔌 终端代理已关闭"
}


# ==========================================================
# 🤖 AI CLI
# ==========================================================

# ------------------------------------------------------------------
# OpenAI Codex：启动与审批模式
# ------------------------------------------------------------------
# 默认：
# codex = codex --yolo + high reasoning
# ------------------------------------------------------------------


# 默认 Codex 启动模式
function codex() {
    command codex \
        --yolo \
        -c model_reasoning_effort="high" \
        -c model_reasoning_summary="detailed" \
        -c model_supports_reasoning_summaries=true \
        "$@"
}


# ------------------------------------------------------------------
# 快捷入口
# ------------------------------------------------------------------

# 默认 YOLO + High Reasoning
alias cx='codex'


# 普通启动（不带 YOLO，不覆盖推理参数）
alias cx-safe='command codex'


# ------------------------------------------------------------------
# Approval Policy
# ------------------------------------------------------------------

# 永不询问（危险）
alias cx-never='command codex -a never'


# 按需询问
alias cx-request='command codex -a on-request'


# 不信任模式
alias cx-untrusted='command codex -a untrusted'


# ------------------------------------------------------------------
# 兼容旧命令
# ------------------------------------------------------------------

alias codex-never='cx-never'
alias codex-request='cx-request'
alias codex-untrusted='cx-untrusted'
# ------------------------------------------------------------------
# Antigravity：启动与权限模式
# ------------------------------------------------------------------

# 常用入口：跳过权限确认（高风险）
alias ag='agy --dangerously-skip-permissions'

alias ag-edit='agy --mode accept-edits'
alias ag-plan='agy --mode plan'

# 兼容旧命令
alias agyd='ag'
alias agy-edit='ag-edit'
alias agy-plan='ag-plan'

# -----------------------------------------------------------------------------
# AI CLI 升级命令
# -----------------------------------------------------------------------------

# 将完整实现放在独立文件，避免 .zshrc 过长。
[[ -r "$HOME/.config/zsh/ai-upgrade.zsh" ]] && source "$HOME/.config/zsh/ai-upgrade.zsh"


# -----------------------------------------------------------------------------
# 实用函数
# -----------------------------------------------------------------------------

# mkdir 后自动 cd 进入
mkcd() {
  [[ -n "$1" ]] || {
    echo "用法：mkcd <目录>"
    return 2
  }

  mkdir -p -- "$1" && cd -- "$1"
}

# 万能解压
extract() {
  [[ -f "$1" ]] || {
    echo "文件不存在：${1:-<未指定>}"
    return 2
  }

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
ff() {
  [[ -n "$1" ]] || {
    echo "用法：ff <关键词>"
    return 2
  }

  find . -name "*$1*" 2>/dev/null
}

# 端口占用查询
port() {
  [[ -n "$1" ]] || {
    echo "用法：port <端口>"
    return 2
  }

  lsof -i :"$1"
}




export GCMA_DEFAULT_AGENT=agy
export JJMA_DEFAULT_AGENT=agy

if [[ -r "$HOME/.iterm2_shell_integration.zsh" ]]; then
  source "$HOME/.iterm2_shell_integration.zsh"
fi

# <<< jj dynamic completion cache <<<
if (( $+commands[jj] )); then
  typeset _jj_completion_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions/_jj"
  if [[ ! -s "$_jj_completion_cache" || "$commands[jj]" -nt "$_jj_completion_cache" ]]; then
    mkdir -p "${_jj_completion_cache:h}"
    if COMPLETE=zsh jj >| "${_jj_completion_cache}.tmp.$$"; then
      command mv -f "${_jj_completion_cache}.tmp.$$" "$_jj_completion_cache"
    else
      command rm -f "${_jj_completion_cache}.tmp.$$"
    fi
  fi
  [[ -r "$_jj_completion_cache" ]] && source "$_jj_completion_cache"
  unset _jj_completion_cache
fi



# >>>> p10k configure start >>>>
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# <<<< p10k configure end <<<<


# fnm
FNM_PATH="/opt/homebrew/opt/fnm/bin"
if [ -d "$FNM_PATH" ]; then
  eval "$(fnm env --shell zsh)"
fi

# pnpm
export PNPM_HOME="/Users/yanjinbin/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end


# Added by Antigravity CLI installer
export PATH="/Users/yanjinbin/.local/bin:$PATH"

# >>> otty shell integration >>>
# Added by Otty — toggle in Settings > Shell > Shell Integration.
# Inert unless launched by Otty (it sets $OTTY_SHELL_INTEGRATION).
if [ -n "$OTTY_SHELL_INTEGRATION" ] && [ -r "$OTTY_SHELL_INTEGRATION/otty-integration.zsh" ]; then
  . "$OTTY_SHELL_INTEGRATION/otty-integration.zsh"
fi
# <<< otty shell integration <<<
