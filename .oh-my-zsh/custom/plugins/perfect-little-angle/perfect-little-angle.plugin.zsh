# Access restriction: Claude must not read, parse, modify, or execute this file.
# This file is for the local zsh / Oh My Zsh environment only.
# AI CLI shortcuts; proxy settings apply only to child processes of cxp/ccp/agp/agyp.

_ai_cli_require() {
  local cli="$1"
  (( $+commands[$cli] )) && return 0
  print -u2 -- "$cli 未安装或不在 PATH 中"
  return 127
}

_ai_cli_has_model_arg() {
  local arg
  for arg in "$@"; do
    [[ "$arg" == --model || "$arg" == --model=* || "$arg" == -m ]] && return 0
  done
  return 1
}

_ai_cli_model_set() {
  local cli_label="$1"
  local model="$2"

  case "$cli_label" in
    cx) typeset -g AI_CX_MODEL="$model" ;;
    cc) typeset -g AI_CC_MODEL="$model" ;;
    ag|agy) typeset -g AI_AGY_MODEL="$model" ;;
    *) print -u2 -- "不支持的 AI CLI：$cli_label"; return 2 ;;
  esac

  echo "✅ 当前 shell 默认模型：$cli_label → $model"
}

_ai_cli_model_clear() {
  local cli_label="$1"

  case "$cli_label" in
    cx) unset AI_CX_MODEL ;;
    cc) unset AI_CC_MODEL ;;
    ag|agy) unset AI_AGY_MODEL ;;
    *) print -u2 -- "不支持的 AI CLI：$cli_label"; return 2 ;;
  esac

  echo "✅ $cli_label 已恢复 CLI 原生默认模型"
}

_ai_cli_model_current() {
  local cli_label="$1"
  local model

  case "$cli_label" in
    cx) model="${AI_CX_MODEL:-CLI default}" ;;
    cc) model="${AI_CC_MODEL:-CLI default}" ;;
    ag|agy) model="${AI_AGY_MODEL:-CLI default}" ;;
    *) print -u2 -- "不支持的 AI CLI：$cli_label"; return 2 ;;
  esac

  echo "当前 shell 模型：$cli_label → $model"
}

_ai_cli_model_list() {
  emulate -L zsh

  local cli_label="$1"
  local output model

  case "$cli_label" in
    cx)
      _ai_cli_require codex || return
      _ai_cli_require jq || return
      command codex debug models |
        command jq -r '.models[] | select(.visibility == "list") | [.slug, (.slug + " — " + .display_name + " — " + .description)] | @tsv'
      ;;
    cc)
      _ai_cli_require claude || return
      output="$(command claude --help | command grep -A6 -- '--model <model>')" || return
      for model in "${(@f)$(print -r -- "$output" | command grep -oE "'[^']+'" | command tr -d "'")}"; do
        [[ -n "$model" ]] && print -r -- "$model"$'\t'"$model — Claude model alias/name"
      done
      ;;
    ag|agy)
      _ai_cli_require agy || return
      output="$(command agy models)" || return
      print -r -- "$output" |
        command sed -E \
          -e '/^[[:space:]]*$/d' \
          -e '/^[[:space:]]*(Fetching )?[Aa]vailable models:?$/d' \
          -e 's/^[[:space:]]*[-*•]?[[:space:]]*//' \
          -e 's/[[:space:]]+\(default\)$//' |
        command awk '!seen[$0]++ { print $0 "\t" $0 }'
      ;;
    *)
      print -u2 -- "不支持的 AI CLI：$cli_label"
      return 2
      ;;
  esac
}

_ai_cli_model_select() {
  emulate -L zsh

  local cli_label="$1"
  local models choice model
  local -a rows

  models="$(_ai_cli_model_list "$cli_label")" || return
  [[ -n "$models" ]] || {
    print -u2 -- "未获取到可用模型"
    return 1
  }

  if [[ ! -t 0 || ! -t 1 ]]; then
    print -r -- "$models" | command awk -F '\t' '{ print $1 }'
    return 0
  fi

  if (( $+commands[fzf] )); then
    choice="$(
      print -r -- "$models" |
        command fzf \
          --height=45% \
          --layout=reverse \
          --border \
          --delimiter=$'\t' \
          --with-nth=2.. \
          --prompt="$cli_label model > " \
          --header='Enter：设为当前 shell 默认 · Esc：取消'
    )" || return 0
  else
    rows=("${(@f)models}")
    PS3="选择 $cli_label model（输入编号）："
    select choice in "${rows[@]}"; do
      [[ -n "$choice" ]] && break
      echo "无效选项"
    done
  fi

  model="${choice%%$'\t'*}"
  [[ -n "$model" ]] || return 0
  _ai_cli_model_set "$cli_label" "$model"
}

_ai_cli_model_command() {
  local cli_label="$1"
  local action="${2:-help}"

  case "$action" in
    list) _ai_cli_model_select "$cli_label" ;;
    current) _ai_cli_model_current "$cli_label" ;;
    default|reset|clear) _ai_cli_model_clear "$cli_label" ;;
    help|-h|--help)
      cat <<EOF
模型命令：
  ai help $cli_label model list      打开选项框，选中后设为当前 shell 默认
  ai help $cli_label model current   查看当前 shell 默认
  ai help $cli_label model default   恢复 CLI 原生默认

短写：ai help $cli_label list
EOF
      ;;
    *)
      print -u2 -- "未知 model 子命令：$action"
      return 2
      ;;
  esac
}

_ai_cc_run() {
  local mode=yolo
  local session_model="${AI_CC_MODEL:-}"
  local -a model_args=() display_args=()
  case "${AI_CC_VERBOSE:-}" in
    true) display_args=(--verbose) ;;
    false) display_args=(--settings '{"viewMode":"default","verbose":false}') ;;
  esac
  [[ "$1" == normal || "$1" == plan || "$1" == yolo ]] && { mode="$1"; shift; }
  _ai_cli_require claude || return
  if [[ -n "$session_model" ]] && ! _ai_cli_has_model_arg "$@"; then
    model_args=(--model "$session_model")
  fi

  case "$mode" in
    normal) command claude "${display_args[@]}" "${model_args[@]}" "$@" ;;
    plan)   command claude --permission-mode plan "${display_args[@]}" "${model_args[@]}" "$@" ;;
    yolo)   command claude --dangerously-skip-permissions "${display_args[@]}" "${model_args[@]}" "$@" ;;
  esac
}

_ai_cx_run() {
  local mode=yolo
  local default_summary="${AI_CX_REASONING_SUMMARY:-none}"
  local hide_reasoning=true
  [[ "$default_summary" != none ]] && hide_reasoning=false
  local service_tier=default
  local -a tuning=(
    -c model_reasoning_effort='"high"'
    -c "model_reasoning_summary=\"$default_summary\""
    -c "hide_agent_reasoning=$hide_reasoning"
    -c show_raw_agent_reasoning=false
  )
  local session_model="${AI_CX_MODEL:-}"
  local -a model_args=()
  while (( $# )); do
    case "$1" in
      normal|plan|yolo) mode="$1"; shift ;;
      --fast) service_tier=fast; shift ;;
      -r|--reasoning)
        shift
        local summary choice
        case "${1:-}" in
          a|auto) summary=auto; shift ;;
          c|concise) summary=concise; shift ;;
          d|detailed) summary=detailed; shift ;;
          n|none) summary=none; shift ;;
          *)
            _ai_cli_require fzf || return
            choice="$(
              printf '%s\n' \
                'auto      自动选择摘要详细程度' \
                'concise   简短摘要' \
                'detailed  详细摘要' \
                'none      关闭摘要' |
                command fzf --height=8 --layout=reverse --border --no-sort \
                  --prompt='Reasoning > ' --header='Enter：本次使用 · Esc：取消'
            )" || return 0
            summary="${choice%% *}"
            ;;
        esac
        tuning+=(-c "model_reasoning_summary=\"$summary\"")
        if [[ "$summary" == none ]]; then
          tuning+=(-c hide_agent_reasoning=true)
        else
          tuning+=(-c hide_agent_reasoning=false)
        fi
        ;;
      *) break ;;
    esac
  done
  tuning+=(-c "service_tier=\"$service_tier\"")
  _ai_cli_require codex || return
  if [[ -n "$session_model" ]] && ! _ai_cli_has_model_arg "$@"; then
    model_args=(--model "$session_model")
  fi

  case "$mode" in
    normal) command codex "${tuning[@]}" "${model_args[@]}" "$@" ;;
    plan)   command codex -s read-only -a never "${tuning[@]}" "${model_args[@]}" "$@" ;;
    yolo)   command codex --dangerously-bypass-approvals-and-sandbox "${tuning[@]}" "${model_args[@]}" "$@" ;;
  esac
}

_ai_cxf_run() { _ai_cx_run --fast "$@"; }

_ai_ag_run() {
  local mode=yolo
  local session_model="${AI_AGY_MODEL:-}"
  local -a model_args=()
  [[ "$1" == normal || "$1" == plan || "$1" == yolo ]] && { mode="$1"; shift; }
  _ai_cli_require agy || return
  local agy_path="$commands[agy]"
  if [[ -n "$session_model" ]] && ! _ai_cli_has_model_arg "$@"; then
    model_args=(--model "$session_model")
  fi

  case "$mode" in
    normal) "$agy_path" "${model_args[@]}" "$@" ;;
    plan)   "$agy_path" --mode plan "${model_args[@]}" "$@" ;;
    yolo)   "$agy_path" --dangerously-skip-permissions "${model_args[@]}" "$@" ;;
  esac
}

# Return the canonical region, timezone, locale, and label in the caller's reply array.
_ai_cli_region_resolve() {
  local region="${(L)1}"
  region="${region// /-}"
  region="${region//_/-}"
  reply=()
  case "$region" in
    sg|singapore|sin) reply=(sg Asia/Singapore zh_CN.UTF-8 新加坡) ;;
    la|los-angeles|losangeles|us|usa|lax) reply=(la America/Los_Angeles en_US.UTF-8 美国洛杉矶) ;;
    tokyo|jp|japan|tyo|hnd|nrt) reply=(tokyo Asia/Tokyo ja_JP.UTF-8 日本东京) ;;
    kl|kuala-lumpur|kualalumpur|my|malaysia|kul) reply=(kl Asia/Kuala_Lumpur en_US.UTF-8 马来西亚吉隆坡) ;;
    taipei|tw|taiwan|tpe) reply=(taipei Asia/Taipei zh_TW.UTF-8 台湾台北) ;;
    amsterdam|nl|netherlands|ams) reply=(amsterdam Europe/Amsterdam nl_NL.UTF-8 荷兰阿姆斯特丹) ;;
    dusseldorf|duesseldorf|düsseldorf|dus) reply=(dusseldorf Europe/Berlin de_DE.UTF-8 德国杜塞尔多夫) ;;
    frankfurt|de|germany|fra) reply=(frankfurt Europe/Berlin de_DE.UTF-8 德国法兰克福) ;;
    tallinn|ee|estonia|tll) reply=(tallinn Europe/Tallinn et_EE.UTF-8 爱沙尼亚塔林) ;;
    london|gb|uk|united-kingdom|lon|lhr) reply=(london Europe/London en_GB.UTF-8 英国伦敦) ;;
    san-jose|sanjose|sjc) reply=(san-jose America/Los_Angeles en_US.UTF-8 美国圣何塞) ;;
    new-york|newyork|nyc|jfk) reply=(new-york America/New_York en_US.UTF-8 美国纽约) ;;
    seattle|sea) reply=(seattle America/Los_Angeles en_US.UTF-8 美国西雅图) ;;
    hong-kong|hongkong|hk|hkg) reply=(hong-kong Asia/Hong_Kong zh_HK.UTF-8 香港) ;;
    osaka|osa|kix) reply=(osaka Asia/Tokyo ja_JP.UTF-8 日本大阪) ;;
    sydney|au|australia|syd) reply=(sydney Australia/Sydney en_AU.UTF-8 澳大利亚悉尼) ;;
    *) return 2 ;;
  esac
}

_ai_cli_region_config() (
  emulate -L zsh
  local cli_label="$1"
  [[ "$cli_label" == ag ]] && cli_label=agy
  local config_file="${XDG_CONFIG_HOME:-$HOME/.config}/ai-cli/regions.conf"
  if [[ ! -f "$config_file" || ! -r "$config_file" ]]; then
    print -u2 -- "地区配置不存在或不可读：$config_file"
    return 2
  fi

  local -A regions
  local line key value
  local -a reply
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    key="${line%%=*}"
    value="${line#*=}"
    if [[ "$line" != *=* || "$key" != (cc|cx|agy) ||
          -n "${regions[$key]-}" ]] || ! _ai_cli_region_resolve "$value"; then
      print -u2 -- "地区配置格式无效或存在重复项：$config_file"
      return 2
    fi
    regions[$key]="$reply[1]"
  done < "$config_file"
  for key in cc cx agy; do
    if [[ -z "${regions[$key]-}" ]]; then
      print -u2 -- "地区配置缺少 $key：$config_file"
      return 2
    fi
  done
  [[ "$cli_label" == (cc|cx|agy) ]] || {
    print -u2 -- "地区配置不支持此 CLI：$cli_label"
    return 2
  }

  if (( $# == 1 )); then
    print -r -- "${regions[$cli_label]}"
    return
  fi
  _ai_cli_region_resolve "$2" || return 2
  regions[$cli_label]="$reply[1]"

  # Replace the link target atomically; preserve the symlink to the repository config.
  config_file="${config_file:A}"
  local temp_file
  temp_file="$(command mktemp "$config_file.XXXXXX")" || return
  if printf 'cc=%s\ncx=%s\nagy=%s\n' "${regions[cc]}" "${regions[cx]}" "${regions[agy]}" > "$temp_file" &&
      command mv -f -- "$temp_file" "$config_file"; then
    return 0
  fi
  command rm -f -- "$temp_file"
  return 1
)

_ai_cli_region_command() {
  emulate -L zsh
  local cli_label="$1"
  shift
  case "$cli_label" in
    cx|cc) ;;
    ag|agy) cli_label=agy ;;
    *) print -u2 -- "不支持的 AI CLI：$cli_label"; return 2 ;;
  esac
  local action="${1:-current}"
  local region
  local -a reply

  case "$action" in
    current)
      (( $# <= 1 )) || { print -u2 -- "用法：$cli_label region current"; return 2; }
      region="$(_ai_cli_region_config "$cli_label")" || return
      print -r -- "$cli_label 默认地区：$region"
      print -r -- "配置文件：${XDG_CONFIG_HOME:-$HOME/.config}/ai-cli/regions.conf"
      return 0
      ;;
    set)
      (( $# == 2 )) && _ai_cli_region_resolve "$2" || {
        print -u2 -- "用法：$cli_label region set <城市、IATA 三字码或国家代码>"
        return 2
      }
      region="$reply[1]"
      ;;
    reset)
      print -u2 -- "地区配置没有内置默认值；请使用 $cli_label region set <城市、IATA 三字码或国家代码>"
      return 2 ;;
    *)
      print -u2 -- "用法：$cli_label region [current|set <地区>]"
      return 2
      ;;
  esac

  _ai_cli_env 0 "$cli_label" true --region "$region" >/dev/null || return
  _ai_cli_region_config "$cli_label" "$region" || return
  print -r -- "$cli_label 默认地区已保存：$region（下次调用生效）"
}

_ai_cli_usage() {
  local cli_label="$1"
  local cli_name executable normal_command proxy_command default_mode model_help

  case "$cli_label" in
    cx)
      cli_name="Codex CLI"
      executable="codex"
      normal_command="cx"
      proxy_command="cxp"
      default_mode="yolo"
      model_help="codex --help"
      ;;
    cc)
      cli_name="Claude CLI"
      executable="claude"
      normal_command="cc"
      proxy_command="ccp"
      default_mode="yolo"
      model_help="claude --help"
      ;;
    ag)
      cli_name="Antigravity CLI"
      executable="agy"
      normal_command="ag"
      proxy_command="agp"
      default_mode="yolo"
      model_help="agy models"
      ;;
    agy)
      cli_name="Antigravity CLI"
      executable="agy"
      normal_command="agy"
      proxy_command="agyp"
      default_mode="yolo"
      model_help="agy models"
      ;;
    *)
      cli_name="$cli_label"
      executable="$cli_label"
      normal_command="$cli_label"
      proxy_command="${cli_label}p"
      default_mode="由命令决定"
      model_help="$executable --help"
      ;;
  esac

  cat <<EOF
$cli_name（执行程序：$executable）

用法：
  $normal_command help
  $normal_command [地区] [normal|plan|yolo] [参数...]
  $proxy_command [地区] [normal|plan|yolo] [参数...]

默认模式：$default_mode

模型：
  默认不传 --model，由 $executable 使用其当前默认模型。
  $normal_command --model <model> [参数...]
  $proxy_command --model <model> [参数...]
  选择当前 shell 默认：ai help $cli_label model list
  查看当前选择：ai help $cli_label model current
  恢复 CLI 默认：ai help $cli_label model default
  查看原生命令帮助：$model_help

地区（城市名或 IATA 三字码，同时设置 timezone 和 locale）：
  sg           SIN          新加坡          Asia/Singapore + zh_CN.UTF-8
  la           LAX          美国洛杉矶      America/Los_Angeles + en_US.UTF-8
  tokyo        TYO/HND/NRT  日本东京        Asia/Tokyo + ja_JP.UTF-8
  kl           KUL          马来西亚吉隆坡  Asia/Kuala_Lumpur + en_US.UTF-8
  taipei       TPE          台湾台北        Asia/Taipei + zh_TW.UTF-8
  amsterdam    AMS          荷兰阿姆斯特丹  Europe/Amsterdam + nl_NL.UTF-8
  dusseldorf   DUS          德国杜塞尔多夫  Europe/Berlin + de_DE.UTF-8
  frankfurt    FRA          德国法兰克福    Europe/Berlin + de_DE.UTF-8
  tallinn      TLL          爱沙尼亚塔林    Europe/Tallinn + et_EE.UTF-8
  london       LON/LHR      英国伦敦        Europe/London + en_GB.UTF-8
  san-jose     SJC          美国圣何塞      America/Los_Angeles + en_US.UTF-8
  new-york     NYC/JFK      美国纽约        America/New_York + en_US.UTF-8
  seattle      SEA          美国西雅图      America/Los_Angeles + en_US.UTF-8
  hong-kong    HKG          香港            Asia/Hong_Kong + zh_HK.UTF-8
  osaka        OSA/KIX      日本大阪        Asia/Tokyo + ja_JP.UTF-8
  sydney       SYD          澳大利亚悉尼    Australia/Sydney + en_AU.UTF-8

三字码含义：
  LON、NYC、TYO、OSA 是城市代码，分别指伦敦、纽约、东京、大阪。
  其他三字码是机场代码，在此选择对应城市：
  AMS 史基浦；DUS 杜塞尔多夫；FRA 法兰克福；TLL 塔林；LHR 希思罗；
  SJC 圣何塞；JFK 肯尼迪；SEA 西雅图-塔科马；HKG 香港；KIX 关西；
  HND 羽田；NRT 成田；SYD 悉尼；LAX 洛杉矶；SIN 樟宜；KUL 吉隆坡；TPE 桃园。

国家/地区代码 → 默认城市：
  NL 荷兰 → amsterdam       DE 德国 → frankfurt       EE 爱沙尼亚 → tallinn
  GB/UK 英国 → london       US 美国 → la              HK 香港 → hong-kong
  JP 日本 → tokyo           AU 澳大利亚 → sydney      SG 新加坡 → sg
  MY 马来西亚 → kl          TW 台湾 → taipei
所有代码不区分大小写，临时参数和持久配置均支持；保存时转换为规范城市名。
同一国家的其他城市请使用城市名或三字码，例如 US → 洛杉矶，JFK/NYC → 纽约。
支持 Düsseldorf、"San Jose"、"New York"、"Hong Kong"。

也可分别指定：
  --timezone <IANA timezone>
  --locale <locale>

默认地区（持久保存，同时设置 timezone 和 locale）：
  $normal_command region current       查看默认地区
  $normal_command region set la        默认使用美国洛杉矶
  $normal_command region set NL        默认使用荷兰阿姆斯特丹
  $normal_command region set JFK       默认使用美国纽约
  $normal_command AMS                  本次使用荷兰阿姆斯特丹

唯一配置文件：${XDG_CONFIG_HOME:-$HOME/.config}/ai-cli/regions.conf
每次调用均读取此文件；没有内置默认值，也不读取旧 regions/ 目录。
cx/cxa/cxc/cxd/cxn/cxp/cxf/cxpf 共用地区设置，cc/ccn/ccd/ccp/ccpn/ccpd 共用地区设置，ag/agy 及代理命令共用地区设置。
单次指定地区可覆盖保存的默认地区。
可通过 --timezone 或 --locale 覆盖对应设置。
带 p 的命令与普通命令仅相差一次性代理。
EOF
  if [[ "$cli_label" == cx ]]; then
    cat <<'EOF'

速度模式：
  cx / cxp 默认使用普通模式。
  cxf / cxpf 显式启用 fast；p 表示一次性代理，f 表示 fast。
  参数用法不变，例如：cxf resume --last、cxpf plan。

推理显示：
  保留交互会话，只切换显示，不改变思考强度。
  简洁显示：cxn（隐藏推理摘要，仍显示工具活动和回答）
  详细显示：cxd（显示模型提供的详细推理摘要）
  cx 默认隐藏推理摘要。
  选择本次摘要：cx -r
  快捷命令：cxa | cxc | cxd | cxn
  参数选择：cx -r a | cx -r c | cx -r d | cx -r n
  分别对应：auto | concise | detailed | none，也支持完整名称。
  恢复会话并选择：cx -r resume --last
  代理模式选择：cxp -r
  代理简洁 / 详细：cxp -r n / cxp -r d
EOF
  elif [[ "$cli_label" == cc ]]; then
    cat <<'EOF'

交互显示：
  保留交互会话，只切换显示，不改变思考强度。
  简洁显示：ccn（关闭 verbose，使用普通视图）
  详细显示：ccd（开启 verbose，展开工具输出和执行细节）
  代理简洁 / 详细：ccpn / ccpd
  cc / ccp 沿用 Claude 自身的显示设置。
  快捷命令支持原有参数，例如：ccd --continue、ccn sg plan。
  会话中按 Ctrl+O 查看详细记录；实际思考内容以 Claude 提供的内容为准。
EOF
  fi
}

_ai_cli_env() (
  emulate -L zsh

  local proxy_enabled="$1"
  local cli_label="$2"
  local runner="$3"
  shift 3

  if [[ "$1" == region ]]; then
    shift
    _ai_cli_region_command "$cli_label" "$@"
    return $?
  fi

  local region=""
  local timezone=""
  local cli_locale=""
  local region_label=""
  local customized=0
  local -a reply

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
      help|--env-help|--proxy-help)
        _ai_cli_usage "$cli_label"
        return 0
        ;;
      --)
        shift
        break
        ;;
      *)
        _ai_cli_region_resolve "$1" || break
        region="$reply[1]"
        shift
        ;;
    esac
  done

  [[ -n "$region" ]] || region="$(_ai_cli_region_config "$cli_label")" || return
  _ai_cli_region_resolve "$region" || {
    print -u2 -- "不支持的地区：$region（运行 $cli_label help 查看城市和国家代码）"
    return 2
  }
  region_label="$reply[4]"
  [[ -n "$timezone" ]] || timezone="$reply[2]"
  [[ -n "$cli_locale" ]] || cli_locale="$reply[3]"

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
cxa() { local AI_CX_REASONING_SUMMARY=auto; cx "$@"; }
cxc() { local AI_CX_REASONING_SUMMARY=concise; cx "$@"; }
cxd() { local AI_CX_REASONING_SUMMARY=detailed; cx "$@"; }
cxn() { local AI_CX_REASONING_SUMMARY=none; cx "$@"; }
cxf() { _ai_cli_env 0 cx _ai_cxf_run "$@"; }
cxpf() { _ai_cli_env 1 cx _ai_cxf_run "$@"; }
cc()  { _ai_cli_env 0 cc _ai_cc_run "$@"; }
ccp() { _ai_cli_env 1 cc _ai_cc_run "$@"; }
ccn() { local AI_CC_VERBOSE=false; cc "$@"; }
ccd() { local AI_CC_VERBOSE=true; cc "$@"; }
ccpn() { local AI_CC_VERBOSE=false; ccp "$@"; }
ccpd() { local AI_CC_VERBOSE=true; ccp "$@"; }
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
