# ==========================================================
# 🤖 AI CLI Upgrade
# 独立加载文件：~/.config/zsh/ai-upgrade.zsh
# ==========================================================

ai() {
  case "$1" in
    upgrade) shift; _ai_upgrade "$@" ;;
    *) echo "Usage: ai upgrade [claude|codex|agy|herdr|opencode] [all]" ;;
  esac
}

_ai_upgrade() {
  local targets=("$@")
  # 不指定目标时 = 升级整条 AI toolchain
  [[ ${#targets[@]} -eq 0 ]] && targets=(claude codex agy herdr opencode)

  local do_claude=0
  local do_codex=0
  local do_agy=0
  local do_herdr=0
  local do_opencode=0
  local target

  for target in "${targets[@]}"; do
    case "$target" in
      all) do_claude=1; do_codex=1; do_agy=1; do_herdr=1; do_opencode=1 ;;
      claude|c) do_claude=1 ;;
      codex|x) do_codex=1 ;;
      agy|antigravity|a) do_agy=1 ;;
      herdr|h) do_herdr=1 ;;
      opencode|op) do_opencode=1 ;;
      *)
        echo "Usage: ai upgrade [claude|codex|agy|herdr|opencode] [all]"
        return 2
        ;;
    esac
  done

  local RESET='\033[0m'
  local BOLD='\033[1m'
  local DIM='\033[2m'
  local GREEN='\033[38;5;120m'
  local RED='\033[38;5;203m'
  local YELLOW='\033[38;5;221m'

  _banner() {
    echo ""
    printf '\033[38;5;213m  ✦ \033[38;5;183mA\033[38;5;153mI\033[38;5;123m \033[38;5;120mC\033[38;5;121mL\033[38;5;122mI\033[38;5;148m \033[38;5;214mU\033[38;5;208mp\033[38;5;203md\033[38;5;204ma\033[38;5;205mt\033[38;5;206me\033[38;5;213m ✦\033[0m'
    echo ""
  }

  _spin() {
    local pid=$1 msg=$2
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local colors=('\033[38;5;213m' '\033[38;5;183m' '\033[38;5;153m' '\033[38;5;123m' '\033[38;5;120m')
    local i=0 c=0
    while kill -0 "$pid" 2>/dev/null; do
      printf "\r  ${colors[c]}${frames[i]}${RESET}  ${msg}"
      i=$(( (i+1) % ${#frames[@]} ))
      c=$(( (c+1) % ${#colors[@]} ))
      sleep 0.08
    done
  }

  _run() {
    local label=$1; shift
    local log
    log=$(mktemp)
    { "$@" >"$log" 2>&1; } &
    local pid=$!
    _spin $pid "$label"
    wait $pid
    local ok=$?
    if (( ok == 0 )); then
      printf "\r  ${GREEN}✔${RESET}  ${BOLD}${label}${RESET}\n"
    else
      printf "\r  ${RED}✘${RESET}  ${BOLD}${label}${RESET} ${DIM}(failed)${RESET}\n"
      [[ -s "$log" ]] && command tail -n 8 "$log"
    fi
    command rm -f "$log"
    return $ok
  }

  _row() {
    local icon=$1 name=$2 before=$3 after=$4 ok=$5
    if (( ok != 0 )) || [[ "$after" == "—" ]]; then
      printf "  %s  %-18s ${DIM}%-24s${RESET} ${RED}✘${RESET} ${RED}%s${RESET}\n" "$icon" "$name" "$before" "upgrade failed"
    elif [[ "$before" == "$after" ]]; then
      printf "  %s  %-18s ${DIM}%-24s${RESET} ${YELLOW}↔${RESET} ${DIM}%s${RESET}\n" "$icon" "$name" "$before" "already latest"
    else
      printf "  %s  %-18s ${DIM}%-24s${RESET} ${GREEN}→${RESET} ${GREEN}${BOLD}%s${RESET}\n" "$icon" "$name" "$before" "$after"
    fi
  }

  # 官方安装/升级命令：
  #   claude:  https://claude.ai/install.sh
  #   codex:   https://chatgpt.com/codex/install.sh   （默认走 releases.openai.com，不吃 GitHub API quota）
  #   agy:     首次安装用 install.sh；已安装用 agy update（install.sh 检测到已存在会直接退出）
  #   herdr:     herdr update
  #   opencode:  opencode upgrade
  _ai_upgrade_claude() {
    curl -fsSL https://claude.ai/install.sh | bash
  }

  _ai_upgrade_codex() {
    curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=1 sh
  }

  _ai_upgrade_agy() {
    if command -v agy >/dev/null 2>&1; then
      command agy update
    else
      curl -fsSL https://antigravity.google/cli/install.sh | bash
    fi
  }

  _ai_upgrade_herdr() {
    command herdr update
  }

  _ai_upgrade_opencode() {
    command opencode upgrade
  }

  setopt LOCAL_OPTIONS PIPE_FAIL NO_NOTIFY NO_MONITOR 2>/dev/null
  set +m 2>/dev/null

  local c_before x_before a_before h_before o_before
  (( do_claude )) && c_before=$(command claude --version 2>/dev/null || echo "—")
  (( do_codex )) && x_before=$(command codex --version 2>/dev/null || echo "—")
  (( do_agy )) && a_before=$(command agy --version 2>/dev/null || echo "—")
  (( do_herdr )) && h_before=$(command herdr --version 2>/dev/null || echo "—")
  (( do_opencode )) && o_before=$(command opencode --version 2>/dev/null || echo "—")

  _banner

  local enabled=()
  (( do_claude )) && enabled+=("Anthropic Claude")
  (( do_codex )) && enabled+=("OpenAI Codex")
  (( do_agy )) && enabled+=("Antigravity AGY")
  (( do_herdr )) && enabled+=("herdr")
  (( do_opencode )) && enabled+=("opencode")
  printf "  ${BOLD}本次升级：${RESET}%s\n\n" "${(j: · :)enabled}"

  local c_rc=0 x_rc=0 a_rc=0 h_rc=0 o_rc=0
  printf "  ${DIM}%s${RESET}\n" "·················································"
  if (( do_claude )); then _run "Anthropic Claude  " _ai_upgrade_claude; c_rc=$?; fi
  if (( do_codex )); then _run "OpenAI codex     " _ai_upgrade_codex; x_rc=$?; fi
  if (( do_agy )); then _run "Antigravity agy  " _ai_upgrade_agy; a_rc=$?; fi
  if (( do_herdr )); then _run "herdr            " _ai_upgrade_herdr; h_rc=$?; fi
  if (( do_opencode )); then _run "opencode         " _ai_upgrade_opencode; o_rc=$?; fi
  printf "  ${DIM}%s${RESET}\n" "·················································"

  echo ""

  rehash

  local c_after x_after a_after h_after o_after
  (( do_claude )) && c_after=$(command claude --version 2>/dev/null || echo "—")
  (( do_codex )) && x_after=$(command codex --version 2>/dev/null || echo "—")
  (( do_agy )) && a_after=$(command agy --version 2>/dev/null || echo "—")
  (( do_herdr )) && h_after=$(command herdr --version 2>/dev/null || echo "—")
  (( do_opencode )) && o_after=$(command opencode --version 2>/dev/null || echo "—")

  (( do_claude )) && _row "🦀" "Anthropic Claude"  "$c_before" "$c_after" "$c_rc"
  (( do_codex )) && _row "🐙" "OpenAI codex"     "$x_before" "$x_after" "$x_rc"
  (( do_agy )) && _row "🛸" "Antigravity agy"  "$a_before" "$a_after" "$a_rc"
  (( do_herdr )) && _row "🐑" "herdr"            "$h_before" "$h_after" "$h_rc"
  (( do_opencode )) && _row "🧰" "opencode"         "$o_before" "$o_after" "$o_rc"

  echo ""
  printf "  \033[38;5;213m✨\033[38;5;183m✨\033[38;5;153m✨\033[0m  ${DIM}all done!${RESET}\n"
  echo ""
  (( c_rc == 0 && x_rc == 0 && a_rc == 0 && h_rc == 0 && o_rc == 0 ))
}
