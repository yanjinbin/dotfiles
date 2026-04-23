# gcma plugin

`gcma` 是一个用于生成 Git 提交信息的 Oh My Zsh 插件，支持 `codex`、`claude`、`copilot` 三种 agent。

## 安装

### 方式 A（推荐）：已克隆本仓库

1. 确认插件文件存在：`.oh-my-zsh/custom/plugins/gcma/gcma.plugin.zsh`
2. 确认 `~/.zshrc` 的 `plugins=(...)` 中包含 `gcma`
3. 重载 shell：

```bash
source ~/.zshrc
```

### 方式 B：仅安装 gcma 插件到 Oh My Zsh

```bash
git clone --depth=1 --filter=blob:none --sparse https://github.com/yanjinbin/dotfiles.git ~/.oh-my-zsh/custom/plugins/gcma
cd ~/.oh-my-zsh/custom/plugins/gcma
git sparse-checkout set .oh-my-zsh/custom/plugins/gcma
cp .oh-my-zsh/custom/plugins/gcma/gcma.plugin.zsh ./gcma.plugin.zsh
```

然后在 `~/.zshrc` 的 `plugins=(...)` 里加上 `gcma`，再执行：

```bash
source ~/.zshrc
```

## 更新

```bash
cd ~/.oh-my-zsh/custom/plugins/gcma
git pull
cp .oh-my-zsh/custom/plugins/gcma/gcma.plugin.zsh ./gcma.plugin.zsh
source ~/.zshrc
```

## 前置依赖

- `git`（必须）
- 至少安装并登录一个 agent CLI：
  - `codex`（`codex login`）
  - `claude`（`claude auth login`）
  - `gh copilot`（`gh auth login -h github.com`）

## 使用

先暂存你要提交的改动：

```bash
git add <files>
```

查看帮助：

```bash
gcma --help
```

默认使用 `codex`：

```bash
gcma
```

指定 agent / model：

```bash
gcma codex gpt-5.3-codex
gcma claude sonnet
gcma copilot gpt-5-mini
```

## 运行模式

- 输入上下文为 3 段：`summary + name-status + unified diff`
- diff 使用 `--unified=0 --minimal` 压缩上下文（减少 token）
- 不截断原始变更行（added/removed lines 保留）
- 本地校验提交信息格式：
  - Conventional Commits
  - 最长 72 字符
  - 末尾不能是 `.`
- 仅在你输入 `y` 后才执行 `git commit -m "..."`

## 常见问题

1. 提示未登录
- 按 agent 登录后重试：`codex login` / `claude auth login` / `gh auth login -h github.com`

2. 提示 No staged changes
- 先 `git add`，再执行 `gcma`

3. 提示 Invalid format
- 说明 agent 输出未通过本地校验，直接重试一次或换 model
