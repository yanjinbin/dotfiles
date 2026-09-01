# ⚠️ 访问限制：禁止 Claude 读取、解析、修改或执行本文件。
# 本文件仅供本机 zsh / Oh My Zsh 加载使用。
# AI CLI 快捷命令；代理只对 cxp/ccp/agp 的子进程生效。

_ai_cli_require() {
  local cli="$1"
  (( $+commands[$cli] )) && return 0
  print -u2 -- "$cli 未安装或不在 PATH 中"
  return 127
}

_ai_cc_run() {
  local mode=normal
  [[ "$1" == normal || "$1" == plan || "$1" == yolo ]] && { mode="$1"; shift; }
  _ai_cli_require claude || return

  case "$mode" in
    normal) command claude "$@" ;;
    plan)   command claude --permission-mode plan "$@" ;;
    yolo)   command claude --dangerously-skip-permissions "$@" ;;
  esac
}

_ai_cx_run() {
  local mode=yolo
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

_ai_ag_run() {
  local mode=yolo
  [[ "$1" == normal || "$1" == plan || "$1" == yolo ]] && { mode="$1"; shift; }
  _ai_cli_require agy || return
  local agy_path="$commands[agy]"

  case "$mode" in
    normal) "$agy_path" "$@" ;;
    plan)   "$agy_path" --mode plan "$@" ;;
    yolo)   "$agy_path" --dangerously-skip-permissions "$@" ;;
  esac
}

_ai_cli_usage() {
  local cli_label="$1"
  local cli_name executable normal_command proxy_command default_mode

  case "$cli_label" in
    cx)
      cli_name="Codex CLI"
      executable="codex"
      normal_command="cx"
      proxy_command="cxp"
      default_mode="yolo"
      ;;
    cc)
      cli_name="Claude CLI"
      executable="claude"
      normal_command="cc"
      proxy_command="ccp"
      default_mode="normal"
      ;;
    ag)
      cli_name="Antigravity CLI"
      executable="agy"
      normal_command="ag"
      proxy_command="agp"
      default_mode="yolo"
      ;;
    agy)
      cli_name="Antigravity CLI"
      executable="agy"
      normal_command="agy"
      proxy_command="agyp"
      default_mode="yolo"
      ;;
    *)
      cli_name="$cli_label"
      executable="$cli_label"
      normal_command="$cli_label"
      proxy_command="${cli_label}p"
      default_mode="由命令决定"
      ;;
  esac

  cat <<EOF
$cli_name（执行程序：$executable）

用法：
  $normal_command [地区] [normal|plan|yolo] [参数...]
  $proxy_command [地区] [normal|plan|yolo] [参数...]

默认模式：$default_mode

地区（可选，同时设置 timezone 和 locale）：
  la       美国洛杉矶      America/Los_Angeles + en_US.UTF-8
  tokyo    日本东京        Asia/Tokyo + ja_JP.UTF-8
  kl       马来西亚吉隆坡  Asia/Kuala_Lumpur + en_US.UTF-8
  taipei   台湾台北        Asia/Taipei + zh_TW.UTF-8

也可分别指定：
  --timezone <IANA timezone>
  --locale <locale>

不指定地区、timezone 或 locale 时，默认使用台湾台北。
带 p 的命令与普通命令仅相差一次性代理。
EOF
}

_ai_cli_env() (
  emulate -L zsh

  local proxy_enabled="$1"
  local cli_label="$2"
  local runner="$3"
  shift 3

  local region="taipei"
  local timezone=""
  local cli_locale=""
  local region_label="台湾台北（默认）"
  local customized=0

  while (( $# )); do
    case "$1" in
      --region)
        (( $# >= 2 )) || { print -u2 -- "--region 需要一个地区"; return 2; }
        region="$2"
        shift 2
        ;;
      --region=*)
        region="${1#*=}"
        shift
        ;;
      --timezone)
        (( $# >= 2 )) || { print -u2 -- "--timezone 需要一个 IANA timezone"; return 2; }
        timezone="$2"
        customized=1
        shift 2
        ;;
      --timezone=*)
        timezone="${1#*=}"
        customized=1
        shift
        ;;
      --locale)
        (( $# >= 2 )) || { print -u2 -- "--locale 需要一个 locale"; return 2; }
        cli_locale="$2"
        customized=1
        shift 2
        ;;
      --locale=*)
        cli_locale="${1#*=}"
        customized=1
        shift
        ;;
      --env-help|--proxy-help)
        _ai_cli_usage "$cli_label"
        return 0
        ;;
      --)
        shift
        break
        ;;
      la|los-angeles|losangeles|us|usa|tokyo|jp|japan|kl|kuala-lumpur|kualalumpur|my|malaysia|taipei|tw|taiwan)
        region="$1"
        shift
        ;;
      *)
        break
        ;;
    esac
  done

  case "$region" in
    "") ;;
    la|los-angeles|losangeles|us|usa)
      region_label="美国洛杉矶"
      [[ -n "$timezone" ]] || timezone="America/Los_Angeles"
      [[ -n "$cli_locale" ]] || cli_locale="en_US.UTF-8"
      ;;
    tokyo|jp|japan)
      region_label="日本东京"
      [[ -n "$timezone" ]] || timezone="Asia/Tokyo"
      [[ -n "$cli_locale" ]] || cli_locale="ja_JP.UTF-8"
      ;;
    kl|kuala-lumpur|kualalumpur|my|malaysia)
      region_label="马来西亚吉隆坡"
      [[ -n "$timezone" ]] || timezone="Asia/Kuala_Lumpur"
      [[ -n "$cli_locale" ]] || cli_locale="en_US.UTF-8"
      ;;
    taipei|tw|taiwan)
      region_label="台湾台北"
      [[ -n "$timezone" ]] || timezone="Asia/Taipei"
      [[ -n "$cli_locale" ]] || cli_locale="zh_TW.UTF-8"
      ;;
    *)
      print -u2 -- "不支持的地区：$region（可选：la、tokyo、kl、taipei）"
      return 2
      ;;
  esac

  (( customized )) && region_label="自定义"

  if [[ -n "$timezone" && ! -r "/usr/share/zoneinfo/$timezone" ]]; then
    print -u2 -- "无效的 timezone：$timezone"
    return 2
  fi
  if [[ -n "$cli_locale" ]] && ! command locale -a 2>/dev/null | command grep -Fqx -- "$cli_locale"; then
    print -u2 -- "本机不可用的 locale：$cli_locale"
    return 2
  fi

  [[ -n "$timezone" ]] && export TZ="$timezone"
  if [[ -n "$cli_locale" ]]; then
    export LANG="$cli_locale"
    export LC_ALL="$cli_locale"
  fi

  if (( proxy_enabled )); then
    export http_proxy="http://127.0.0.1:7890"
    export https_proxy="$http_proxy"
    export all_proxy="socks5h://127.0.0.1:7890"
    export HTTP_PROXY="$http_proxy"
    export HTTPS_PROXY="$https_proxy"
    export ALL_PROXY="$all_proxy"
    echo "🟢 AI Proxy ON → 127.0.0.1:7890（$cli_label）"
  fi

  echo "🌐 AI CLI ENV → Region=$region_label | Timezone=${TZ:-System Default} | Locale=${LC_ALL:-${LANG:-System Default}}"
  "$runner" "$@"
)

ai_env() {
  local cli="$1"
  shift
  if [[ "$cli" == agy ]]; then
    _ai_cli_env 0 agy _ai_ag_run "$@"
  else
    _ai_cli_env 0 "$cli" "$cli" "$@"
  fi
}

aip() {
  local cli="$1"
  shift
  if [[ "$cli" == agy ]]; then
    _ai_cli_env 1 agy _ai_ag_run "$@"
  else
    _ai_cli_env 1 "$cli" "$cli" "$@"
  fi
}

cx()  { _ai_cli_env 0 cx _ai_cx_run "$@"; }
cxp() { _ai_cli_env 1 cx _ai_cx_run "$@"; }
cc()  { _ai_cli_env 0 cc _ai_cc_run "$@"; }
ccp() { _ai_cli_env 1 cc _ai_cc_run "$@"; }
ag()  { _ai_cli_env 0 ag _ai_ag_run "$@"; }
agp() { _ai_cli_env 1 ag _ai_ag_run "$@"; }
agy()  { _ai_cli_env 0 agy _ai_ag_run "$@"; }
agyp() { _ai_cli_env 1 agy _ai_ag_run "$@"; }

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
