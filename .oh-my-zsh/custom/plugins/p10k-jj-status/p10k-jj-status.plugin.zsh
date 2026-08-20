setopt localoptions NO_shwordsplit
autoload -Uz VCS_INFO_bydir_detect

# Load zsh-async when it is installed next to this plugin. The prompt still has
# a synchronous fallback, so a missing optional dependency never breaks zsh.
if (( ! $+functions[async_init] )); then
    typeset -g _P10K_JJ_ASYNC_PATH="${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-async/async.zsh"
    [[ -r "$_P10K_JJ_ASYNC_PATH" ]] && source "$_P10K_JJ_ASYNC_PATH"
fi

typeset -g _P10K_JJ_STATUS_DISPLAY=''
typeset -g _P10K_JJ_STATUS_WORKSPACE=''
typeset -g _P10K_JJ_STATUS_WORKER='p10k_jj_status_worker'

# Render the current JJ working-copy change. This function runs in a zsh-async
# worker when available, so snapshotting and diff counting never block the
# interactive shell.
function _p10k_jj_status_render() {
    emulate -L zsh
    setopt pipefail

    local workspace="$1"
    local revision file_status display

    # Refresh JJ's working-copy snapshot so the prompt reflects filesystem
    # edits even before the user runs another jj command.
    command jj --repository "$workspace" --no-pager debug snapshot \
        >/dev/null 2>&1 || return

    revision="$(
        command jj --repository "$workspace" --ignore-working-copy --no-pager \
            log --no-graph --color never --revisions @ --limit 1 --template '
              separate(" ",
                "@" ++ change_id.shortest(8),
                if(conflict, "×"),
                if(empty, "∅")
              )
              ++ "\n"
            ' 2>/dev/null
    )" || return

    file_status="$(
        command jj --repository "$workspace" --ignore-working-copy --no-pager \
            log --no-graph --color never --revisions @ --limit 1 \
            --template 'self.diff().files().map(|f| f.status()).join("\n")' \
            2>/dev/null |
        awk 'NF { changed++ } END { if (changed) printf "!%d", changed }'
    )" || return

    display="$revision"
    [[ -n "$file_status" ]] && display+=" $file_status"

    # The first line lets the callback reject stale results from a workspace
    # that is no longer active.
    print -r -- "$workspace"
    print -r -- "$display"
}

function _p10k_jj_status_callback() {
    emulate -L zsh

    local job_name="$1"
    local exit_code="$2"
    local output="$3"
    local next_pending="$6"
    local workspace display

    [[ "$job_name" == "_p10k_jj_status_render" && "$exit_code" == 0 ]] || return

    workspace="${output%%$'\n'*}"
    display="${output#*$'\n'}"

    [[ "$workspace" == "$_P10K_JJ_STATUS_WORKSPACE" ]] || return
    _P10K_JJ_STATUS_DISPLAY="$display"

    (( next_pending )) || p10k display -r
}

function prompt_jj_status() {
    local -A vcs_comm
    local workspace result
    vcs_comm[detect_need_file]=working_copy

    VCS_INFO_bydir_detect .jj || return
    workspace="$vcs_comm[basedir]"

    if [[ "$workspace" != "$_P10K_JJ_STATUS_WORKSPACE" ]]; then
        _P10K_JJ_STATUS_WORKSPACE="$workspace"
        _P10K_JJ_STATUS_DISPLAY=''
    fi

    if (( $+functions[async_job] )); then
        async_job "$_P10K_JJ_STATUS_WORKER" _p10k_jj_status_render "$workspace"
        p10k segment -t '$_P10K_JJ_STATUS_DISPLAY' -e
        return
    fi

    result="$(_p10k_jj_status_render "$workspace")" || return
    _p10k_jj_status_callback _p10k_jj_status_render 0 "$result" 0 '' 0
    [[ -n "$_P10K_JJ_STATUS_DISPLAY" ]] || return
    p10k segment -t "$_P10K_JJ_STATUS_DISPLAY"
}

# Reinitialize cleanly when ~/.zshrc is sourced more than once.
if (( $+functions[async_init] )) && [[ -o interactive ]]; then
    async_init
    async_stop_worker "$_P10K_JJ_STATUS_WORKER" 2>/dev/null
    async_start_worker "$_P10K_JJ_STATUS_WORKER" -u
    async_unregister_callback "$_P10K_JJ_STATUS_WORKER" 2>/dev/null
    async_register_callback "$_P10K_JJ_STATUS_WORKER" _p10k_jj_status_callback
fi
