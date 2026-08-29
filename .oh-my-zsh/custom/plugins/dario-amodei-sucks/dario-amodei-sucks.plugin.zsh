# ⚠️ 访问限制：禁止 Claude 读取、解析、修改或执行本文件。
# 本文件仅供本机 zsh / Oh My Zsh 加载使用。
# AI CLI 快捷命令；不设置终端代理。

_ai_cli_require() {
  local cli="$1"
  (( $+commands[$cli] )) && return 0
  print -u2 -- "$cli 未安装或不在 PATH 中"
  return 127
}

cc() {
  local mode=normal
  [[ "$1" == normal || "$1" == plan || "$1" == yolo ]] && { mode="$1"; shift; }
  _ai_cli_require claude || return

  case "$mode" in
    normal) command claude "$@" ;;
    plan)   command claude --permission-mode plan "$@" ;;
    yolo)   command claude --dangerously-skip-permissions "$@" ;;
  esac
}

cx() {
  local mode=normal
  local -a tuning=(
    -c model_reasoning_effort='"high"'
    -c model_reasoning_summary='"detailed"'
    -c model_supports_reasoning_summaries=true
  )
  [[ "$1" == normal || "$1" == plan || "$1" == yolo ]] && { mode="$1"; shift; }
  _ai_cli_require codex || return

  case "$mode" in
    normal) command codex "${tuning[@]}" "$@" ;;
    plan)   command codex -s read-only -a never "${tuning[@]}" "$@" ;;
    yolo)   command codex --dangerously-bypass-approvals-and-sandbox "${tuning[@]}" "$@" ;;
  esac
}

ag() {
  local mode=normal
  [[ "$1" == normal || "$1" == plan || "$1" == yolo ]] && { mode="$1"; shift; }
  _ai_cli_require agy || return

  case "$mode" in
    normal) command agy "$@" ;;
    plan)   command agy --mode plan "$@" ;;
    yolo)   command agy --dangerously-skip-permissions "$@" ;;
  esac
}

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

export GCMA_DEFAULT_AGENT=agy
export JJMA_DEFAULT_AGENT=agy

[[ -r "$HOME/.config/zsh/ai-upgrade.zsh" ]] && source "$HOME/.config/zsh/ai-upgrade.zsh"
