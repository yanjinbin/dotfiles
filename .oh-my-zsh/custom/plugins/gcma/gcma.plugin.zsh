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
  gemini
  copilot

Examples:
  gcma
  gcma codex gpt-5.3-codex
  gcma claude sonnet
  gcma gemini gemini-2.5-pro
  gcma copilot gpt-5-mini
  gcma --help

Run Mode:
  1) Args: gcma [agent] [model]
  2) Defaults: agent=$GCMA_DEFAULT_AGENT or codex; model=$GCMA_DEFAULT_MODEL or per-agent default
  3) Context: staged summary + name-status + unified diff
  4) Flow: auth check -> generate -> local validate -> confirm -> git commit

Notes:
  1) Stage only what you want to describe. Unstaged and untracked changes are ignored.
  2) Auth is checked before generation: codex login status, claude auth status, gemini auth status, or gh auth status.
  3) Defaults: codex -> gpt-5.3-codex, claude -> sonnet, gemini -> gemini-2.5-pro, copilot -> gpt-5-mini.
  4) Gemini valid models: gemini-3.1-pro-preview gemini-3-flash-preview gemini-3.1-flash-lite-preview gemini-2.5-pro gemini-2.5-flash
  5) Injected context has 3 sections: summary, name-status, and unified diff.
  6) Diff context is compacted (U0 + minimal) without truncation; added/removed lines are preserved.
  7) Local validation requires Conventional Commits pattern and max length 72.
  8) Messages ending with a period are rejected.
  9) After suggestion, commit runs only when you confirm with y.
  10) Exit code: 0 on success or --help; 1 on validation/auth/generation failure.
EOF_HELP
}

_gcma_prompt_base() {
  cat <<'EOF_PROMPT'
Generate a git commit message from the staged changes context.

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
- Use only the staged context provided below (summary, name-status, unified diff).
- The unified diff is compacted with --unified=0 --minimal to reduce tokens.
- All added/removed lines from staged changes are preserved (no truncation).
- Do not ask to run git commands.
- Do not ask for extra permissions.
EOF_PROMPT
}

gcma() {
  local provider="${GCMA_DEFAULT_AGENT:-codex}"
  local model=""
  local explicit_provider=0
  local default_model=""
  local tmp_file
  local err_file
  local prompt
  local raw
  local msg
  local confirm
  local staged_summary
  local staged_name_status
  local staged_diff
  local pattern='^(feat|fix|docs|style|refactor|test|chore|ci|build|perf|revert|hotfix)(\([^)]+\))?: .+'
  local gemini_valid_models=(
    gemini-3.1-pro-preview
    gemini-3-flash-preview
    gemini-3.1-flash-lite-preview
    gemini-2.5-pro
    gemini-2.5-flash
  )

  case "${1:-}" in
    -h|--help|help)
      _gcma_help
      return 0
      ;;
    codex|claude|gemini|copilot)
      provider="$1"
      explicit_provider=1
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

  staged_summary="$(git diff --cached --summary 2>/dev/null)"
  staged_name_status="$(git diff --cached --name-status 2>/dev/null)"
  staged_diff="$(git diff --cached --no-color --no-ext-diff --unified=0 --minimal 2>/dev/null)"

  if [[ -z "$staged_summary" && -z "$staged_name_status" && -z "$staged_diff" ]]; then
    echo "❌ No staged changes. Run git add first."
    return 1
  fi

  case "$provider" in
    codex)   default_model="gpt-5.3-codex" ;;
    claude)  default_model="sonnet" ;;
    gemini)  default_model="gemini-2.5-pro" ;;
    copilot) default_model="gpt-5-mini" ;;
  esac
  # GCMA_DEFAULT_MODEL only applies when using the default agent (not overridden via CLI)
  if [[ -z "$model" ]]; then
    if (( !explicit_provider )) && [[ -n "${GCMA_DEFAULT_MODEL:-}" ]]; then
      model="$GCMA_DEFAULT_MODEL"
    else
      model="$default_model"
    fi
  fi

  if [[ "$provider" == "gemini" ]]; then
    local valid=0
    for m in "${gemini_valid_models[@]}"; do
      [[ "$m" == "$model" ]] && valid=1 && break
    done
    if (( !valid )); then
      echo "❌ Invalid gemini model: $model"
      echo "Valid options: ${gemini_valid_models[*]}"
      return 1
    fi
  fi

  prompt="$(_gcma_prompt_base)

Staged summary starts:
${staged_summary:-[none]}
Staged summary ends.

Staged name-status starts:
${staged_name_status:-[none]}
Staged name-status ends.

Staged unified diff starts:
${staged_diff:-[none]}
Staged unified diff ends."

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
        echo "---- codex stderr ----"
        cat "$err_file"
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
        echo "---- claude stderr ----"
        cat "$err_file"
        rm -f "$tmp_file" "$err_file"
        return 1
      fi
      ;;
    gemini)
      if ! command -v gemini >/dev/null 2>&1; then
        echo "❌ gemini not found in PATH"
        rm -f "$tmp_file" "$err_file"
        return 1
      fi
      if ! command gemini --output-format text --model "$model" -p "$prompt" >"$tmp_file" 2>"$err_file"; then
        echo "❌ Gemini generation failed"
        echo "---- gemini stderr ----"
        cat "$err_file"
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
        echo "---- gh copilot stderr ----"
        cat "$err_file"
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
