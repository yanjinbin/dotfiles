# dotfiles

个人 macOS 开发环境配置：zsh、终端、AI CLI、编辑器与网络规则。以仓库作为配置源，通过文件级软链接同步到本机；管理范围见 [`symlinks.json`](symlinks.json)。

## 目录

- [Install · 安装 OpenCode](#install--安装-opencode)
- [Usage · 让 Agent 初始化 macOS](#usage--让-agent-初始化-macos)
- [Uninstall · 卸载与恢复](#uninstall--卸载与恢复)
- [快速开始（手动安装）](#快速开始)
- [日常维护](#日常维护)
- [仓库结构](#仓库结构)
- [文档导航](#文档导航)
- [管理边界](#管理边界)

## Install · 安装 OpenCode

在 macOS 终端安装 [OpenCode](https://opencode.ai/v2/install)：

```bash
curl -fsSL https://opencode.ai/v2/install | bash
export PATH="$HOME/.opencode/bin:$PATH"
opencode
```

配置 DeepSeek API Key：

1. 在 [DeepSeek 控制台](https://platform.deepseek.com/) 创建 API Key。
2. 在 OpenCode 中输入 `/connect`，选择 **DeepSeek**，在凭据输入框粘贴 Key。
3. 输入 `/models`，选择可用的 DeepSeek 模型，使用 **Build** 模式执行下面的提示词。

Key 由 OpenCode 保存在本机 `~/.local/share/opencode/auth.json`，不要放进提示词或仓库。详见 [官方 DeepSeek 配置说明](https://opencode.ai/docs/providers/#deepseek)。已有能执行本机命令的 Agent，可直接跳到下一节。

## Usage · 让 Agent 初始化 macOS

复制下面整段提示词给 OpenCode 或其他本机 Agent。Agent 会获取仓库、补齐依赖并应用配置；系统密码、图形界面授权和应用登录由你操作。

```text
请使用 https://github.com/yanjinbin/dotfiles 初始化这台 Mac 的开发环境，并实际执行到验证完成。

1. 检查 macOS 架构、Xcode Command Line Tools、Git、Homebrew 和 Python 3.11+；缺失时按官方方式安装。系统密码、安装弹窗和登录交给我操作，不读取或记录凭据。
2. 当前目录若已是该仓库就直接使用，否则将 main 克隆到 ~/WebstormProjects/dotfiles；目录已存在时先核对来源和 Git 状态，不覆盖、不重置、不新建分支，也不自动提交或推送。
3. 先阅读 AGENTS.md、README.md、Brewfile、symlinks.json、scripts/sync.py、docs/shell.md 和 terminal-configs.md。简要列出安装范围，然后继续执行；按当前机器适配路径，不照搬作者的用户名、代理或私有设置。
4. 补齐 Shell 所需工具、Oh My Zsh、Powerlevel10k 和外部插件。Brewfile 是个人软件清单，先让我选择全量安装或仅安装 Shell 必需依赖；可选终端、字体、Herdr 插件和 iTerm2 偏好按对应文档及我的选择恢复。
5. 用 Python 3.11+ 运行 scripts/sync.py 预览，再运行 --apply。遇到冲突，先展示差异并保留本机设置；经我确认合并方案后才使用 --apply --replace。保留备份目录和 links.json，不删除未纳管文件，不将 API Key 或本机私有配置写入仓库。
6. 运行 scripts/sync.py --check，并在新的 zsh 会话中检查启动报错、PATH、提示符和已安装工具。修复本次初始化产生的问题，最后列出已完成、待人工处理、备份位置和恢复方式；未完成项不得宣称通过。
```

后续维护可直接告诉 Agent：“按本仓库 README 检查并修复配置同步，先审阅差异，保留本机私有配置。”手动操作见下方[快速开始](#快速开始)和[日常维护](#日常维护)。

## Uninstall · 卸载与恢复

仓库目前没有自动卸载命令。保留仓库和备份，先把下面提示词交给 Agent；恢复并验证完成后，再决定是否删除仓库。

```text
请撤销这台 Mac 上的 dotfiles 配置同步。先读取仓库 symlinks.json、scripts/sync.py，以及 ${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backups/ 下的 links.json，展示恢复计划供我确认。
只解除仍指向本仓库或其 .local/codex/ 生成文件的纳管软链接；先保存当前内容，再根据备份记录恢复安装前的文件。存在多次备份时先核对顺序，不把中间状态当作原始配置；没有原文件备份时，说明情况并让我选择保留独立副本或移除链接。
保留后来修改的普通文件、凭据、会话和未纳管内容。不批量卸载 Homebrew 软件，不删除整个 ~/.config、~/.oh-my-zsh 或仓库。iTerm2 导入及单独安装的应用、插件、字体另列处理。最后检查新 zsh 会话能正常启动，并报告未恢复项。
```

如需同时卸载 OpenCode，先预览再执行；以下命令保留配置及会话数据（[官方卸载说明](https://opencode.ai/docs/cli/#uninstall)）：

```bash
opencode uninstall --dry-run --keep-config --keep-data
opencode uninstall --keep-config --keep-data
```

## 快速开始

以下为手动安装流程；已通过 Agent 完成初始化可跳过。

适用环境：macOS、zsh、Homebrew、Python 3.11+。以下命令均在仓库根目录执行。

### 1. 准备环境

先核对本机与仓库的配置差异，保留需要的设置。根据需要安装 [`Brewfile`](Brewfile) 中的软件：

```bash
brew bundle --file ./Brewfile
```

首次恢复还需准备 Oh My Zsh、Powerlevel10k 和外部插件，见 [Shell 与插件](docs/shell.md)。Otty、Herdr.app、字体和 Herdr 插件按 [终端配置](terminal-configs.md) 与 [恢复 prompt](docs/herdr-restore-prompt.md) 准备。

### 2. 预览并建立软链接

```bash
python3 scripts/sync.py
python3 scripts/sync.py --apply
python3 scripts/sync.py --check
```

默认只预览；`--apply` 遇到内容差异会拒绝覆盖。先审阅并合并差异，再使用：

```bash
python3 scripts/sync.py --apply --replace
```

脚本只替换清单中的文件，保留所在目录及其他内容。当前实现会将被替换文件保存到 `${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backups/`；`links.json` 记录对应关系。

### 3. 加载配置

打开新终端，或重新加载 Shell：

```zsh
source ~/.zshrc
```

iTerm2 偏好单独导入，执行前先退出 iTerm2，详见 [iTerm2 恢复说明](iterm2/README.md)：

```bash
./iterm2/install.sh
```

## 日常维护

| 任务 | 入口 |
| --- | --- |
| 修改 Shell、提示符或插件 | 编辑 [`.zshrc`](.zshrc)、[`.p10k.zsh`](.p10k.zsh) 或 [自定义插件](.oh-my-zsh/custom/plugins/)；重新加载 Shell |
| 检查软链接 | `python3 scripts/sync.py --check` |
| 预览同步差异 | `python3 scripts/sync.py` |
| 调整 AI CLI 的模型、地区、显示和代理 | [AI CLI 使用指南](docs/ai-cli.md)；`ai help` / `cx help` / `cc help` |
| 升级 AI CLI | `ai upgrade`，或指定工具，如 `ai upgrade codex` |
| 修改 Codex / Claude 的共享指令 | [`AGENTS.md`](AGENTS.md)，两者的全局指令文件共用此源 |
| 修改或导入 Codex 偏好 | [配置合成与导入流程](agents/README.md#codex-settings-and-private-state) |
| 恢复 Herdr 插件 | [可复制的恢复 prompt](docs/herdr-restore-prompt.md) |

应用升级若用原子写入替换了软链接，`--check` 会检出；先把新设置合并回仓库，再重新建立链接。配置通过链接修改后，可用 `git diff` 检查待提交内容。

## 仓库结构

```text
.
├── README.md
├── AGENTS.md
├── symlinks.json
├── scripts/sync.py
├── .zshrc
├── .p10k.zsh
├── .oh-my-zsh/           # Shell plugins
├── .config/             # Terminal and CLI settings
├── agents/              # Codex and Claude settings and hooks
├── docs/                # Usage guides and recovery prompt
├── fonts/               # Herdr font snapshots and licenses
├── iterm2/              # Preferences and import script
├── mihomo/rules/        # Network rules
├── tests/               # CLI and sync checks
├── Brewfile
├── brew_backup_restore.sh
├── terminal-configs.md
└── toolchain.md
```

编辑器配置另存于 [`.vimrc`](.vimrc)、[`.spacemacs`](.spacemacs)、[`settings.json`](settings.json) 和 [`launch.json`](launch.json)。仓库中存在某个文件，不代表同步脚本会安装它；以链接清单为准。

## 文档导航

| 文档 | 内容 |
| --- | --- |
| [Shell 与插件](docs/shell.md) | 加载顺序、PATH、常用别名、JJ 提示与插件配置 |
| [AI CLI 使用指南](docs/ai-cli.md) | Codex / Claude / agy 快捷命令、模型、地区代码、帮助与升级 |
| [Codex / Claude 配置](agents/README.md) | 共享指令、hooks、私有状态及配置导入 |
| [Tern、Otty、Herdr 与 Herdr.app](terminal-configs.md) | 配置位置、换行、主题、字体与插件恢复 |
| [Herdr 恢复 prompt](docs/herdr-restore-prompt.md) | 固定插件版本、源码依赖、认证与验证步骤 |
| [Herdr 字体](fonts/README.md) | Meslo、JetBrains 定制字体、图标字体、校验值与安装步骤 |
| [iTerm2 配置](iterm2/README.md) | 偏好导入和字体依赖 |
| [Mac / Linux 工具链](toolchain.md) | 工具分类与使用场景 |
| [网络规则审计](mihomo/network-audit.md) | Mihomo 规则检查记录 |

## 管理边界

- **直接链接**：Shell、已纳管插件、终端配置、Claude 设置及两套工具的全局指令文件。
- **合成后链接**：Codex 主配置由公开偏好和本机私有状态合成到忽略目录 `.local/codex/`；修改通用设置后需重新运行同步脚本。
- **单独恢复**：应用、外部插件、字体和 iTerm2 偏好。Herdr 的 `plugins.json` 是参考快照，不能直接替代插件安装。
- **留在本机**：凭据、会话、缓存、授权记录及 Shell 私有配置 `~/.config/zsh/private.zsh`。提交前检查新增配置和环境变量，避免把私密信息带入公开仓库。
