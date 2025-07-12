##### Powerlevel10k Instant Prompt #####
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

##### 基本配置 #####
export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME="agnoster"
ZSH_THEME="powerlevel10k/powerlevel10k"
ENABLE_CORRECTION="true"

##### 插件配置 #####
plugins=(
  git
  pnpm
  docker-compose
  z
  zsh-syntax-highlighting
  you-should-use
  fzf-tab
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

##### Zinit 插件管理器 #####
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  print -P "%F{33} 正在安装 Zinit 插件管理器... %f"
  command mkdir -p "$HOME/.local/share/zinit" && chmod g-rwX "$HOME/.local/share/zinit"
  git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
  print -P "%F{34} 安装成功。%f"
fi
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit && (( ${+_comps} )) && _comps[zinit]=_zinit

##### 环境变量与路径配置 #####
# Homebrew
export HOMEBREW_PATH="/opt/homebrew/bin"
export PATH="$HOMEBREW_PATH:$PATH"

# PNPM
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Maven
export MAVEN_HOME="$HOME/apache-maven-3.6.3"
export PATH="$MAVEN_HOME/bin:$PATH"

# Go
export GO111MODULE=on
export GOPROXY="https://mirrors.aliyun.com/goproxy/,direct"
export GOPATH="$HOME/GolandProjects"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOBIN"

# Docker
export DOCKER_PATH="/Applications/Docker.app/Contents/Resources/bin"
export PATH="$DOCKER_PATH:$PATH"

# Python (pyenv)
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Ruby (rbenv)
eval "$(rbenv init - --no-rehash zsh)"

# Racket
export PATH="/Applications/Racket v8.12/bin:$PATH"

# Mise 版本管理工具
eval "$($HOME/.local/bin/mise activate zsh)"

##### Proxy 切换 #####
alias proxyon='export https_proxy="http://127.0.0.1:7890" http_proxy="http://127.0.0.1:7890" all_proxy="socks5://127.0.0.1:7890"'
alias proxyoff='unset https_proxy http_proxy all_proxy'

##### 常用别名 #####
# PNPM
alias pi="pnpm install"
alias pa="pnpm add"
alias prd="pnpm run dev"
alias prp="pnpm run preview"
alias prb="pnpm run biome"

# Git
alias gbso="git branch show origin"
alias gbvv="git branch -vv"
alias gbuo="git branch update origin"
alias grpo="git remote prune origin"

# 工具 & 快捷
alias y="yazi"
alias t="history | tail -100"
alias loginaliyun='ssh -i ~/.ssh/aliyun_rsa root@121.41.102.247'

##### Prompt 配置 #####
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
