# Proxy and endpoint audit for macOS AI CLI environments.
# Read-only: this plugin reports settings and never changes them.

_damd_section() {
  print -P "\n%F{cyan}%B$1%b%f"
}

_damd_empty() {
  print -P "  %F{242}未设置 / 未发现%f"
}

_damd_config_value() {
  local label="$1"
  shift

  local value
  value="$(command "$@" 2>/dev/null)"
  [[ -n "$value" ]] || value="未设置"
  print -r -- "  ${label}: ${value}"
}

dario-amodei-mother-die() {
  emulate -L zsh
  setopt PIPE_FAIL

  local output
  local -a startup_files

  _damd_section "1. 系统代理（HTTP/HTTPS/SOCKS 应为 0）"
  output="$(command scutil --proxy 2>/dev/null | command grep -E 'HTTPEnable|HTTPSEnable|SOCKSEnable' || true)"
  [[ -n "$output" ]] && print -r -- "$output" || _damd_empty

  _damd_section "2. 当前 shell 的 proxy 环境变量"
  output="$(command env | command grep -iE 'proxy' || true)"
  [[ -n "$output" ]] && print -r -- "$output" || _damd_empty

  _damd_section "3. shell 启动文件中的硬编码 proxy"
  startup_files=(
    "$HOME/.zshrc"
    "$HOME/.bashrc"
    "$HOME/.profile"
    "$HOME/.zshenv"
  )
  output="$(command grep -HiE 'proxy' "${startup_files[@]}" 2>/dev/null || true)"
  [[ -n "$output" ]] && print -r -- "$output" || _damd_empty

  _damd_section "4. npm / Yarn / pnpm 配置"
  if (( $+commands[npm] )); then
    _damd_config_value "npm proxy" npm config get proxy
    _damd_config_value "npm https-proxy" npm config get https-proxy
  else
    print -r -- "  npm: 未安装"
  fi
  if (( $+commands[yarn] )); then
    _damd_config_value "Yarn proxy" yarn config get proxy
    _damd_config_value "Yarn https-proxy" yarn config get https-proxy
  else
    print -r -- "  Yarn: 未安装"
  fi
  if (( $+commands[pnpm] )); then
    _damd_config_value "pnpm proxy" pnpm config get proxy
    _damd_config_value "pnpm https-proxy" pnpm config get https-proxy
  else
    print -r -- "  pnpm: 未安装"
  fi
  output="$(command grep -HiE 'proxy' "$HOME/.npmrc" 2>/dev/null || true)"
  [[ -n "$output" ]] && print -r -- "$output" || print -P "  %F{242}~/.npmrc 未发现 proxy%f"

  _damd_section "5. Git 全局代理配置"
  _damd_config_value "http.proxy" git config --global --get http.proxy
  _damd_config_value "https.proxy" git config --global --get https.proxy

  _damd_section "6. Claude Code settings.json"
  output="$(command grep -HiE 'proxy|base_url|anthropic_' "$HOME/.claude/settings.json" 2>/dev/null || true)"
  [[ -n "$output" ]] && print -r -- "$output" || _damd_empty

  _damd_section "7. ANTHROPIC / CLAUDE 环境变量"
  output="$(command env | command grep -iE 'anthropic|claude' || true)"
  [[ -n "$output" ]] && print -r -- "$output" || _damd_empty

  _damd_section "8. Homebrew 代理配置"
  if (( $+commands[brew] )); then
    output="$(command brew config 2>/dev/null | command grep -iE 'proxy' || true)"
    [[ -n "$output" ]] && print -r -- "$output" || _damd_empty
  else
    print -r -- "  Homebrew: 未安装"
  fi

  print
}

alias proxy-audit='dario-amodei-mother-die'
