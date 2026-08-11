# dotfiles

macOS 开发环境配置仓库，集中管理终端、编辑器、包管理与网络规则。

## 仓库内容

- Shell: `.zshrc`、`.p10k.zsh`、`.oh-my-zsh/`（插件与命令）
- Editor: `.vimrc`、`.spacemacs`、`settings.json`、`launch.json`
- Package: `Brewfile`
- Network: `mihomo/rules/*.yaml`
- Script: `brew_backup_restore.sh`
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

## Shell 配置（~/.zshrc）

- 框架：Oh My Zsh + Powerlevel10k（含即时提示）
- 插件：`git`、`jj`、`uv`、`pnpm`、`docker-compose`、`z`、`you-should-use`、`tmux`、`jjma`、`p10k-jj-status`、`zsh-autosuggestions`、`zsh-syntax-highlighting`
- PATH：`~/.local/bin`、`~/.opencode/bin`、pnpm、Maven、Go（GOPROXY 腾讯镜像）、Rust（rsproxy.cn）、fnm（Node）
- 别名 / 函数：
  - eza 列表：`ls`、`ll`、`lla`、`lld`、`llf`、`lt`、`lt3`、`lt4`
  - uv：`ur`、`ua`、`us`、`uvp`
  - 工具：`mkcd`、`extract`、`ff`、`port`、`myip`、`flushdns`、`ipv6on`、`ipv6off`
  - 时区：`tz jp|sg|la|system`（默认 `America/Los_Angeles`）
  - 代理：`proxyon` / `proxyoff`（127.0.0.1:7890）
- AI CLI（详见下节）：Claude 隐私开关与权限别名、`codex` 包装函数、`ocx_service`、`ai upgrade`

## AI Agent Coding 工具

版本以各工具 `--version` 实测为准（下表为 2026-08-10 数据）。

| 工具 | 定位 | 安装 | 维护 / 升级 |
|------|------|------|-------------|
| Claude Code | 长上下文 agent CLI | `npm install -g @anthropic-ai/claude-code` | `ai upgrade claude` |
| OpenAI Codex | 本地代码 agent | 官方 standalone 包（`~/.codex/packages/standalone`，入口 `~/.local/bin/codex`） | `ai upgrade codex`（走 GitHub release，不占 API quota） |
| Antigravity agy | agent CLI / workflow | `curl -fsSL https://antigravity.google/cli/install.sh | bash`（`~/.local/bin/agy`） | `ai upgrade agy` / `agy update` |
| OpenCodeX ocx | Codex 网关 / 代理服务 | `npm install -g @bitkyc08/opencodex` + `ocx service install`（launchd 常驻） | `ocx_service update` / `ocx update` |
| Otty | 终端 / agent 辅助入口 | Otty 应用内 Shell Integration 安装（`~/.local/bin/otty`） | 应用内更新 |
| opencode | 本地 agent | `curl -fsSL https://opencode.ai/install | bash`（`~/.opencode/bin/opencode`） | `opencode upgrade` |

常用入口（来自 `~/.zshrc`）：

- Claude：`cc`（跳过权限确认）、`cc-bypass`、`cc-auto`、`cc-edit`、`cc-plan`、`cc-ask`；隐私 `claude-private` / `claude-normal` / `claude-status`
- Codex：`cx`（默认 `--yolo` + high reasoning）、`cx-safe`、`cx-never`、`cx-request`、`cx-untrusted`
- agy：`ag`、`ag-edit`、`ag-plan`
- OCX 服务：`ocxon` / `ocxoff` / `ocxstatus` / `ocxr` / `ocxh` / `ocxd` / `ocxl`
- 升级：`ai upgrade [claude|codex|agy]`（无参数时全部升级；实现在 `~/.config/zsh/ai-upgrade.zsh`）

> 注：上述版本为 2026-08-10 实测（codex-cli 0.147.0、agy 1.1.10、opencodex 2.10.2、otty 1.3.1、opencode 1.18.16）；Claude Code 当时未安装（未出现在 PATH 中），安装后请用 `ai upgrade claude` 校验。

## 插件文档

- `gcma` — AI 生成 Conventional Commits 提交信息，支持 Gemini / Claude / Codex / Copilot
  - 详细说明：[`.oh-my-zsh/custom/plugins/gcma/README.md`](.oh-my-zsh/custom/plugins/gcma/README.md)
  - 快速配置：

    ```zsh
    export GCMA_DEFAULT_AGENT=gemini
    export GCMA_DEFAULT_MODEL=gemini-3.1-pro-preview
    ```

- `jjma` — 为当前 jj change 生成 Conventional Commit 描述，支持大 diff 分块总结
  - 详细说明：[`.oh-my-zsh/custom/plugins/jjma/README.md`](.oh-my-zsh/custom/plugins/jjma/README.md)
  - 默认配置：

    ```zsh
    export JJMA_DEFAULT_AGENT=agy
    ```

## 说明

- 默认面向 `macOS + zsh + Homebrew`。
- 配置包含个人化 alias、代理和路径设置，使用前建议先审阅并按需裁剪。
