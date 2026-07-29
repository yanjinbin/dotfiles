# jjma: generate a Conventional Commit description for the current jj change
# Usage:
#   jjma [agent] [model]

unalias jjma 2>/dev/null

_jjma_help() {
  cat <<'EOF_HELP'
Usage:
  jjma [agent] [model]

Agents:
  agy     (default, Antigravity)
  claude
  codex

Examples:
  jjma
  jjma agy "Gemini 3.1 Pro (High)"
  jjma claude sonnet
  jjma codex gpt-5.3-codex
  jj edit <change-id> && jjma
  jj edit @- && jjma
  jjma --help

Run Mode:
  1) Target: the exact revision currently checked out as the jj working copy (@)
  2) Defaults: agent=$JJMA_DEFAULT_AGENT or agy; model=$JJMA_DEFAULT_MODEL or per-agent default
  3) Context: the shell captures the pinned revision with read-only jj commands
  4) Flow: snapshot -> silent analysis -> validate -> snapshot check -> confirm -> jj describe

Notes:
  1) jj has no staging area; jjma describes every change currently contained in @.
  2) After `jj edit <change-id>`, jjma describes that edited change.
  3) The AI never runs shell commands; it receives context captured by the parent shell.
  4) A small diff uses one AI call; a large diff is summarized in bounded chunks and aggregated.
  5) If @ changes during analysis or confirmation, the suggestion is discarded.
  6) Defaults: agy -> "Gemini 3.1 Pro (High)", claude -> sonnet, codex -> gpt-5.3-codex.
  7) Local validation requires Conventional Commits format and a maximum length of 72.
  8) Messages ending with a period are rejected.
  9) The description is changed only after you confirm with y.
  10) Exit code: 0 on success, cancellation, or --help; 1 on validation/auth/generation failure.

Environment:
  JJMA_DEFAULT_AGENT       Default agent (agy, claude, or codex)
  JJMA_DEFAULT_MODEL       Model override for the default agent
  JJMA_DIFF_FULL_BYTES     One-call full-diff threshold (default: 204800)
  JJMA_DIFF_CHUNK_BYTES    Large-diff chunk size (default: 262144)
  JJMA_MAX_CHUNKS          Maximum chunks before refusing the change (default: 12)
  JJMA_PRINT_TIMEOUT       Antigravity print timeout (default: 5m)
EOF_HELP
}

_jjma_full_prompt() {
  local change_id="$1"
  local commit_id="$2"
  local manifest="$3"
  local change_diff="$4"

  cat <<EOF_PROMPT
Generate a Jujutsu change description from the supplied read-only context.

Change ID:
$change_id

Commit ID:
$commit_id

Change manifest:
$manifest

Compact Git-format diff:
$change_diff

Description requirements:
- Follow Conventional Commits.
- Type must be one of: feat, fix, docs, style, refactor, test, chore, ci, build, perf, revert, hotfix.
- Include a gitmoji AFTER the type.
- Format strictly as: type(scope): emoji message
- If scope is unclear, omit it.
- Maximum 72 characters.
- Use imperative mood.
- Do not end with a period.

Output rules:
- Output exactly ONE line.
- Output only the description.
- Do not use Markdown fences.
- Do not include analysis or explanations.
- Use only the supplied context.
- Do not use tools, run commands, inspect the filesystem, or ask questions.
EOF_PROMPT
}

_jjma_chunk_prompt() {
  local chunk_index="$1"
  local chunk_count="$2"
  local manifest="$3"
  local chunk_text="$4"

  cat <<EOF_PROMPT
Summarize chunk $chunk_index of $chunk_count from one Jujutsu change.

Change manifest:
$manifest

Diff chunk:
$chunk_text

Requirements:
- Identify concrete behavior, API, data, test, configuration, or documentation changes.
- Distinguish primary source changes from generated files, lockfiles, and bulk formatting.
- Return at most five short plain-text bullet points.
- Do not generate the final commit message yet.
- Use only the supplied context.
- Do not use tools, run commands, inspect the filesystem, or ask questions.
EOF_PROMPT
}

_jjma_aggregate_prompt() {
  local change_id="$1"
  local commit_id="$2"
  local manifest="$3"
  local chunk_summaries="$4"

  cat <<EOF_PROMPT
Generate one Jujutsu change description from summaries covering every diff chunk.

Change ID:
$change_id

Commit ID:
$commit_id

Change manifest:
$manifest

Chunk summaries:
$chunk_summaries

Description requirements:
- Summarize the dominant intent of the complete change, not an isolated chunk.
- Follow Conventional Commits.
- Type must be one of: feat, fix, docs, style, refactor, test, chore, ci, build, perf, revert, hotfix.
- Include a gitmoji AFTER the type.
- Format strictly as: type(scope): emoji message
- If scope is unclear, omit it.
- Maximum 72 characters.
- Use imperative mood.
- Do not end with a period.

Output rules:
- Output exactly ONE line.
- Output only the description.
- Do not use Markdown fences.
- Do not include analysis or explanations.
- Use only the supplied context.
- Do not use tools, run commands, inspect the filesystem, or ask questions.
EOF_PROMPT
}

_jjma_run_agent() {
  local provider="$1"
  local model="$2"
  local repo_root="$3"
  local prompt="$4"
  local print_timeout="$5"
  local output_file="$6"
  local error_file="$7"

  : >| "$output_file"
  : >| "$error_file"

  case "$provider" in
    agy)
      (
        builtin cd -- "$repo_root" >/dev/null 2>&1 &&
          command agy \
            --mode plan \
            --sandbox \
            --output-format text \
            --print-timeout "$print_timeout" \
            --model "$model" \
            -p "$prompt"
      ) </dev/null >"$output_file" 2>"$error_file"
      ;;
    claude)
      (
        builtin cd -- "$repo_root" >/dev/null 2>&1 &&
          command claude \
            -p \
            --output-format text \
            --permission-mode plan \
            --model "$model" \
            "$prompt"
      ) </dev/null >"$output_file" 2>"$error_file"
      ;;
    codex)
      command codex exec \
        --model "$model" \
        --sandbox read-only \
        --cd "$repo_root" \
        --ephemeral \
        --color never \
        --output-last-message "$output_file" \
        - <<<"$prompt" >/dev/null 2>"$error_file"
      ;;
  esac
}

_jjma_remove_temp_dir() {
  local temp_dir="$1"
  local temp_parent="${TMPDIR:-/tmp}"
  local temp_file

  [[ -n "$temp_dir" && -d "$temp_dir" ]] || return 0
  [[ "$temp_dir" == "$temp_parent"/jjma.* ]] || return 1

  for temp_file in "$temp_dir"/*(N); do
    [[ -f "$temp_file" ]] && command rm -f -- "$temp_file"
  done
  command rmdir -- "$temp_dir" 2>/dev/null
}

_jjma_extract_message() {
  local pattern="$1"
  local normalized

  # Text-mode CLIs can still emit a BOM, ANSI styling, CRLF, or surrounding
  # whitespace. Normalize those wrappers before applying the anchored format
  # check so a visually valid one-line description is not rejected.
  normalized="$(
    command sed \
      -e $'s/\033\\][^\007]*\007//g' \
      -e $'s/\033\\[[0-9;?]*[ -\\/]*[@-~]//g' |
      command tr -d '\r'
  )"
  normalized="${normalized#$'\xef\xbb\xbf'}"

  printf '%s\n' "$normalized" |
    command sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' |
    command grep -E "$pattern" |
    command tail -n 1
}

jjma() {
  local provider="${JJMA_DEFAULT_AGENT:-agy}"
  local model=""
  local explicit_provider=0
  local default_model=""
  local repo_root
  local snapshot
  local current_commit_id
  local change_id
  local change_id_short
  local commit_id
  local change_summary
  local diff_full_bytes="${JJMA_DIFF_FULL_BYTES:-204800}"
  local diff_chunk_bytes="${JJMA_DIFF_CHUNK_BYTES:-262144}"
  local max_chunks="${JJMA_MAX_CHUNKS:-12}"
  local print_timeout="${JJMA_PRINT_TIMEOUT:-5m}"
  local temp_dir=""
  local output_file
  local error_file
  local diff_file
  local stat_file
  local summary_file
  local summaries_file
  local stat_lines
  local summary_lines
  local manifest
  local diff_bytes
  local change_diff
  local chunk_count=0
  local chunk_index=0
  local chunk_file
  local chunk_text
  local chunk_summary
  local chunk_summaries
  local -a chunk_files
  local prompt
  local generation_status=0
  local raw
  local msg
  local confirm
  local pattern='^(feat|fix|docs|style|refactor|test|chore|ci|build|perf|revert|hotfix)(\([^)]+\))?: .+$'
  local agy_valid_models=(
    "Gemini 3.5 Flash (Medium)"
    "Gemini 3.5 Flash (High)"
    "Gemini 3.5 Flash (Low)"
    "Gemini 3.1 Pro (Low)"
    "Gemini 3.1 Pro (High)"
    "Claude Sonnet 4.6 (Thinking)"
    "Claude Opus 4.6 (Thinking)"
    "GPT-OSS 120B (Medium)"
  )

  case "${1:-}" in
    -h|--help|help)
      _jjma_help
      return 0
      ;;
    agy|antigravity)
      provider="agy"
      explicit_provider=1
      shift
      ;;
    claude|codex)
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
    _jjma_help
    return 1
  fi

  if ! command -v jj >/dev/null 2>&1; then
    echo "❌ jj not found in PATH"
    return 1
  fi

  repo_root="$(command jj root 2>/dev/null)" || {
    echo "❌ Not inside a jj repository"
    return 1
  }

  snapshot="$(
    command jj --color=never log --no-graph -r @ \
      -T 'change_id ++ "\n" ++ commit_id' 2>/dev/null
  )"
  if [[ -z "$snapshot" || "$snapshot" != *$'\n'* ]]; then
    echo "❌ Failed to capture the current jj revision"
    return 1
  fi

  change_id="${snapshot%%$'\n'*}"
  commit_id="${snapshot#*$'\n'}"
  change_id_short="${change_id[1,8]}"

  change_summary="$(
    command jj --color=never diff -r "$commit_id" --summary 2>/dev/null |
      command sed -n '1p'
  )"
  if [[ -z "$change_summary" ]]; then
    echo "❌ Current jj change (@) is empty"
    return 1
  fi

  if [[ "$diff_full_bytes" != <-> || "$diff_full_bytes" -lt 1024 || "$diff_full_bytes" -gt 524288 ]]; then
    echo "❌ JJMA_DIFF_FULL_BYTES must be an integer from 1024 to 524288"
    return 1
  fi

  if [[ "$diff_chunk_bytes" != <-> || "$diff_chunk_bytes" -lt 32768 || "$diff_chunk_bytes" -gt 524288 ]]; then
    echo "❌ JJMA_DIFF_CHUNK_BYTES must be an integer from 32768 to 524288"
    return 1
  fi

  if [[ "$max_chunks" != <-> || "$max_chunks" -lt 1 || "$max_chunks" -gt 32 ]]; then
    echo "❌ JJMA_MAX_CHUNKS must be an integer from 1 to 32"
    return 1
  fi

  case "$provider" in
    agy)    default_model="Gemini 3.1 Pro (High)" ;;
    claude) default_model="sonnet" ;;
    codex)  default_model="gpt-5.3-codex" ;;
  esac

  # JJMA_DEFAULT_MODEL applies only when the provider was not overridden.
  if [[ -z "$model" ]]; then
    if (( !explicit_provider )) && [[ -n "${JJMA_DEFAULT_MODEL:-}" ]]; then
      model="$JJMA_DEFAULT_MODEL"
    else
      model="$default_model"
    fi
  fi

  if [[ "$provider" == "agy" ]]; then
    local valid=0
    local candidate
    for candidate in "${agy_valid_models[@]}"; do
      [[ "$candidate" == "$model" ]] && valid=1 && break
    done
    if (( !valid )); then
      echo "❌ Invalid agy model: $model"
      echo "Valid options: ${agy_valid_models[*]}"
      return 1
    fi
  fi

  case "$provider" in
    agy)
      if ! command -v agy >/dev/null 2>&1; then
        echo "❌ agy not found in PATH"
        return 1
      fi
      ;;
    claude)
      if ! command -v claude >/dev/null 2>&1; then
        echo "❌ claude not found in PATH"
        return 1
      fi
      if ! command claude auth status >/dev/null 2>&1; then
        echo "❌ Claude not logged in. Run: claude auth login"
        return 1
      fi
      ;;
    codex)
      if ! command -v codex >/dev/null 2>&1; then
        echo "❌ codex not found in PATH"
        return 1
      fi
      if ! command codex login status >/dev/null 2>&1; then
        echo "❌ Codex not logged in. Run: codex login"
        return 1
      fi
      ;;
  esac

  temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/jjma.XXXXXX")" || {
    echo "❌ Failed to create temporary files"
    return 1
  }
  output_file="$temp_dir/output"
  error_file="$temp_dir/error"
  diff_file="$temp_dir/change.diff"
  stat_file="$temp_dir/change.stat"
  summary_file="$temp_dir/change.summary"
  summaries_file="$temp_dir/chunk-summaries"

  if ! command jj --color=never diff -r "$commit_id" --stat >"$stat_file" 2>"$error_file" ||
     ! command jj --color=never diff -r "$commit_id" --summary >"$summary_file" 2>>"$error_file" ||
     ! command jj --color=never diff -r "$commit_id" --git --context=0 >"$diff_file" 2>>"$error_file"; then
    echo "❌ Failed to capture the pinned jj change"
    [[ -s "$error_file" ]] && command sed -n '1,120p' "$error_file"
    _jjma_remove_temp_dir "$temp_dir"
    return 1
  fi

  stat_lines="$(command wc -l <"$stat_file" | command tr -d '[:space:]')"
  summary_lines="$(command wc -l <"$summary_file" | command tr -d '[:space:]')"
  diff_bytes="$(command wc -c <"$diff_file" | command tr -d '[:space:]')"

  manifest="Diff stat (showing up to 300 of $stat_lines lines):
$(command sed -n '1,300p' "$stat_file")

Changed paths and statuses (showing up to 300 of $summary_lines lines):
$(command sed -n '1,300p' "$summary_file")"

  echo "🤖 $provider is analyzing change $change_id_short..."

  if (( diff_bytes <= diff_full_bytes )); then
    change_diff="$(<"$diff_file")"
    prompt="$(_jjma_full_prompt "$change_id" "$commit_id" "$manifest" "$change_diff")"
    _jjma_run_agent \
      "$provider" "$model" "$repo_root" "$prompt" "$print_timeout" \
      "$output_file" "$error_file" || generation_status=$?
  else
    chunk_count=$(( (diff_bytes + diff_chunk_bytes - 1) / diff_chunk_bytes ))
    if (( chunk_count > max_chunks )); then
      echo "❌ Compact diff is $diff_bytes bytes and needs $chunk_count chunks"
      echo "Maximum allowed chunks: $max_chunks"
      echo "Split the jj change, or explicitly raise JJMA_MAX_CHUNKS (maximum 32)."
      _jjma_remove_temp_dir "$temp_dir"
      return 1
    fi

    echo "🧩 Large diff: $diff_bytes bytes, $chunk_count analysis chunks"
    if ! command split -b "$diff_chunk_bytes" "$diff_file" "$temp_dir/chunk."; then
      echo "❌ Failed to split the large diff"
      _jjma_remove_temp_dir "$temp_dir"
      return 1
    fi

    chunk_files=("$temp_dir"/chunk.*(N))
    if (( ${#chunk_files[@]} != chunk_count )); then
      echo "❌ Diff chunk count mismatch"
      _jjma_remove_temp_dir "$temp_dir"
      return 1
    fi

    : >| "$summaries_file"
    for chunk_file in "${chunk_files[@]}"; do
      (( chunk_index += 1 ))
      echo "   Summarizing chunk $chunk_index/$chunk_count..."
      chunk_text="$(<"$chunk_file")"
      prompt="$(_jjma_chunk_prompt "$chunk_index" "$chunk_count" "$manifest" "$chunk_text")"

      generation_status=0
      _jjma_run_agent \
        "$provider" "$model" "$repo_root" "$prompt" "$print_timeout" \
        "$output_file" "$error_file" || generation_status=$?

      if (( generation_status != 0 )); then
        echo "❌ $provider chunk $chunk_index analysis failed (exit $generation_status)"
        if [[ -s "$error_file" ]]; then
          echo "---- $provider stderr ----"
          command sed -n '1,120p' "$error_file"
        fi
        _jjma_remove_temp_dir "$temp_dir"
        return 1
      fi

      chunk_summary="$(command tr -d '\r' <"$output_file")"
      if [[ -z "${chunk_summary//[[:space:]]/}" ]]; then
        echo "❌ $provider returned no summary for chunk $chunk_index"
        if [[ -s "$error_file" ]]; then
          echo "---- $provider stderr ----"
          command sed -n '1,120p' "$error_file"
        fi
        _jjma_remove_temp_dir "$temp_dir"
        return 1
      fi

      if (( ${#chunk_summary} > 6000 )); then
        echo "❌ $provider returned an oversized summary for chunk $chunk_index"
        _jjma_remove_temp_dir "$temp_dir"
        return 1
      fi

      printf 'Chunk %d/%d:\n%s\n\n' \
        "$chunk_index" "$chunk_count" "$chunk_summary" >>"$summaries_file"
    done

    chunk_summaries="$(<"$summaries_file")"
    prompt="$(_jjma_aggregate_prompt "$change_id" "$commit_id" "$manifest" "$chunk_summaries")"
    generation_status=0
    echo "   Aggregating chunk summaries..."
    _jjma_run_agent \
      "$provider" "$model" "$repo_root" "$prompt" "$print_timeout" \
      "$output_file" "$error_file" || generation_status=$?
  fi

  if (( generation_status != 0 )); then
    echo "❌ $provider analysis failed (exit $generation_status)"
    if [[ -s "$error_file" ]]; then
      echo "---- $provider stderr ----"
      command sed -n '1,120p' "$error_file"
    fi
    _jjma_remove_temp_dir "$temp_dir"
    return 1
  fi

  raw="$(<"$output_file")"
  if [[ -z "${raw//[[:space:]]/}" ]]; then
    echo "❌ $provider returned no change description"
    if [[ -s "$error_file" ]]; then
      echo "---- $provider stderr ----"
      command sed -n '1,120p' "$error_file"
    fi
    _jjma_remove_temp_dir "$temp_dir"
    return 1
  fi
  _jjma_remove_temp_dir "$temp_dir"

  msg="$(printf '%s\n' "$raw" | _jjma_extract_message "$pattern")"
  if [[ -z "$msg" ]]; then
    msg="$(
      printf '%s\n' "$raw" |
        command sed \
          -e $'s/\033\\][^\007]*\007//g' \
          -e $'s/\033\\[[0-9;?]*[ -\\/]*[@-~]//g' |
        command tr -d '\r' |
        command awk 'NF {sub(/^[[:space:]]+/, ""); sub(/[[:space:]]+$/, ""); print; exit}'
    )"
    msg="${msg#$'\xef\xbb\xbf'}"
  fi

  if [[ -z "$msg" ]]; then
    echo "❌ Failed to extract change description"
    return 1
  fi

  if ! printf '%s\n' "$msg" | command grep -Eq "$pattern"; then
    echo "❌ Invalid format from $provider:"
    echo "$msg"
    return 1
  fi

  if (( ${#msg} > 72 )); then
    echo "❌ Change description too long (>72 chars):"
    echo "$msg"
    return 1
  fi

  if [[ "$msg" == *. ]]; then
    echo "❌ Change description must not end with a period:"
    echo "$msg"
    return 1
  fi

  current_commit_id="$(
    command jj --color=never log --no-graph -r @ -T 'commit_id' 2>/dev/null
  )"
  if [[ "$current_commit_id" != "$commit_id" ]]; then
    echo "⚠️ Current jj change changed during analysis; suggestion discarded"
    echo "Run jjma again against the latest @."
    return 1
  fi

  echo ""
  echo "💡 Suggested description for @ ($change_id_short): (agent: $provider, model: $model)"
  echo "$msg"
  echo ""

  read "?Describe the current change with this message? (y/n): " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "❌ Aborted"
    return 0
  fi

  current_commit_id="$(
    command jj --color=never log --no-graph -r @ -T 'commit_id' 2>/dev/null
  )"
  if [[ "$current_commit_id" != "$commit_id" ]]; then
    echo "⚠️ Current jj change changed before confirmation; suggestion discarded"
    echo "Run jjma again against the latest @."
    return 1
  fi

  printf '%s\n' "$msg" | command jj describe -r "$commit_id" --stdin
}
