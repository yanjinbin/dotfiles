# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"
# ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(git zsh-autosuggestions zsh-syntax-highlighting )

plugins=( uv git pnpm docker-compose z you-should-use tmux zsh-autosuggestions
zsh-syntax-highlighting )
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# Python (pyenv)
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# PNPM
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Maven
export MAVEN_HOME="$HOME/apache-maven-3.6.3"
export PATH="$MAVEN_HOME/bin:$PATH"

# Go
# export GO111MODULE=on
export GOPROXY=https://mirrors.tencent.com/go/
# export GOPROXY=https://goproxy.cn,https://mirrors.tencent.com/go,direct
# export GOPROXY=https://goproxy.cn,direct
export GOPATH="$HOME/GolandProjects"
export GOBIN="$GOPATH/bin"
export PATH="$GOBIN:$PATH"


### >>> alias config start >>>>
##### Proxy 切换 #####
# ===== Auto proxy on (every new tab/window) =====
export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"
export all_proxy="socks5://127.0.0.1:7890"

alias proxyon='export http_proxy="http://127.0.0.1:7890" https_proxy="http://127.0.0.1:7890" all_proxy="socks5://127.0.0.1:7890"'
alias proxyoff='unset http_proxy https_proxy all_proxy'
# ==============================================





##### 常用别名 #####
# ==============================
# eza - modern ls replacement
# ==============================

# 基础：替代 ls（彩色 + 图标）
alias ls='eza --icons --color=auto'

# 常用：长列表（不显示 owner / group，目录优先）
alias ll='eza -l --icons --group-directories-first'

# 全量：包含隐藏文件（.git / .env 等）
alias lla='eza -la --icons --group-directories-first'

# 树形：查看项目结构（2 层，最常用）
alias lt='eza -T -L 2 --icons'
alias lt2='eza -T -L 2 --icons'
# ------------------------------
# 进阶（可选但强烈推荐）
# ------------------------------

# 带 Git 状态（非常适合项目目录）
alias llg='eza -l --icons --git --group-directories-first'
alias llag='eza -la --icons --git --group-directories-first'

# 只看目录 / 只看文件
alias lld='eza -l --icons --only-dirs'
alias llf='eza -l --icons --only-files'

# 更深的树（调试项目结构）
alias lt3='eza -T -L 3 --icons'
alias lt4='eza -T -L 4 --icons'

# 恢复系统原生 ls（以防万一）
# alias lsb='/bin/ls'


alias npm='pnpm'
# PNPM
alias pi="pnpm install"
alias pa="pnpm add"
alias prd="pnpm run dev"
alias prp="pnpm run preview"
alias prb="pnpm run biome"

alias wattage="system_profiler SPPowerDataType | grep Wattage -C 5"
# Git
alias gbso="git branch show origin"
alias gbvv="git branch -vv"
alias gbuo="git branch update origin"
alias grpo="git remote prune origin"

# uv alias
alias ur="uv run python"
alias ua="uv add"
alias us="uv sync"
alias uvp="uv pip"


# 
alias c="clear"

# 工具 & 快捷
alias y="yazi"
alias t="history | tail -100"
alias loginaliyun='ssh -i ~/.ssh/aliyun_rsa root@121.41.102.247'



### <<<< alias config end <<<<<

# >>>> p10k configure start >>>>
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# <<<< p10k configure end <<<<

# pnpm
export PNPM_HOME="${HOME}/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# . "$HOME/.local/bin/env"
