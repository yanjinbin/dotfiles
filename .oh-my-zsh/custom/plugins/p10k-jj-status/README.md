# p10k jj status

## What?

A zsh / powerlevel10k plugin for displaying the status of jujutsu repositories
on the command line prompt.
It supports jj's native color output and doesn't use vcs_info.

## Why?

1. Something in the vcs_info + powerlevel10k's vcs segment (the one used for
   gitstatus) breaks escaping of escape sequences, which is necessary for a
   properly aligned right side prompt.
2. In colocated repositories, it'd be nice to also see info from gitstatus.

## How?

Works like any other zsh plugin.
Either use a plugin manager and copy/clone

```zsh
# .zshrc

# Example: oh my zsh
plugins=(
    # other plugins...
    p10k-jj-status
)

# ~/.p10k.zsh (the segment must be enabled explicitly)
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir
    jj_status
    vcs
)

```

For a manual installation, source the plugin directly:

```zsh
source ~/path-to-copy/p10k-jj-status.plugin.zsh
```

The current implementation refreshes JJ's working-copy snapshot, displays the
short change ID plus a changed-file count, and uses `zsh-async` when available.
It falls back to synchronous rendering when `zsh-async` is not installed.
