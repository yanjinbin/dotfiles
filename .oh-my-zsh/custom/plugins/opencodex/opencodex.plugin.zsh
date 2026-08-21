# OpenCodex Oh My Zsh plugin.
#
# Enables lowercase, case-insensitive service switches and client shortcuts:
#   ocx on|off|pause|status|start|stop|restart|init|install|log
#   ocx service repair
#   ocx client export <client>
#
# Other ocx commands are passed through to the original OpenCodex CLI.

export OCX_PACKAGE_NAME="${OCX_PACKAGE_NAME:-@bitkyc08/opencodex}"
export OCX_HOME="${OCX_HOME:-$HOME/.opencodex}"
export OCX_NOHUP_LOG="${OCX_NOHUP_LOG:-$OCX_HOME/nohup.log}"
export OCX_NOHUP_PID="${OCX_NOHUP_PID:-$OCX_HOME/nohup.pid}"

_opencodex_has_cmd() {
  (( $+commands[ocx] ))
}

_opencodex_install_if_missing() {
  if _opencodex_has_cmd; then
    return 0
  fi

  if ! (( $+commands[npm] )); then
    echo "未找到 npm，无法安装 $OCX_PACKAGE_NAME"
    return 127
  fi

  echo "未找到 ocx，开始安装 $OCX_PACKAGE_NAME ..."
  command npm install -g "$OCX_PACKAGE_NAME" || return
  rehash
}

_opencodex_is_running() {
  _opencodex_has_cmd && command ocx health --json >/dev/null 2>&1
}

_opencodex_usage() {
  cat <<EOF
用法：
  ocx install              安装/升级 $OCX_PACKAGE_NAME
  ocx init                 交互初始化，写入 ~/.opencodex/config.json
  ocx on [ocx start 参数]  用 nohup 后台启动 ocx start
  ocx start [参数]         同 ocx on
  ocx off                  停止 ocx，并恢复原生 Codex
  ocx stop                 同 ocx off
  ocx pause                同 ocx off，保留配置
  ocx restart              重启 nohup 后台进程
  ocx status               查看状态
  ocx log                  跟随 nohup 日志
  ocx client export <名称>  导出客户端配置，等同于 ocx export --client <名称>
  ocx client <参数>         转发到 ocx integration client <参数>
  ocx service-on           使用 ocx 内置后台服务安装/启动
  ocx service-off          停止 ocx 内置后台服务
  ocx service-status       查看 ocx 内置后台服务状态
  ocx service repair       调用原生 ocx service repair

说明：
  子命令大小写不敏感，例如 ocx On 等同于 ocx on。
  未列出的子命令会转发给原始 ocx CLI。
EOF
}

_opencodex_ctl() {
  local action="${1:-status}"
  shift || true
  action="${(L)action}"

  case "$action" in
    install|update|upgrade)
      if ! (( $+commands[npm] )); then
        echo "未找到 npm"
        return 127
      fi
      command npm install -g "$OCX_PACKAGE_NAME"
      rehash
      ;;

    init|setup)
      _opencodex_install_if_missing || return
      command ocx init "$@"
      ;;

    on|start)
      _opencodex_install_if_missing || return
      mkdir -p "$OCX_HOME"
      local ocx_bin="$commands[ocx]"

      if _opencodex_is_running; then
        echo "ocx 已在运行。"
        command ocx status
        return 0
      fi

      echo "用 nohup 后台启动：ocx start $*"
      nohup "$ocx_bin" start "$@" >> "$OCX_NOHUP_LOG" 2>&1 < /dev/null &
      local ocx_pid=$!
      echo "$ocx_pid" >| "$OCX_NOHUP_PID"
      disown

      sleep 1
      if command ocx ready --wait --timeout 10; then
        echo
        echo "ocx 已后台运行。PID: $ocx_pid"
        echo "日志: $OCX_NOHUP_LOG"
      else
        echo "ocx 后台启动命令已发出，但暂未 ready。"
        echo "PID: $ocx_pid"
        echo "日志: $OCX_NOHUP_LOG"
        return 1
      fi
      ;;

    off|stop|pause)
      if _opencodex_has_cmd; then
        command ocx stop "$@"
      elif [[ -s "$OCX_NOHUP_PID" ]]; then
        local ocx_pid
        ocx_pid="$(<"$OCX_NOHUP_PID")"
        if [[ -n "$ocx_pid" ]] && kill -0 "$ocx_pid" 2>/dev/null; then
          kill "$ocx_pid"
          echo "已停止 nohup PID: $ocx_pid"
        else
          echo "ocx nohup PID 不存在或已退出。"
        fi
      else
        echo "未找到 ocx，也没有 nohup PID 文件。"
        return 127
      fi
      ;;

    restart)
      _opencodex_ctl off
      sleep 1
      _opencodex_ctl on "$@"
      ;;

    status)
      _opencodex_install_if_missing || return
      command ocx status "$@"
      if [[ -s "$OCX_NOHUP_PID" ]]; then
        local ocx_pid
        ocx_pid="$(<"$OCX_NOHUP_PID")"
        if [[ -n "$ocx_pid" ]] && kill -0 "$ocx_pid" 2>/dev/null; then
          echo "Nohup PID: $ocx_pid"
        fi
      fi
      echo "Nohup log: $OCX_NOHUP_LOG"
      ;;

    log|logs)
      mkdir -p "$OCX_HOME"
      touch "$OCX_NOHUP_LOG"
      tail -f "$OCX_NOHUP_LOG"
      ;;

    client|clients)
      _opencodex_install_if_missing || return
      local client_action="${1:-help}"
      shift || true
      client_action="${(L)client_action}"

      case "$client_action" in
        export|config)
          local client_name="$1"
          shift || true
          if [[ -z "$client_name" ]]; then
            echo "用法：ocx client export <opencode|pi|omp|hermes|openclaw|kimi|gajae|dsh|mcode|zcode|prime> [--json] [--out <path>] [--force]"
            return 2
          fi
          command ocx export --client "$client_name" "$@"
          ;;
        help|-h|--help)
          command ocx integration client --help
          echo
          command ocx export --help
          ;;
        *)
          command ocx integration client "$client_action" "$@"
          ;;
      esac
      ;;

    service)
      _opencodex_install_if_missing || return
      local service_action="${1:-}"
      shift || true
      service_action="${(L)service_action}"

      case "$service_action" in
        ""|on|start|install|repair|restart)
          if [[ -n "$service_action" ]]; then
            command ocx service "$service_action" "$@"
          else
            command ocx service "$@"
          fi
          ;;
        off|stop)
          command ocx service stop "$@"
          ;;
        status)
          command ocx service status "$@"
          ;;
        uninstall|remove)
          command ocx service "$service_action" "$@"
          ;;
        *)
          command ocx service "$service_action" "$@"
          ;;
      esac
      ;;

    service-on|daemon-on)
      _opencodex_install_if_missing || return
      command ocx service "$@"
      ;;

    service-off|daemon-off)
      _opencodex_install_if_missing || return
      command ocx service stop "$@"
      ;;

    service-status|daemon-status)
      _opencodex_install_if_missing || return
      command ocx service status "$@"
      ;;

    help|-h|--help)
      _opencodex_usage
      ;;

    *)
      return 64
      ;;
  esac
}

ocx() {
  if [[ $# -gt 0 ]]; then
    _opencodex_ctl "$@"
    local rc=$?
    if [[ $rc -ne 64 ]]; then
      return $rc
    fi
  fi

  command ocx "$@"
}

alias ocxon='ocx on'
alias ocxoff='ocx off'
alias ocxstatus='ocx status'
alias ocxrestart='ocx restart'
alias ocxlog='ocx log'
