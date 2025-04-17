# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="af-magic"
ZSH_THEME="agnoster"
# ZSH_THEME="powerlevel10k/powerlevel10k"
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
# Custom plugins may be added to $ZSH_CUSTOM/plug ins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git pnpm docker-compose z fzf-tab zsh-autosuggestions you-should-use zsh-syntax-highlighting )
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# ================ Zinit 插件管理器 =================
# 如果没有安装 Zinit 插件管理器，则进行安装
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} 正在安装 Zinit 插件管理器... %f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
    print -P "%F{34} 安装成功。%f"
fi
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"  # 加载 Zinit
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit  # 启用补全功能

# ===================== 路径配置 =====================

# Homebrew 路径
export HOMEBREW_PATH='/opt/homebrew/bin/'
export PATH="$HOMEBREW_PATH:$PATH"  # 将 Homebrew 路径添加到系统 PATH 中


 export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# PNPM 路径
export PNPM_HOME="/Users/yanjinbin/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"  # 将 PNPM 路径添加到系统 PATH 中


# Maven 路径
export MAVEN_HOME="${HOME}/apache-maven-3.6.3"
export PATH="$MAVEN_HOME/bin:$PATH"  # 将 Maven 路径添加到系统 PATH 中

# Go 环境配置
export GO111MODULE=on  # 启用 Go Modules
# export GOPROXY=https://mirrors.aliyun.com/goproxy/,direct  # 设置 Go 代理
export GOPATH="${HOME}/GolandProjects"  # 设置 Go 工作空间路径
export GOBIN="${GOPATH}/bin"  # 设置 Go 可执行文件路径
export PATH="$PATH:$GOBIN"  # 将 Go 可执行文件路径添加到系统 PATH 中

# Docker 路径
export DOCKER_PATH="/Applications/Docker.app/Contents/Resources/bin"
export PATH="$DOCKER_PATH:$PATH"  # 将 Docker 路径添加到系统 PATH 中

# Python 环境配置
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"  # 将 Pyenv 路径添加到系统 PATH 中
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"  # 初始化 pyenv
fi

# RVM 环境配置（Ruby 版本管理）
export PATH="$PATH:$HOME/.rvm/bin"  # 将 RVM 路径添加到系统 PATH 中

# 环境变量设置（ElasticSearch 和 API Key）
export ES_URL="localhost:9200"
export API_KEY="aTl3am5vNEJRai1jV3ZhSUlJTXE6LUF1M1RkbDlRMHlBQU9RVF9zVE9aZw=="

# ===================== 常用别名 =====================

# PNPM 命令别名
alias pi="pnpm install"  # 安装依赖
alias pa="pnpm add"  # 添加依赖
alias prd="pnpm run dev"  # 启动开发环境
alias prb="pnpm run biome"  # 启动 Biome
alias prp="pnpm run preview"  # 启动预览


# Git 命令别名
alias gbso="git branch show origin"  # 显示远程分支
alias gbvv="git branch -vv"  # 显示分支信息
alias gbuo="git branch update origin"  # 更新远程分支
alias grpo="git remote prune origin"  # 清理远程分支

# 常用工具别名
alias y="yazi"  # 别名 yazi
alias t="history | tail -100"  # 查看最近 100 条命令

# SSH 连接到阿里云服务器
alias loginaliyun='ssh -i ~/.ssh/aliyun_rsa root@121.41.102.247'

alias  proxyon='export https_proxy="http://127.0.0.1:7890" http_proxy="http://127.0.0.1:7890" all_proxy="socks5://127.0.0.1:7890"'
alias proxyoff='unset https_proxy http_proxy all_proxy'

# ===================== 其他工具配置 =====================

# Racket 路径配置
RacketHomePath="/Applications/Racket v8.12/bin"
export PATH="$RacketHomePath:$PATH"  # 将 Racket 路径添加到系统 PATH 中


# JetBrains VMOptions 配置
___MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"
if [ -f "${___MY_VMOPTIONS_SHELL_FILE}" ]; then
    . "${___MY_VMOPTIONS_SHELL_FILE}"
fi

# 主题配置（如果存在）
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ===================== 自定义命令 =====================

# 通过 Google 搜索的别名
function google() {
    open -na "Google Chrome" --args "https://www.google.com/search?q=$*"
}

# C++ 编译和运行的函数
function compilecpp() {
    g++ "$1".cpp -o "$1" && ./$1
}

# ===================== 特定工具 =====================

# 安装和激活 Mise 环境
eval "$(~/.local/bin/mise activate zsh)"




# ===================== 结束 =====================

# pnpm
export PNPM_HOME="/Users/yanjinbin/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


querypid() {
  # 验证端口号是否有效
  local port=$1
  if [[ ! "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
    echo "⚠️ 无效的端口号: $port"
    return 1
  fi

  # 使用 lsof 查询指定端口的进程
  pid=$(lsof -ti :$port 2>/dev/null)

  # 如果没有返回结果，说明没有进程监听该端口
  if [ -z "$pid" ]; then
    echo "⚠️ 没有进程监听端口 $port"
    return 2
  fi

  # 返回 PID
  echo "$pid"
}

# 用于终止指定进程 PID 的函数
killpid() {
  local pid=$1
  if [ -z "$pid" ]; then
    echo "⚠️ 没有提供 PID，无法终止进程"
    return 1
  fi

  echo "🔴 正在终止进程 PID: $pid"
  kill -9 "$pid" 2>/dev/null

  if [ $? -eq 0 ]; then
    echo "✅ 进程 $pid 已终止"
  else
    echo "⚠️ 无法终止进程 $pid"
    return 2
  fi
}
#!/bin/bash

# 查询指定端口的进程 PID
querypid() {
  local port=$1

  # 验证端口号是否有效
  if [[ ! "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
    echo "⚠️ 无效的端口号: $port"
    return 1
  fi

  # 使用 lsof 查询指定端口的进程
  pid=$(lsof -ti :$port 2>/dev/null)

  # 如果没有返回结果，说明没有进程监听该端口
  if [ -z "$pid" ]; then
    echo "⚠️ 没有进程监听端口 $port"
    return 2
  fi

  # 返回 PID
  echo "$pid"
}

# 终止指定进程 PID
killpid() {
  local pid=$1

  if [ -z "$pid" ]; then
    echo "⚠️ 没有提供 PID，无法终止进程"
    return 1
  fi

  echo "🔴 正在终止进程 PID: $pid"
  kill -SIGTERM "$pid" 2>/dev/null

  if [ $? -eq 0 ]; then
    echo "✅ 进程 $pid 已终止"
  else
    echo "⚠️ 无法终止进程 $pid"
    return 2
  fi
}

# 根据端口号查询并终止占用该端口的进程
terminate_process_by_port() {
  local port=$1

  # 查询 PID
  pid=$(querypid "$port")

  # 如果 querypid 返回错误，则终止处理
  if [ $? -ne 0 ]; then
    return $?
  fi

  # 终止该进程
  killpid "$pid"
}

# 示例：根据端口号终止进程
terminate_process_by_port 9003
