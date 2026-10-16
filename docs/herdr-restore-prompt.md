# Herdr recovery prompt

Copy the following prompt into a new coding session on the destination machine. The inventory was checked against the local CLI and manifests on 2026-10-16. It is a recovery specification, not evidence of installation on another machine.

```text
Restore my Otty, Herdr CLI, Herdr.app, and agent integrations from my dotfiles.

Repository: https://github.com/yanjinbin/dotfiles
Usual checkout: ~/WebstormProjects/dotfiles
Original account: /Users/yanjinbin

Read AGENTS.md, terminal-configs.md, agents/README.md, and symlinks.json first.
Inspect the destination before changing it. Preserve existing work, credentials,
sessions, SSH entries, and files outside the managed list. Back up replaced files.
Use file-level symlinks through scripts/sync.py. Do not link entire runtime dirs.
Do not commit, push, restart Herdr, stop its server, or kill terminal processes.
If a required restart would close active work, report it and ask before restarting.
Do not print credentials or copy auth databases into the public repository.

1. Inspect versions and dependencies.
   Check Otty, Herdr CLI, Herdr.app, Git, jj, Node, Python 3.11+, Cargo, and fonts.
   Use current local CLI help and official installation instructions.
   All four GitHub plugins below are pinned to observed commits, not latest.
   Most require Herdr >= 0.9.0; jj-workspace declares >= 0.7.0.
   Inspect build scripts for additional dependencies before running them.

2. Restore the five plugins observed as installed and enabled.

   herdr plugin install jeffarese/herdr-bar --ref 5dbc33404218f23e16c724a5675534c96fb67882
   herdr plugin install mrolafsson/herdr-linear --ref b6da0a22c832769af58810f7748fa6973f9a6704
   herdr plugin install hhdebb/herdr-radar --ref 2425fa080b7b72f30c1299481282b23003a2ee61
   herdr plugin install NathanFlurry/herdr-plugin-jj-workspace --ref ee71c3ce112ce97b494f4f77a92ac8589df12274

   Observed versions: herdr-bar 0.5.1, herdr-linear 0.6.2,
   hhdebb.herdr-radar 1.3.20, nathanflurry.jj-workspace 0.4.0.
   Radar builds with Node; jj-workspace builds with Cargo; Linear has a build.sh.
   Bar uses Python. Validate each installed manifest and enabled state.

   The fifth plugin, herdr-agent-usage 1.6.3, was linked from a clean local checkout:
   source: https://github.com/levi-qiao/herdr-agent-usage.git
   commit: 1b21311ec3fa2b46c2c715a8490f104fbde857e0
   path: ~/WebstormProjects/herdr-agent-usage
   Clone if absent. If present, inspect status before selecting the pinned commit;
   do not reset a dirty checkout. Read its build instructions, build with Cargo,
   then register it with:

   herdr plugin link "$HOME/WebstormProjects/herdr-agent-usage"

   Verify target/release/herdr-agent-usage exists. Claude's status line and both
   tools' quota integrations depend on this checkout. Do not infer that a plugin
   registry entry proves the binary is available or its runtime is healthy.
   Authenticate Linear and quota providers on the destination machine as needed.
   Keep OAuth tokens and provider credentials local.

3. Treat tsk as optional, not as one of the five installed plugins.
   Dotfiles contains .config/herdr/tsk-plugins/6dbeb33a45acd132/ with a 0.10.1
   herdr-tsk manifest, but the source machine's plugin list did not register it.
   Its manifest refers to /Users/yanjinbin/.local/bin/tsk.
   Ask whether it is wanted before adding it; inspect tsk's supported integration
   setup and fix destination paths. Do not claim it was previously enabled.

4. Restore configuration after plugin installation.
   Plugin install/configure actions can rewrite theme, sidebar, and hook settings.
   Compare the results with the dotfiles snapshots before restoring personal prefs.
   Do not copy plugins.json as an active registry: it contains source-machine paths.
   Do not copy old plugins/github caches or session/runtime data.
   Herdr.app reads config-gpui.local.toml for personal overrides. Leave its generated
   config-gpui.toml to the app. Otty uses Apple Graphite; preserve the current
   sidebar, quota, keybinding, and theme choices from the tracked configuration.

   Review absolute paths in agents/codex/hooks.json, agents/claude/settings.json,
   plugin manifests, and the Agent Usage status line if the account path differs.
   Install Otty shell/agent integration through the application as needed.
   Reconcile its generated hooks with the tracked hooks; do not add duplicates.

   From the repository root:
   python3 scripts/sync.py
   # Review and merge all reported differences before allowing replacement.
   python3 scripts/sync.py --apply --replace
   python3 scripts/sync.py --check

   The script saves original files. Codex's public settings and local private
   runtime fragment produce a linked config without publishing private paths.
   Keep existing local approval rules and authentication files intact.

5. Restore fonts explicitly.
   Otty needs MesloLGS NF Herdr and Herdr Agent Icons Max.
   Herdr.app uses MesloLGS NF Herdr Fit, JetBrains Mono Herdr,
   MesloLGL Nerd Font, and JetBrains Mono.
   Read fonts/README.md and verify fonts/SHA256SUMS from the repository root.
   The exact installed Regular files are archived under fonts/herdr/ and fonts/base/.
   Install those six files into ~/Library/Fonts/ without replacing differing
   existing files until they have been reviewed. The older 29-icon font remains
   in .config/otty/fonts/; the system restore uses the newer 30-icon font.
   Otty's app font folder does not install fonts for Herdr. Inspect duplicate
   family registrations and verify the selected names and glyph coverage in the UI.
   Preserve the bundled licenses and notices. The Meslo patched build recipes
   were not recovered; use the archived binaries rather than claiming a source rebuild.

6. Validate the result.
   Run the dotfiles tests and shell syntax checks.
   Run Otty's config validator with the linked config path.
   Parse Herdr TOML and the agent JSON files.
   Verify all five plugin IDs, versions, sources, and enabled states with
   herdr plugin list. Verify binaries, hook paths, and status-line commands exist.
   Check that each bound plugin action exists in its installed manifest.
   Reload Herdr config only after the config and plugin checks pass.
   Observe Otty and Herdr.app fonts, theme, sidebar rows, and shortcuts in the UI.
   Check Claude and Codex session reporting in a real test pane, without sending
   messages to external services on my behalf. Verify quota display after login.
   Do not open/remove jj workspaces in existing projects merely to test shortcuts;
   use a disposable repository if a functional test is needed.

Report what was installed, what was linked, backup paths, exact checks performed,
and any remaining authentication, font, version, or restart requirements.
Separate source/config validation from observed runtime behavior. Never claim
that prompts, configuration files, or successful builds prove UI behavior.
```
