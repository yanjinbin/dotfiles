# dotfiles

个人 macOS 开发环境配置：zsh、终端、AI CLI、编辑器与网络规则。以仓库作为配置源，通过文件级软链接同步到本机；管理范围见 [`symlinks.json`](symlinks.json)。

## 目录

- [快速开始](#快速开始)
- [日常维护](#日常维护)
- [仓库结构](#仓库结构)
- [文档导航](#文档导航)
- [管理边界](#管理边界)

## 快速开始

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
