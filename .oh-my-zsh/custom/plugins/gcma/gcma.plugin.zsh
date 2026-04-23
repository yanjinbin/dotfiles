# gcma: generate conventional commit message via selectable agent CLI
# Usage:
#   gcma [agent] [model]

unalias gcma 2>/dev/null

_gcma_help() {
  cat <<'EOF_HELP'
Usage:
  gcma [agent] [model]

Agents:
  codex   (default)
  claude
  copilot

Examples:
  gcma
  gcma codex gpt-5.3-codex
  gcma claude sonnet
  gcma copilot gpt-5-mini
  gcma --help

Notes:
  1) Stage changes first: git add ...
  2) gcma injects staged diff into the prompt, so agent tools are not required.
EOF_HELP
}

_gcma_prompt_base() {
  cat <<'EOF_PROMPT'
Generate a git commit message from the staged diff.

Requirements:
- Follow Conventional Commits
- Type must be one of: feat, fix, docs, style, refactor, test, chore, ci, build, perf, revert, hotfix
- Include a gitmoji AFTER the type
- Format strictly as: type(scope): emoji message
- If scope is unclear, omit it
- Maximum 72 characters
- Use imperative mood
- No trailing period

Output rules:
- Output exactly ONE line
- No explanation
- No extra text

Important:
- Use only the staged diff provided below.
- Do not ask to run git commands.
- Do not ask for extra permissions.
EOF_PROMPT
}

gcma() {
  local provider="codex"
  local model=""
  local default_model=""
  local tmp_file
  local err_file
  local prompt
  local raw
  local msg
  local confirm
  local staged_diff
  local pattern='^(feat|fix|docs|style|refactor|test|chore|ci|build|perf|revert|hotfix)(\([^)]+\))?: .+'
  local -i diff_limit=20000

  case "${1:-}" in
    -h|--help|help)
      _gcma_help
      return 0
      ;;
    codex|claude|copilot)
      provider="$1"
      shift
      ;;
  esac

  if [[ $# -gt 0 ]]; then
    model="$1"
    shift
  fi

  if [[ $# -gt 0 ]]; then
    echo "❌ Too many arguments"
    _gcma_help
    return 1
  fi

  staged_diff="$(git diff --cached --no-color --no-ext-diff 2>/dev/null)"
  if [[ -z "$staged_diff" ]]; then
    echo "❌ No staged changes. Run git add first."
    return 1
  fi

  if (( ${#staged_diff} > diff_limit )); then
    staged_diff="${staged_diff[1,$diff_limit]}\n\n[Diff truncated to first ${diff_limit} characters.]"
  fi

  case "$provider" in
    codex)   default_model="gpt-5.3-codex" ;;
    claude)  default_model="sonnet" ;;
    copilot) default_model="gpt-5-mini" ;;
  esac
  model="${model:-$default_model}"

  prompt="$(_gcma_prompt_base)

Staged diff starts:
$staged_diff
Staged diff ends."

  tmp_file="$(mktemp)"
  err_file="$(mktemp)"

  case "$provider" in
    codex)
      if ! command -v codex >/dev/null 2>&1; then
        echo "❌ codex not found in PATH"
        rm -f "$tmp_file" "$err_file"
        return 1
      fi
      if ! codex login status >/dev/null 2>&1; then
        echo "❌ Codex not logged in. Run: codex login"
        rm -f "$tmp_file" "$err_file"
        return 1
      fi
      if ! codex exec --model "$model" --ephemeral -o "$tmp_file" "$prompt" >/dev/null 2>"$err_file"; then
        echo "❌ Codex generation failed"
        echo "---- codex stderr (last 12 lines) ----"
        tail -n 12 "$err_file"
        rm -f "$tmp_file" "$err_file"
        return 1
      fi
      ;;
    claude)
      if ! command -v claude >/dev/null 2>&1; then
        echo "❌ claude not found in PATH"
        rm -f "$tmp_file" "$err_file"
        return 1
      fi
      if ! claude auth status >/dev/null 2>&1; then
        echo "❌ Claude not logged in. Run: claude auth login"
        rm -f "$tmp_file" "$err_file"
        return 1
      fi
      if ! claude -p --output-format text --permission-mode bypassPermissions --model "$model" "$prompt" >"$tmp_file" 2>"$err_file"; then
        echo "❌ Claude generation failed"
        echo "---- claude stderr (last 12 lines) ----"
        tail -n 12 "$err_file"
        rm -f "$tmp_file" "$err_file"
        return 1
      fi
      ;;
    copilot)
      if ! command -v gh >/dev/null 2>&1; then
        echo "❌ gh not found in PATH"
        rm -f "$tmp_file" "$err_file"
        return 1
      fi
      if ! gh auth status -h github.com >/dev/null 2>&1; then
        echo "❌ GitHub not logged in. Run: gh auth login -h github.com"
        rm -f "$tmp_file" "$err_file"
        return 1
      fi
      if ! gh copilot --model "$model" -p "$prompt" >"$tmp_file" 2>"$err_file"; then
        echo "❌ Copilot generation failed"
        echo "---- gh copilot stderr (last 12 lines) ----"
        tail -n 12 "$err_file"
        rm -f "$tmp_file" "$err_file"
        return 1
      fi
      ;;
  esac

  raw="$(tr -d '\r' < "$tmp_file")"
  msg="$(printf '%s\n' "$raw" | grep -E "$pattern" | tail -n 1)"
  if [[ -z "$msg" ]]; then
    msg="$(printf '%s\n' "$raw" | awk 'NF {print; exit}')"
  fi
  rm -f "$tmp_file" "$err_file"

  if [[ -z "$msg" ]]; then
    echo "❌ Failed to extract commit message"
    return 1
  fi

  if [[ ! "$msg" =~ $pattern ]]; then
    echo "❌ Invalid format from $provider:"
    echo "$msg"
    return 1
  fi

  if (( ${#msg} > 72 )); then
    echo "❌ Commit message too long (>72 chars):"
    echo "$msg"
    return 1
  fi

  if [[ "$msg" == *. ]]; then
    echo "❌ Commit message must not end with a period:"
    echo "$msg"
    return 1
  fi

  echo ""
  echo "💡 Suggested commit: (agent: $provider, model: $model)"
  echo "$msg"
  echo ""

  read "?Use this commit? (y/n): " confirm
  if [[ "$confirm" == "y" ]]; then
    git commit -m "$msg"
  else
    echo "❌ Aborted"
  fi
}
