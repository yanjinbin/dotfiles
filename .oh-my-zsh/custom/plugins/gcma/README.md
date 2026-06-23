# gcma plugin

`gcma` 是一个用于生成 Git 提交信息的 Oh My Zsh 插件，支持 `agy`、`claude`、`codex` 三种 agent。

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
  - `agy`（使用其自身已配置的 session，仅检查命令是否在 PATH）
  - `claude`（`claude auth login`）
  - `codex`（`codex login`）

## 配置默认 agent / model（可选）

在 `~/.zshrc` 中设置环境变量：

```bash
# agy（默认 agent）
export GCMA_DEFAULT_AGENT=agy
export GCMA_DEFAULT_MODEL="Gemini 3.1 Pro (High)"

# Claude
export GCMA_DEFAULT_AGENT=claude
export GCMA_DEFAULT_MODEL=sonnet
```

**注意**：`GCMA_DEFAULT_MODEL` 仅对默认 agent 生效。通过 CLI 显式指定不同 agent 时（如 `gcma claude`），使用该 agent 的内置默认 model，`GCMA_DEFAULT_MODEL` 不生效。

不设置则退回到 `agy + "Gemini 3.5 Flash (Medium)"`。

## Agent 默认 model

| Agent  | 默认 model                 | model 校验 |
|--------|----------------------------|-----------|
| agy    | Gemini 3.5 Flash (Medium)  | 白名单校验 |
| claude | sonnet                     | 透传       |
| codex  | gpt-5.3-codex              | 透传       |

agy 合法 model：

- `Gemini 3.5 Flash (Medium)`
- `Gemini 3.5 Flash (High)`
- `Gemini 3.5 Flash (Low)`
- `Gemini 3.1 Pro (Low)`
- `Gemini 3.1 Pro (High)`
- `Claude Sonnet 4.6 (Thinking)`
- `Claude Opus 4.6 (Thinking)`
- `GPT-OSS 120B (Medium)`

## 使用

先暂存你要提交的改动：

```bash
git add <files>
```

查看帮助：

```bash
gcma --help
```

使用配置的默认 agent（或 agy）：

```bash
gcma
```

指定 agent / model（覆盖环境变量）：

```bash
gcma agy "Gemini 3.1 Pro (High)"
gcma claude sonnet
gcma claude claude-sonnet-4-6
gcma codex gpt-5.3-codex
```

## gcma!（amend 上一个 commit）

`gcma!` 是 amend 变体，类似 oh-my-zsh 的 `gcan!`：重新生成提交信息并 **修改（amend）上一个 commit**，而不是新建 commit。

```bash
gcma!                          # 用默认 agent 重新生成信息并 amend HEAD
gcma! claude sonnet            # 指定 agent / model 同样适用
```

关键区别：`gcma!` 的上下文是 **上一个 commit 的 diff + 当前暂存的 diff 合并在一起**（等价于 `git diff --cached HEAD~1`）。因此生成的提交信息会同时考虑「上次提交的改动」和「这次新暂存的改动」，再整体 amend 到 HEAD。

- 若 HEAD 是仓库的根 commit（没有父 commit），则与空树比较，仍可 amend。
- 仅在确认 `y` 后才执行 `git commit --amend -m "..."`。
- 没有任何可提交内容（相对 HEAD~1 的 diff 为空）时会报错。

## 运行模式

- 输入上下文为 3 段：`summary + name-status + unified diff`
- diff 使用 `--unified=0 --minimal` 压缩上下文（减少 token）
- 不截断原始变更行（added/removed lines 保留）
- 本地校验提交信息格式：
  - Conventional Commits（type 在 `feat/fix/docs/style/refactor/test/chore/ci/build/perf/revert/hotfix` 之中）
  - type 之后带 gitmoji，格式为 `type(scope): emoji message`
  - 最长 72 字符
  - 末尾不能是 `.`
- 仅在你输入 `y` 后才执行 `git commit -m "..."`
- 失败时输出完整 stderr 便于排查

## 常见问题

1. **提示未登录 / 命令未找到**
   - 确认对应 agent CLI 已在 PATH：`agy` / `claude` / `codex`
   - 按 agent 登录后重试：`claude auth login` / `codex login`
   - agy 使用其自身已配置的 session，认证失败时完整错误会直接打印

2. **提示 No staged changes**
   - 先 `git add`，再执行 `gcma`

3. **提示 Invalid format**
   - agent 输出未通过本地校验，直接重试一次或换 model

4. **提示 Invalid agy model**
   - 传入的 agy model 不在白名单中，请从上表「agy 合法 model」中选择
