# Codex and Claude configuration

Both tools use the root `AGENTS.md` as the single source of global instructions:

| Local file | Repository source |
| --- | --- |
| `~/.codex/AGENTS.md` | `AGENTS.md` |
| `~/.claude/CLAUDE.md` | `AGENTS.md` |
| `~/.codex/config.toml` | `.local/codex/config.toml`, generated from the files below |
| `~/.codex/hooks.json` | `agents/codex/hooks.json` |
| `~/.codex/herdr-agent-state.sh` | `agents/codex/herdr-agent-state.sh` |
| `~/.claude/settings.json` | `agents/claude/settings.json` |
| `~/.claude/hooks/herdr-agent-state.sh` | `agents/claude/hooks/herdr-agent-state.sh` |

Run `python3 scripts/sync.py` from the repository root to preview links. After reviewing differences, use `--apply`; add `--replace` only for reviewed changes. The script backs up each replaced file and supports `--check` to verify all links.

## Codex settings and private state

`agents/codex/config.toml` stores model, reasoning, service tier, desktop preferences, feature flags, and plugin settings. It is outside `.codex/` so it cannot also load as this repository's project config. Codex distinguishes user and project configuration; see the [official configuration documentation](https://learn.chatgpt.com/docs/config-file/config-basic).

The sync script combines that file with the current machine's project trust records, hook approvals, notification command, local runtime MCP servers, bundled marketplace paths, and model onboarding state. These values stay in ignored `.local/codex/private.toml`. The result is ignored `.local/codex/config.toml`, linked from `~/.codex/config.toml`. The initial merge preserves all existing settings.

The TOML fragment merge belongs to this repository's script; it is not a Codex include feature. The script reads fresh private state from the live config on each apply. It fails on unsupported TOML layouts instead of silently dropping values.

After editing shared preferences, run `--apply --replace` to rebuild the linked config. After changing preferences in Codex itself, import them for review:

```bash
python3 scripts/sync.py --capture-codex
git diff -- agents/codex/config.toml
python3 scripts/sync.py --apply
python3 scripts/sync.py --check
```

Review new MCP entries and environment variables before committing; the script separates known machine state, but is not a secret detector. Authentication files, session databases, project history, cached packages, and `~/.codex/rules/default.rules` remain local. Existing task-specific approval rules are not exported.

## Claude settings and integrations

The settings retain the current model, Herdr session reporting, Agent Usage status line, and plugin preferences. The two Herdr hook scripts differ by agent protocol and must remain separate. Otty and Rex hooks are not configured.

Hooks and the status line currently use `/Users/yanjinbin` and the local `herdr-agent-usage` checkout. On another account, review and update these paths before linking. Install the corresponding applications and plugin binaries before using these integrations.

`~/.claude.json` contains account and project state and is not linked or exported. The inspected user MCP entry is Linear at `https://mcp.linear.app/mcp`; add it through Claude's current MCP CLI on a new machine and authenticate there. Never copy account or OAuth state from another machine.

The inspected Claude plugin sources are:

| Plugin | Marketplace source | Installed version / commit |
| --- | --- | --- |
| `mattpocock-skills@claude-plugins-official` | `anthropics/claude-plugins-official` | `1.3.1` / `49dd158d1076134a641b33efb035946536778336` |
| `diagram-design@diagram-design` | `cathrynlavery/diagram-design` | `2.6.107` / `b46c9701f035844a20b13ab0551315977188933b` |

Use `claude plugin marketplace` and `claude plugin install` to restore these registrations, checking the installed CLI help first. Settings alone do not install plugin code. Codex's enabled plugin entries likewise need their marketplaces and packages available; app-managed bundled marketplaces are supplied by the installed app. Skills, plugin caches, and absolute-path installation registries are not copied into dotfiles.
