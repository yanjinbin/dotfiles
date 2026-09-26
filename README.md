# dotfiles

macOS 开发环境配置仓库，集中管理终端、编辑器、包管理与网络规则。

## 仓库内容

- Shell: `.zshrc`、`.p10k.zsh`、`.oh-my-zsh/`（插件与命令）
- Editor: `.vimrc`、`.spacemacs`、`settings.json`、`launch.json`
- Package: `Brewfile`
- Network: `mihomo/rules/*.yaml`
- Script: `brew_backup_restore.sh`
- Terminal: [iTerm2 可迁移配置](iterm2/README.md)（偏好导出与恢复脚本）
- Tool Chain: [Mac / Linux Tool Chain](toolchain.md)

## 快速恢复

```bash
brew bundle --file ./Brewfile
ln -sf "$(pwd)/.zshrc" ~/.zshrc
ln -sf "$(pwd)/.p10k.zsh" ~/.p10k.zsh
ln -sf "$(pwd)/.vimrc" ~/.vimrc
ln -sf "$(pwd)/.tmux.conf" ~/.tmux.conf
source ~/.zshrc
```

`Brewfile` 同时安装 iTerm2 与 MesloLGS Nerd Font；完成安装后再导入偏好。

iTerm2 偏好恢复（先退出 iTerm2）：

```bash
./iterm2/install.sh
```

## Shell 配置（~/.zshrc）

- 框架：Oh My Zsh + Powerlevel10k（含即时提示）
- 插件：`git`、`jj`、`uv`、`pnpm`、`docker-compose`、`z`、`you-should-use`、`tmux`、`jjma`、`p10k-jj-status`、`zsh-autosuggestions`、`zsh-syntax-highlighting`
- JJ 提示：`zsh-jj` 提供 `vcs_info` 的 JJ 后端（仅加载其 `functions/`，不 source 会重设 `PROMPT` 的完整插件）；`p10k-jj-status` 提供异步 JJ working-copy 段，需在 `.p10k.zsh` 的 `POWERLEVEL9K_LEFT_PROMPT_ELEMENTS` 或 `RIGHT_PROMPT_ELEMENTS` 中加入 `jj_status`
- PATH：`~/.local/bin`、`~/.opencode/bin`、pnpm、Maven、Go（GOPROXY 腾讯镜像）、Rust（rsproxy.cn）、fnm（Node）
- 别名 / 函数：
  - eza 列表：`ls`、`ll`、`lla`、`lld`、`llf`、`lt`、`lt3`、`lt4`
  - uv：`ur`、`ua`、`us`、`uvp`
  - 工具：`c`（clear）、`y`（yazi）、`t`（history）、`wattage`、`myip`、`nvup`（Neovim 插件/Mason 更新）、`flushdns`、`ipv6on`、`ipv6off`、`mkcd`、`extract`、`ff`、`port`
  - 时区：`tz jp|sg|la|system`（默认系统时区，需要时用 `tz` 临时切换）
  - 代理：`proxyon` / `proxyoff`（127.0.0.1:7890）
- AI CLI（详见下节）：`codex` 包装函数、`ai upgrade`

## AI Agent Coding 工具

版本以各工具 `--version` 实测为准（下表为 2026-08-20 数据）。

| 工具 | 定位 | 安装 | 维护 / 升级 |
|------|------|------|-------------|
| OpenAI Codex | 本地代码 agent | `curl -fsSL https://chatgpt.com/codex/install.sh | sh`（非交互：`CODEX_NON_INTERACTIVE=1 sh`；装在 `~/.codex/packages/standalone`，入口 `~/.local/bin/codex`） | `ai upgrade codex`（同上） |
| Antigravity agy | agent CLI / workflow | `curl -fsSL https://antigravity.google/cli/install.sh | bash`（`~/.local/bin/agy`） | `ai upgrade agy` / `agy update` |
| herdr | 多 agent 编排 CLI / runtime | `curl -fsSL https://herdr.dev/install.sh | sh`（或 `brew install herdr`） | `ai upgrade herdr` / `herdr update` |
| Otty | 终端 / agent 辅助入口 | Otty 应用内 Shell Integration 安装（`~/.local/bin/otty`） | 应用内更新 |
| opencode | 本地 agent | `curl -fsSL https://opencode.ai/install | bash`（`~/.opencode/bin/opencode`） | `opencode upgrade` |

常用入口（来自 `~/.zshrc`）：

- Codex：`cx` / `cxp`（默认 YOLO；`p` 后缀启用一次性代理）
- Codex 推理摘要：默认隐藏；`cxa` 自动、`cxc` 简短、`cxd` 详细、`cxn` 关闭；`cx -r` 打开选择菜单，快捷命令支持追加参数，例如 `cxd resume --last`
- Claude：`cc` / `ccp`（默认 YOLO；`p` 后缀启用一次性代理）
- Claude 交互显示：`ccn` 简洁（关闭 verbose）、`ccd` 详细（开启 verbose）；代理入口为 `ccpn` / `ccpd`。`cc` / `ccp` 沿用原生显示设置。支持原有参数，例如 `ccd --continue`、`ccn sg plan`。
- 显示开关保留交互会话，不改变思考强度。Codex 控制模型提供的推理摘要；Claude 的 verbose 展开工具输出和执行细节，会话中可按 `Ctrl+O` 查看详细记录。
- agy：`ag` / `agp` / `agy` / `agyp`（默认 YOLO；`p` 后缀启用一次性代理）
- 模型：默认不传 `--model`，由各 CLI 选择当前默认模型；需要固定时使用 `cx|cc|agy --model <model>`
- 模型选择：`ai help cx model list`（`cc` / `agy` 同理）；选中后作为当前 shell 默认，`model default` 恢复 CLI 默认
- 默认地区：`cc region set la` / `cx region set sg`；`region current` 查看，`region reset` 恢复内置默认。可选 `sg`、`la`、`tokyo`、`kl`、`taipei`，同时设置 timezone 和 locale。各 CLI 分别保存，显示和代理快捷命令共用所属 CLI 的设置。
- 地区配置保存在 `${XDG_CONFIG_HOME:-$HOME/.config}/ai-cli/regions/`，新终端生效。单次地区参数和 `--timezone` / `--locale` 可覆盖默认设置；未保存时 `cx` / `cc` 使用新加坡，其余使用洛杉矶。
- 帮助：`cc help` / `cx help` / `cxd help` / `agy help`；保留 `ai help` / `ai help cx|cc|agy` 和 `--env-help`。`--help` 继续转发给原生 CLI。
- 升级：`ai upgrade`（无参数时升级整套 AI toolchain：codex / agy / herdr / opencode；也可单升如 `ai upgrade codex`；实现在 `~/.config/zsh/ai-upgrade.zsh`）

> 注：上述版本为 2026-08-20 实测（codex-cli 0.148.0、agy 1.1.15、opencode 1.18.18、herdr 0.8.2、otty 1.4.1）。版本以各自 `--version` 为准，可用 `ai upgrade` 单独或整套刷新。

## 插件文档

- `gcma` — AI 生成 Conventional Commits 提交信息，支持 Gemini / Claude / Codex / Copilot
  - 详细说明：[`.oh-my-zsh/custom/plugins/gcma/README.md`](.oh-my-zsh/custom/plugins/gcma/README.md)
  - 可选配置：

    ```zsh
    export GCMA_DEFAULT_AGENT=agy
    # Set GCMA_DEFAULT_MODEL only when you want to pin a model.
    ```

- `jjma` — 为当前 jj change 生成 Conventional Commit 描述，支持大 diff 分块总结
  - 详细说明：[`.oh-my-zsh/custom/plugins/jjma/README.md`](.oh-my-zsh/custom/plugins/jjma/README.md)
  - 默认配置：

    ```zsh
    export JJMA_DEFAULT_AGENT=agy
    ```

- `zsh-jj` / `p10k-jj-status` — JJ 状态提示组件
  - 详细说明：[`.oh-my-zsh/custom/plugins/zsh-jj/README.md`](.oh-my-zsh/custom/plugins/zsh-jj/README.md)、[`.oh-my-zsh/custom/plugins/p10k-jj-status/README.md`](.oh-my-zsh/custom/plugins/p10k-jj-status/README.md)
  - 安装到 Oh My Zsh：

    ```bash
    cp -R .oh-my-zsh/custom/plugins/zsh-jj ~/.oh-my-zsh/custom/plugins/
    cp -R .oh-my-zsh/custom/plugins/p10k-jj-status ~/.oh-my-zsh/custom/plugins/
    ```

## 说明

- 默认面向 `macOS + zsh + Homebrew`。
- 配置包含个人化 alias、代理和路径设置，使用前建议先审阅并按需裁剪。
