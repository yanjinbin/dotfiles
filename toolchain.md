# Mac / Linux Tool Chain

这是一套偏个人工作流的开发工具链：macOS 为主，Linux 可复用命令行层。核心原则是把日常操作压到终端、轻 GUI 和 AI agent 里，减少需要长期维护的知识库和复杂桌面软件。

## 版本控制

| 工具 | 定位 | 使用场景 |
|------|------|----------|
| `git` | 基础版本控制 | 所有仓库的通用底座，兼容 GitHub / CI / 开源协作 |
| `lazygit` | Git TUI | 日常 stage、commit、rebase、stash、看 diff |
| `tig` | Git 历史浏览 | 快速看提交图、单文件历史和 blame |
| GitHub Desktop | Git GUI | 偶尔处理图形化 diff、冲突确认和跨仓库状态 |

## Jujutsu / JJ

`jj` 更适合频繁重写、拆分、合并本地变更的工作流，尤其适合多 agent / 多分支并行开发时保持提交历史干净。

| 工具 | 定位 | 备注 |
|------|------|------|
| `jj` | Jujutsu CLI | 核心命令行，替代一部分本地 Git 操作 |
| `jjui` | JJ TUI | 浏览 change graph，适合快速整理工作区 |
| `lazyjj` | JJ TUI / wrapper | 类 lazygit 的 JJ 操作入口 |
| `jayjay` | JJ 辅助工具 | 用于补足常见 JJ 工作流 |

学习入口：[hello-jj 教程](https://hello-jj.vercel.app)

## Editor / Agent Workspace

| 工具 | 定位 | 使用方式 |
|------|------|----------|
| Zed | 轻量编辑器 | 快速打开项目、读代码、做局部编辑 |
| Orca | Agent 工作台 | 让 Codex 等 agent 在本地仓库里执行真实任务 |
| Otty | 终端 / agent 辅助入口 | 连接命令行工作流和交互式 agent 使用 |

## Terminal / Shell

| 工具 | 定位 | 使用方式 |
|------|------|----------|
| iTerm2 | macOS 终端 | 主力终端窗口、profile、快捷键和多 pane |
| zsh | 默认 shell | alias、函数、环境变量和补全的主入口 |
| Oh My Zsh | zsh 框架 | 管理插件、主题和 shell 体验 |

Linux 上主要保留 `zsh`、常用 CLI、`lazygit`、`tig`、`jj` 这一层；iTerm2 和 macOS GUI 工具替换为系统原生终端或远程 SSH 环境。

## AI Coding

| 工具 | 定位 | 使用方式 |
|------|------|----------|
| Codex | 本地代码 agent | 面向 repo 的实现、排障、重构和验证 |
| agy | agent CLI / workflow | 快速调起自动化任务和轻量 agent 流程 |
| Claude | 长上下文推理 | 复杂方案分析、架构解释、代码审查辅助 |

AI 工具不单独作为聊天窗口使用，而是尽量落到“读仓库、改文件、跑验证、给结果”的闭环里。

## 协作

| 工具 | 定位 | 使用方式 |
|------|------|----------|
| Slack | 团队沟通 | 高频同步、异步讨论、告警和上下文入口 |
| Linear | 任务管理 | issue、roadmap、实现状态和交付跟踪 |
| Notion | 项目文档 | 轻量 PRD、会议记录、方案归档 |
| Telegram | 移动端沟通 | 第三方客户端：[Mithka](https://mithka.ieb.app/) |
| CatBar | macOS Telegram 菜单栏 | 仓库：[QuentinHsu/cat-bar](https://github.com/QuentinHsu/cat-bar) |

不使用 Obsidian：它更容易把时间耗在插件、链接、图谱和“辅助知识点练习拓扑”上。真实团队协作更需要能被任务、讨论和交付直接消费的文档，而不是个人知识库幻觉。

## 账号 / 密码 / 登录

| 工具 | 定位 | 使用方式 |
|------|------|----------|
| Google Password Manager | 密码管理器 | 保存网站账号密码，配合 Chrome / Android / Google 账号同步 |
| Google Authenticator | 二次验证 | 管理 2FA 动态验证码，给重要账号加第二层保护 |
| MacBook Touch ID | 本机生物识别 | 用指纹解锁 macOS、授权系统操作、唤起钥匙串 / 密码填充 |

账号体系尽量保持简单：密码交给 Google Password Manager，同步验证码交给 Google Authenticator，本机解锁和授权交给 MacBook Touch ID。

## Runtime / Data Tools

| 工具 | 定位 | 使用方式 |
|------|------|----------|
| Docker | 容器底座 | 本地服务、临时依赖、CI 环境对齐 |
| OrbStack | macOS 容器 / Linux VM | 替代 Docker Desktop，启动快、资源占用低 |
| Rebased | 数据库 / 变更辅助工具 | 配合本地开发和数据检查 |
| TablePro | 数据库 GUI | 查询、表结构检查、临时数据修正 |

## 安装参考

本仓库的 `Brewfile` 已经覆盖部分基础项，例如 `git`、`lazygit`、`tig`、`zsh` 生态、`orbstack`、`tmux`、`fzf`、`ripgrep`、`jq` 等。恢复主机环境时先执行：

```bash
brew bundle --file ./Brewfile
```

没有进入 `Brewfile` 的 GUI 或第三方工具，按项目官网、GitHub release 或各自推荐安装方式补齐。
