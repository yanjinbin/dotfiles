# gcma plugin

`gcma` 是一个用于生成 Git 提交信息的 Oh My Zsh 插件，支持 `codex`、`claude`、`gemini`、`copilot` 四种 agent。

## 安装

### 方式 A（推荐）：已克隆本仓库

1. 确认插件文件存在：`.oh-my-zsh/custom/plugins/gcma/gcma.plugin.zsh`
2. 确认 `~/.zshrc` 的 `plugins=(...)` 中包含 `gcma`（放在 `zsh-syntax-highlighting` 前）
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
source ~/.zshrc
```

## 前置依赖

- `git`（必须）
- 至少安装并登录一个 agent CLI：
  - `codex`（`codex login`）
  - `claude`（`claude auth login`）
  - `gemini`（直接使用，认证失败时会给出提示）
  - `gh copilot`（`gh auth login -h github.com`）

## 配置默认 agent / model（可选）

在 `~/.zshrc` 中设置环境变量：

```bash
# Gemini（推荐）
export GCMA_DEFAULT_AGENT=gemini
export GCMA_DEFAULT_MODEL=gemini-3.1-pro-preview

# Claude
export GCMA_DEFAULT_AGENT=claude
export GCMA_DEFAULT_MODEL=sonnet
```

**注意**：`GCMA_DEFAULT_MODEL` 仅对默认 agent 生效。通过 CLI 显式指定不同 agent 时（如 `gcma claude`），使用该 agent 的内置默认 model，`GCMA_DEFAULT_MODEL` 不生效。

不设置则退回到 `codex + gpt-5.3-codex`。

## Agent 默认 model

| Agent   | 默认 model           | model 校验   |
|---------|----------------------|-------------|
| codex   | gpt-5.3-codex        | 透传         |
| claude  | sonnet               | 透传         |
| gemini  | gemini-2.5-pro       | 白名单校验   |
| copilot | gpt-5-mini           | 透传         |

Gemini 合法 model：`gemini-3.1-pro-preview` · `gemini-3-flash-preview` · `gemini-3.1-flash-lite-preview` · `gemini-2.5-pro` · `gemini-2.5-flash`

## 使用

先暂存你要提交的改动：

```bash
git add <files>
```

查看帮助：

```bash
gcma --help
```

使用配置的默认 agent（或 codex）：

```bash
gcma
```

指定 agent / model（覆盖环境变量）：

```bash
gcma codex gpt-5.3-codex
gcma claude sonnet
gcma claude claude-sonnet-4-6
gcma gemini gemini-3.1-pro-preview
gcma gemini gemini-2.5-pro
gcma gemini gemini-2.5-flash
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
- 失败时输出完整 stderr 便于排查

## 常见问题

1. **提示未登录**
   - 按 agent 登录后重试：`codex login` / `claude auth login` / `gh auth login -h github.com`
   - gemini 认证失败时完整错误会直接打印

2. **提示 No staged changes**
   - 先 `git add`，再执行 `gcma`

3. **提示 Invalid format**
   - agent 输出未通过本地校验，直接重试一次或换 model

4. **gemini alias 冲突**
   - 插件内部使用 `command gemini` 调用，绕过 `~/.zshrc` 中的 `gemini` alias，不会出现 `--model` 重复传入的问题
