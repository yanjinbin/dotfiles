# Shell 与插件

[返回首页](../README.md) · [AI CLI 使用指南](ai-cli.md)

以下配置以仓库 `.zshrc` 和自定义插件为准。命令从仓库根目录执行。

## 加载与配置

- 本机 `~/.zshrc`、`~/.p10k.zsh` 和已纳管插件通过软链接引用仓库；首次切换前先合并两份配置，脚本保存原文件备份。
- 框架：Oh My Zsh + Powerlevel10k（含即时提示）
- 插件：`git`、`jj`、`uv`、`pnpm`、`docker-compose`、`z`、`you-should-use`、`tmux`、`herdr`、`gcma`、`jjma`、`perfect-little-angle`、`codex-niubikelas`、`p10k-jj-status`、`zsh-autosuggestions`、`zsh-syntax-highlighting`
- herdr：PATH 就绪后显式加载 `$ZSH/plugins/herdr/herdr.plugin.zsh`，提供官方别名和 `hrdrs` 会话选择器；仓库已保存此文件，恢复步骤见 [终端配置](../terminal-configs.md)。
- JJ 提示：`zsh-jj` 提供 `vcs_info` 的 JJ 后端（仅加载其 `functions/`，不 source 会重设 `PROMPT` 的完整插件）；`p10k-jj-status` 提供异步 JJ working-copy 段，当前由 `.zshrc` 在加载 `.p10k.zsh` 后加入 `jj_status`，并用 `P10K_PROMPT_SHOW_GIT_STATUS` 控制 Git 状态显示
- PATH：先加载 `/opt/homebrew/bin/brew shellenv`，再配置 `~/.local/bin`、`~/.opencode/bin`、pnpm、Maven、Go、fnm（Node）；不再设置 Go 或 Rust 镜像。
- Shell 集成：按文件或环境变量加载 fzf、iTerm2 和 Otty；本机私有配置从 `~/.config/zsh/private.zsh` 加载。

## 常用命令

- eza 列表：`ls`、`ll`、`lla`、`lld`、`llf`、`lt`、`lt3`、`lt4`
- uv：`ur`、`ua`、`us`、`uvp`
- opencode：`oc`、`oca`、`ocy`
- 工具：`c`（clear）、`y`（yazi）、`t`（history）、`wattage`、`myip`、`nvup`（Neovim 插件/Mason 更新）、`flushdns`、`ipv6on`、`ipv6off`、`mkcd`、`extract`、`ff`、`port`
- 时区：`tz jp|sg|la|system`（默认系统时区，需要时用 `tz` 临时切换）
- AI CLI（详见 [AI CLI 使用指南](ai-cli.md)）：`perfect-little-angle` 提供快捷命令并加载 `ai upgrade`；`codex-niubikelas` 提供只读代理与端点检查。代理快捷命令使用 `127.0.0.1:7890`。

## 插件参考

- `gcma` — AI 生成 Conventional Commits 提交信息，支持 Gemini / Claude / Codex / Copilot
  - 详细说明：[`.oh-my-zsh/custom/plugins/gcma/README.md`](../.oh-my-zsh/custom/plugins/gcma/README.md)
  - 可选配置：

    ```zsh
    export GCMA_DEFAULT_AGENT=agy
    # Set GCMA_DEFAULT_MODEL only when you want to pin a model.
    ```

- `jjma` — 为当前 jj change 生成 Conventional Commit 描述，支持大 diff 分块总结
  - 详细说明：[`.oh-my-zsh/custom/plugins/jjma/README.md`](../.oh-my-zsh/custom/plugins/jjma/README.md)
  - 默认配置：

    ```zsh
    export JJMA_DEFAULT_AGENT=agy
    ```

- `zsh-jj` / `p10k-jj-status` — JJ 状态提示组件
  - 详细说明：[`.oh-my-zsh/custom/plugins/zsh-jj/README.md`](../.oh-my-zsh/custom/plugins/zsh-jj/README.md)、[`.oh-my-zsh/custom/plugins/p10k-jj-status/README.md`](../.oh-my-zsh/custom/plugins/p10k-jj-status/README.md)
  - 通过统一脚本链接到 Oh My Zsh：

    ```bash
    python3 scripts/sync.py
    python3 scripts/sync.py --apply
    ```
