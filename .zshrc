# =============================================================================
#  ~/.zshrc
#  Last optimized: 2026-08-20
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

# Prompt 配置：颜色和是否显示 Git vcs 都可以在这里调整。
#
# `P10K_JJ_STATUS_BACKGROUND` 控制 JJ 状态区域的背景色。
# 这里的 30 代表低饱和深青色；改成 24 可使用深蓝色背景。
typeset -g P10K_JJ_STATUS_BACKGROUND=30
#
# `P10K_JJ_STATUS_FOREGROUND` 控制 JJ 状态区域的字体颜色。
# 这里的 255 代表亮白色，适合深色背景。
typeset -g P10K_JJ_STATUS_FOREGROUND=255
#
# `P10K_PROMPT_SHOW_GIT_STATUS` 控制是否显示 Git vcs 状态。
# 1 = 显示；0 = 隐藏。隐藏后仍然保留 Git 插件和 Git 命令。
typeset -g P10K_PROMPT_SHOW_GIT_STATUS=1
#
# 下面这些变量控制目录段和 Git 段的整套配色。


#  ### 1. 浅色柔和（推荐白色背景）

  # typeset -g P10K_DIR_BACKGROUND=153
  # typeset -g P10K_DIR_FOREGROUND=23

  # typeset -g P10K_JJ_STATUS_BACKGROUND=159
  # typeset -g P10K_JJ_STATUS_FOREGROUND=23

  # typeset -g P10K_GIT_CLEAN_BACKGROUND=152
  # typeset -g P10K_GIT_MODIFIED_BACKGROUND=223
  # typeset -g P10K_GIT_UNTRACKED_BACKGROUND=194
  # typeset -g P10K_GIT_CONFLICTED_BACKGROUND=217
  # typeset -g P10K_GIT_FOREGROUND=23

#   ### 2. 浅色暖色

#   typeset -g P10K_DIR_BACKGROUND=188
#   typeset -g P10K_DIR_FOREGROUND=23

#   typeset -g P10K_JJ_STATUS_BACKGROUND=224
#   typeset -g P10K_JJ_STATUS_FOREGROUND=52

#   typeset -g P10K_GIT_CLEAN_BACKGROUND=253
#   typeset -g P10K_GIT_MODIFIED_BACKGROUND=223
#   typeset -g P10K_GIT_UNTRACKED_BACKGROUND=157
#   typeset -g P10K_GIT_CONFLICTED_BACKGROUND=217
#   typeset -g P10K_GIT_FOREGROUND=52

#   ### 3. 深色冷色（当前风格的舒适版）

#   typeset -g P10K_DIR_BACKGROUND=24
#   typeset -g P10K_DIR_FOREGROUND=255

#   typeset -g P10K_JJ_STATUS_BACKGROUND=30
#   typeset -g P10K_JJ_STATUS_FOREGROUND=255

#   typeset -g P10K_GIT_CLEAN_BACKGROUND=23
#   typeset -g P10K_GIT_MODIFIED_BACKGROUND=94
#   typeset -g P10K_GIT_UNTRACKED_BACKGROUND=23
#   typeset -g P10K_GIT_CONFLICTED_BACKGROUND=124
#   typeset -g P10K_GIT_FOREGROUND=255

#   ### 4. 深色蓝紫

#   typeset -g P10K_DIR_FOREGROUND=255

#   typeset -g P10K_JJ_STATUS_BACKGROUND=60
#   typeset -g P10K_JJ_STATUS_FOREGROUND=255

#   typeset -g P10K_GIT_CLEAN_BACKGROUND=59
#   typeset -g P10K_GIT_MODIFIED_BACKGROUND=96
#   typeset -g P10K_GIT_UNTRACKED_BACKGROUND=59
#   typeset -g P10K_GIT_CONFLICTED_BACKGROUND=124
#   typeset -g P10K_GIT_FOREGROUND=255

# 以后切换模板时，只需替换这一组颜色值。
# typeset -g P10K_DIR_BACKGROUND=24
# typeset -g P10K_DIR_FOREGROUND=255
# typeset -g P10K_GIT_CLEAN_BACKGROUND=23
# typeset -g P10K_GIT_MODIFIED_BACKGROUND=94
# typeset -g P10K_GIT_UNTRACKED_BACKGROUND=23
# typeset -g P10K_GIT_CONFLICTED_BACKGROUND=124
# typeset -g P10K_GIT_FOREGROUND=255

# 插件列表（注意：zsh-syntax-highlighting 必须放最后）
plugins=(
  # 保留 gst 等 Git aliases；vcs 显示由 P10K_PROMPT_SHOW_GIT_STATUS 控制
  git
  jj
  uv
  pnpm
  docker-compose
  z
  you-should-use
  tmux
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

  echo "🔌 终端代理已开启 → 127.0.0.1:7890  关闭请用（proxyoff）"
}

proxyoff() {
  unset http_proxy https_proxy all_proxy
  unset HTTP_PROXY HTTPS_PROXY ALL_PROXY

  echo "🔌 终端代理已关闭"
}


# ==========================================================
# 🔒 Claude Code Privacy Control
# Claude Code 隐私 / 遥测控制
# ==========================================================


claude-privacy-on() {

  export DISABLE_TELEMETRY=1
  export DO_NOT_TRACK=1
  export DISABLE_ERROR_REPORTING=1
  export CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1
  export DISABLE_FEEDBACK_COMMAND=1
  export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " 🔒 Claude Code 隐私模式已开启"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo " ✅ 遥测收集          已关闭"
  echo " ✅ 数据追踪          已保护"
  echo " ✅ 错误报告          已关闭"
  echo " ✅ 用户反馈调查      已关闭"
  echo " ✅ Feedback 命令     已隐藏"
  echo " ✅ 非必要流量        已关闭"
  echo ""

}


claude-privacy-off() {

  unset DISABLE_TELEMETRY
  unset DO_NOT_TRACK
  unset DISABLE_ERROR_REPORTING
  unset CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY
  unset DISABLE_FEEDBACK_COMMAND
  unset CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " 🔓 Claude Code 默认模式已恢复"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo " ↩ 遥测收集          默认状态"
  echo " ↩ 数据追踪          默认状态"
  echo " ↩ 错误报告          默认状态"
  echo " ↩ 用户反馈调查      默认状态"
  echo " ↩ Feedback 命令     默认状态"
  echo " ↩ 非必要流量        默认状态"
  echo ""

}


claude-privacy-status() {

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " 🔍 Claude Code 隐私状态"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  [[ "${DISABLE_TELEMETRY}" == "1" ]] \
    && echo " 🔒 遥测收集          已关闭" \
    || echo " ⚪ 遥测收集          默认开启"

  [[ "${DO_NOT_TRACK}" == "1" ]] \
    && echo " 🛡️ 数据追踪          已保护" \
    || echo " ⚪ 数据追踪          默认状态"

  [[ "${DISABLE_ERROR_REPORTING}" == "1" ]] \
    && echo " 🐞 错误报告          已关闭" \
    || echo " ⚪ 错误报告          默认状态"

  [[ "${CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY}" == "1" ]] \
    && echo " 📝 用户反馈调查      已关闭" \
    || echo " ⚪ 用户反馈调查      默认状态"

  [[ "${DISABLE_FEEDBACK_COMMAND}" == "1" ]] \
    && echo " 💬 Feedback 命令     已隐藏" \
    || echo " ⚪ Feedback 命令     默认状态"

  [[ "${CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC}" == "1" ]] \
    && echo " 🌐 非必要流量        已关闭" \
    || echo " ⚪ 非必要流量        默认状态"


  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

}


# ==========================================================
# 🤖 AI CLI
# ==========================================================

# ------------------------------------------------------------------
# 公共运行环境：仅影响 AI CLI 及其子进程
# TZ    : Asia/Kuala_Lumpur
# LANG  : en_US.UTF-8
# LC_ALL: en_US.UTF-8
# Proxy : 默认关闭；使用 cxp / ccp / agp 时临时开启
# ------------------------------------------------------------------

ai_env() {
  echo "🌐 AI CLI ENV → Timezone=Asia/Kuala_Lumpur | Language=en_US | Locale=en_US.UTF-8"
  /usr/bin/env \
    TZ=Asia/Kuala_Lumpur \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    "$@"
}

# ------------------------------------------------------------------
# Claude Code：隐私控制
# ------------------------------------------------------------------

alias claude-private='claude-privacy-on'
alias claude-normal='claude-privacy-off'
alias claude-status='claude-privacy-status'

# 默认启用隐私模式；仅在显式执行 claude-status 时显示详情。
claude-privacy-on >/dev/null

# ------------------------------------------------------------------
# Claude Code：启动与权限模式
# ------------------------------------------------------------------

# 默认：公共环境 + 跳过权限确认（高风险）
claude() {
  ai_env claude \
    --dangerously-skip-permissions \
    "$@"
}

alias cc='claude'

# 显式权限模式：保留公共环境，不经过默认 YOLO 包装器
alias cc-bypass='ai_env claude --permission-mode bypassPermissions'
alias cc-auto='ai_env claude --permission-mode auto'
alias cc-edit='ai_env claude --permission-mode acceptEdits'
alias cc-plan='ai_env claude --permission-mode plan'
alias cc-ask='ai_env claude --permission-mode dontAsk'

# 兼容旧命令
alias claude-bypass='cc-bypass'
alias claude-auto='cc-auto'
alias claude-edit='cc-edit'
alias claude-plan='cc-plan'
alias claude-ask='cc-ask'

# ------------------------------------------------------------------
# OpenAI Codex：启动与审批模式
# ------------------------------------------------------------------
# 默认：
# codex = codex --yolo + high reasoning
# ------------------------------------------------------------------

# 默认：公共环境 + YOLO + High Reasoning
codex() {
  ai_env codex \
    --yolo \
    -c model_reasoning_effort='"high"' \
    -c model_reasoning_summary='"detailed"' \
    -c model_supports_reasoning_summaries=true \
    "$@"
}

# ------------------------------------------------------------------
# 快捷入口
# ------------------------------------------------------------------

# 默认 YOLO + High Reasoning
alias cx='codex'

# 普通启动（保留公共环境，不带 YOLO，不覆盖推理参数）
alias cx-safe='ai_env codex'

# ------------------------------------------------------------------
# Approval Policy
# ------------------------------------------------------------------

# 永不询问（危险）
alias cx-never='ai_env codex -a never'

# 按需询问
alias cx-request='ai_env codex -a on-request'

# 不信任模式
alias cx-untrusted='ai_env codex -a untrusted'

# ------------------------------------------------------------------
# 兼容旧命令
# ------------------------------------------------------------------

alias codex-never='cx-never'
alias codex-request='cx-request'
alias codex-untrusted='cx-untrusted'

# ------------------------------------------------------------------
# Antigravity：启动与权限模式
# ------------------------------------------------------------------

# 默认：公共环境 + 跳过权限确认（高风险）
agy() {
  ai_env agy \
    --dangerously-skip-permissions \
    "$@"
}

alias ag='agy'

# 显式权限模式：保留公共环境，不经过默认 YOLO 包装器
alias ag-edit='ai_env agy --mode accept-edits'
alias ag-plan='ai_env agy --mode plan'

# 兼容旧命令
alias agyd='ag'
alias agy-edit='ag-edit'
alias agy-plan='ag-plan'

# ------------------------------------------------------------------
# AI CLI：一次性代理快捷入口（仅影响本次命令）
# ------------------------------------------------------------------

aip() (
  export http_proxy="http://127.0.0.1:7890" https_proxy="http://127.0.0.1:7890" all_proxy="socks5h://127.0.0.1:7890"
  export HTTP_PROXY="$http_proxy" HTTPS_PROXY="$https_proxy" ALL_PROXY="$all_proxy"

  echo "🟢 AI Proxy ON → 127.0.0.1:7890（$1）"
  "$@"
)

cxp() { aip codex "$@"; }
ccp() { aip claude "$@"; }
agp() { aip agy "$@"; }

# ------------------------------------------------------------------
# opencodex：统一使用官方后台服务管理
# ------------------------------------------------------------------

# claude-env.sh hook 由 opencodex 自动维护在文件末尾。

ocx_service() {
  (( $+commands[ocx] )) || {
    echo "ocx 未安装或不在 PATH 中"
    return 127
  }

  local action="${1:-status}"
  local log_file="${OPENCODEX_HOME:-$HOME/.opencodex}/service.log"

  case "$action" in
    install)        command ocx service install ;;
    start)          command ocx service start ;;
    on|repair|restart)
                    command ocx service repair ;;
    off|stop)       command ocx service stop ;;
    status)         command ocx service status ;;
    health)         command ocx health --json ;;
    doctor)         command ocx doctor ;;
    sync)           command ocx sync ;;
    update)         command ocx update ;;
    gui)            command ocx gui ;;
    log|logs)
      local lines="${2:-100}"
      [[ "$lines" == <-> ]] || {
        echo "日志行数必须是正整数"
        return 2
      }
      [[ -r "$log_file" ]] || {
        echo "OCX 日志不存在：$log_file"
        return 1
      }
      command tail -n "$lines" -- "$log_file"
      ;;
    *)
      echo "用法：ocx_service {install|start|repair|stop|status|health|doctor|sync|update|gui|logs [行数]}"
      return 2
      ;;
  esac
}

# 兼容原有入口；on 现在会刷新并重启已安装的 launchd 服务。
ocx_on()     { ocx_service repair; }
ocx_off()    { ocx_service stop; }
ocx_status() { ocx_service status; }

alias ocxon='ocx_on'
alias ocxoff='ocx_off'
alias ocxstatus='ocx_status'
alias ocxr='ocx_service repair'
alias ocxh='ocx_service health'
alias ocxd='ocx_service doctor'
alias ocxl='ocx_service logs'

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



# # opencodex claude-env hook
# if [ -f ~/.opencodex/claude-env.sh ]; then
#   source ~/.opencodex/claude-env.sh
# fi



# >>>> p10k configure start >>>>
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# <<<< p10k configure end <<<<


# pnpm
export PNPM_HOME="/Users/yanjinbin/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end



# >>>>>  paddle 测试环境key start >>>>>

#  描述
[[ -r "$HOME/.config/zsh/private.zsh" ]] && source "$HOME/.config/zsh/private.zsh"

# <<<< paddle 测试环境key end <<<<<<

# >>> otty shell integration >>>
# Added by Otty — toggle in Settings > Shell > Shell Integration.
# Inert unless launched by Otty (it sets $OTTY_SHELL_INTEGRATION).
if [ -n "$OTTY_SHELL_INTEGRATION" ] && [ -r "$OTTY_SHELL_INTEGRATION/otty-integration.zsh" ]; then
  . "$OTTY_SHELL_INTEGRATION/otty-integration.zsh"
fi
# <<< otty shell integration <<<
