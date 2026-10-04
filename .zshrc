# =============================================================================
#  ~/.zshrc
#  Last optimized: 2026-08-20
# =============================================================================

# -----------------------------------------------------------------------------
# Powerlevel10k instant prompt (keep this block at the top).
# Comment out this block when using the robbyrussell theme.
# -----------------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -----------------------------------------------------------------------------
# Oh My Zsh core settings
# -----------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"

# Load only the Jujutsu vcs_info backend from zsh-jj. Keep Powerlevel10k,
# p10k-jj-status, Oh My Zsh jj aliases, and dynamic completion.
# Do not source zsh-jj.plugin.zsh because it resets PROMPT.
typeset -U fpath
autoload -Uz vcs_info
# Add user command completions (such as Otty) before Oh My Zsh starts.
fpath=("${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions" $fpath)
if [[ -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-jj/functions" ]]; then
  fpath+=("${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-jj/functions")
  zstyle ':vcs_info:*' enable jj
  # zstyle ':vcs_info:*' enable jj git  # Keep the Git backend disabled.
fi

# ZSH_THEME="robbyrussell"
# Use this theme to enable Powerlevel10k.
ZSH_THEME="powerlevel10k/powerlevel10k"


# History timestamps
HIST_STAMPS="yyyy-mm-dd"

# Set prompt colors and Git vcs visibility here.
#
# `P10K_JJ_STATUS_BACKGROUND` sets the JJ status background color.
# 30 is muted dark teal; use 24 for a dark blue background.
typeset -g P10K_JJ_STATUS_BACKGROUND=30
#
# `P10K_JJ_STATUS_FOREGROUND` sets the JJ status text color.
# 255 is bright white, suitable for dark backgrounds.
typeset -g P10K_JJ_STATUS_FOREGROUND=255
#
# `P10K_PROMPT_SHOW_GIT_STATUS` controls Git vcs visibility.
# 1 = show; 0 = hide. The Git plugin and commands remain available.
typeset -g P10K_PROMPT_SHOW_GIT_STATUS=1
#
# The variables below set the directory and Git segment colors.


#  ### 1. Soft light colors (recommended for a white background)

  # typeset -g P10K_DIR_BACKGROUND=153
  # typeset -g P10K_DIR_FOREGROUND=23

  # typeset -g P10K_JJ_STATUS_BACKGROUND=159
  # typeset -g P10K_JJ_STATUS_FOREGROUND=23

  # typeset -g P10K_GIT_CLEAN_BACKGROUND=152
  # typeset -g P10K_GIT_MODIFIED_BACKGROUND=223
  # typeset -g P10K_GIT_UNTRACKED_BACKGROUND=194
  # typeset -g P10K_GIT_CONFLICTED_BACKGROUND=217
  # typeset -g P10K_GIT_FOREGROUND=23

#   ### 2. Warm light colors

#   typeset -g P10K_DIR_BACKGROUND=188
#   typeset -g P10K_DIR_FOREGROUND=23

#   typeset -g P10K_JJ_STATUS_BACKGROUND=224
#   typeset -g P10K_JJ_STATUS_FOREGROUND=52

#   typeset -g P10K_GIT_CLEAN_BACKGROUND=253
#   typeset -g P10K_GIT_MODIFIED_BACKGROUND=223
#   typeset -g P10K_GIT_UNTRACKED_BACKGROUND=157
#   typeset -g P10K_GIT_CONFLICTED_BACKGROUND=217
#   typeset -g P10K_GIT_FOREGROUND=52

#   ### 3. Cool dark colors (a softer version of the current style)

#   typeset -g P10K_DIR_BACKGROUND=24
#   typeset -g P10K_DIR_FOREGROUND=255

#   typeset -g P10K_JJ_STATUS_BACKGROUND=30
#   typeset -g P10K_JJ_STATUS_FOREGROUND=255

#   typeset -g P10K_GIT_CLEAN_BACKGROUND=23
#   typeset -g P10K_GIT_MODIFIED_BACKGROUND=94
#   typeset -g P10K_GIT_UNTRACKED_BACKGROUND=23
#   typeset -g P10K_GIT_CONFLICTED_BACKGROUND=124
#   typeset -g P10K_GIT_FOREGROUND=255

#   ### 4. Dark blue and purple

#   typeset -g P10K_DIR_FOREGROUND=255

#   typeset -g P10K_JJ_STATUS_BACKGROUND=60
#   typeset -g P10K_JJ_STATUS_FOREGROUND=255

#   typeset -g P10K_GIT_CLEAN_BACKGROUND=59
#   typeset -g P10K_GIT_MODIFIED_BACKGROUND=96
#   typeset -g P10K_GIT_UNTRACKED_BACKGROUND=59
#   typeset -g P10K_GIT_CONFLICTED_BACKGROUND=124
#   typeset -g P10K_GIT_FOREGROUND=255

# Replace this group of color values to switch palettes.
# typeset -g P10K_DIR_BACKGROUND=24
# typeset -g P10K_DIR_FOREGROUND=255
# typeset -g P10K_GIT_CLEAN_BACKGROUND=23
# typeset -g P10K_GIT_MODIFIED_BACKGROUND=94
# typeset -g P10K_GIT_UNTRACKED_BACKGROUND=23
# typeset -g P10K_GIT_CONFLICTED_BACKGROUND=124
# typeset -g P10K_GIT_FOREGROUND=255

# Plugin list (zsh-syntax-highlighting must be last)
plugins=(
  # Keep Git aliases such as gst; P10K_PROMPT_SHOW_GIT_STATUS controls vcs visibility.
  git
  jj
  uv
  pnpm
  docker-compose
  z
  you-should-use
  tmux
  herdr
  # Git commit workflow plugins
  gcma
  jjma
  perfect-little-angle
  codex-niubikelas
  p10k-jj-status
  zsh-autosuggestions
  zsh-syntax-highlighting
)


source "$ZSH/oh-my-zsh.sh"

# Use brighter gray for zsh-autosuggestions; the default fg=8 is too dark.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=245'

# -----------------------------------------------------------------------------
# PATH settings (path and PATH stay in sync; keep only the first occurrence)
# -----------------------------------------------------------------------------
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export PNPM_HOME="${HOME}/Library/pnpm"
export MAVEN_HOME="$HOME/apache-maven-3.6.3"
export GOPATH="$HOME/GolandProjects"
export GOBIN="$GOPATH/bin"


# fnm (Node.js version manager)
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

# The custom herdr plugin loads first, so load the official aliases and session selector after PATH is ready.
source "$ZSH/plugins/herdr/herdr.plugin.zsh"

# Initialize the fnm environment.
if [[ -x "$FNM_PATH/fnm" ]]; then
  # Remove old multishell entries before reloading to prevent PATH growth.
  path=( ${path:#${XDG_STATE_HOME:-$HOME/.local/state}/fnm_multishells/*/bin} )
  eval "$("$FNM_PATH/fnm" env --shell zsh)"
fi

# -----------------------------------------------------------------------------
# eza - a modern replacement for ls
# -----------------------------------------------------------------------------
alias ls='eza --icons --color=auto'
alias ll='eza -l  --icons --group-directories-first'
alias lla='eza -la --icons --group-directories-first'
# alias llg='eza -l  --icons --git --group-directories-first'   # Git status; disabled.
# alias llag='eza -la --icons --git --group-directories-first'  # Git status; disabled.
alias lld='eza -l  --icons --only-dirs'
alias llf='eza -l  --icons --only-files'

# Tree view (lt: 2 levels, lt3: 3 levels, lt4: 4 levels)
alias lt='eza  -T -L 2 --icons'
alias lt3='eza -T -L 3 --icons'
alias lt4='eza -T -L 4 --icons'

# -----------------------------------------------------------------------------
# uv - Python package management
# -----------------------------------------------------------------------------
alias ur='uv run python'
alias ua='uv add'
alias us='uv sync'
alias uvp='uv pip'

# -----------
# opencode
# -----------
alias oc='opencode'
alias oca='opencode --auto'
alias ocy='opencode --yolo'

# -----------------------------------------------------------------------------
# Git shortcuts (JJ-only: keep these aliases commented out)
# -----------------------------------------------------------------------------
# alias gs='git status'
# alias gd='git diff'
# alias gl='git log --oneline --graph --decorate -20'
# alias gp='git push'
# alias gpl='git pull'

# -----------------------------------------------------------------------------
# System and tools
# -----------------------------------------------------------------------------
alias c='clear'
alias y='yazi'
alias t='history | tail -100'
alias wattage='system_profiler SPPowerDataType | grep Wattage -C 5'
alias myip="curl -s http://ip-api.com/json | jq -r '\"\(.country) \(.regionName) \(.city) \(.isp) \(.query)\"'"



# -----------------------------------------------------------------------------
# IPv6 controls (Wi-Fi only)
# -----------------------------------------------------------------------------
alias ipv6off="networksetup -setv6off Wi-Fi && echo '✅ IPv6 已关闭'"
alias ipv6on="networksetup -setv6automatic Wi-Fi && echo '✅ IPv6 已恢复'"
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && echo "DNS flushed"'

# Update Neovim plugins and Mason.
alias nvup='nvim --headless "+Lazy! sync" +qa && nvim --headless "+MasonUpdate" +qa'


# ==========================================================
# Time zone selection
# ==========================================================


# Default time zone for all new terminal windows.
# Use tz for a temporary override: tz jp / tz sg / tz la / tz system.
# Use the system time zone by default instead of Los Angeles.
unset TZ

# Set or clear the time zone override.
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

# Main time zone command
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

# Optional aliases for legacy commands
alias tokyo_time='tz jp'
alias singapore_time='tz sg'
alias la_time='tz la'
alias system_time='tz system'


# -----------------------------------------------------------------------------
# Utility functions
# -----------------------------------------------------------------------------

# Create a directory and change to it.
mkcd() {
  [[ -n "$1" ]] || {
    echo "用法：mkcd <目录>"
    return 2
  }

  mkdir -p -- "$1" && cd -- "$1"
}

# Extract archives by file extension.
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

# Find files by name.
ff() {
  [[ -n "$1" ]] || {
    echo "用法：ff <关键词>"
    return 2
  }

  find . -name "*$1*" 2>/dev/null
}

# Show processes that use a port.
port() {
  [[ -n "$1" ]] || {
    echo "用法：port <端口>"
    return 2
  }

  lsof -i :"$1"
}




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


# pnpm
export PNPM_HOME="/Users/yanjinbin/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end



# >>>>> Paddle development keys start >>>>>

# Load private local settings when available.
[[ -r "$HOME/.config/zsh/private.zsh" ]] && source "$HOME/.config/zsh/private.zsh"

# <<<< Paddle development keys end <<<<<<


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# Added by Antigravity CLI installer
export PATH="/Users/yanjinbin/.local/bin:$PATH"


# Commit+ command line tools
export PATH="$HOME/.local/bin:$PATH"


# Added by Antigravity IDE
export PATH="/Users/yanjinbin/.antigravity-ide/antigravity-ide/bin:$PATH"

# >>> otty shell integration >>>
# Added by Otty — toggle in Settings > Shell > Shell Integration.
# Inert unless launched by Otty (it sets $OTTY_SHELL_INTEGRATION).
if [ -n "$OTTY_SHELL_INTEGRATION" ] && [ -r "$OTTY_SHELL_INTEGRATION/otty-integration.zsh" ]; then
  . "$OTTY_SHELL_INTEGRATION/otty-integration.zsh"
fi
# <<< otty shell integration <<<
