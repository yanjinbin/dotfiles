# jjma plugin

`jjma` 是一个为当前 Jujutsu working-copy change（`@`）生成 Conventional Commit 描述的 Oh My Zsh 插件。默认使用 Antigravity，也支持 Claude 和 Codex。

## 安装

将插件目录复制到 Oh My Zsh 的 custom plugins：

```bash
mkdir -p ~/.oh-my-zsh/custom/plugins/jjma
cp .oh-my-zsh/custom/plugins/jjma/jjma.plugin.zsh \
  ~/.oh-my-zsh/custom/plugins/jjma/jjma.plugin.zsh
```

在 `~/.zshrc` 中启用 `jj` 和 `jjma`：

```zsh
plugins=(
  git
  jj
  jjma
)

export JJMA_DEFAULT_AGENT=agy
```

然后重载：

```bash
source ~/.zshrc
type jjma
```

## 前置依赖

- `zsh`
- `jj`
- Oh My Zsh
- 至少一个已安装并登录的 AI CLI：
  - `agy`（默认）
  - `claude`
  - `codex`

## 使用

总结当前 working-copy change：

```bash
jjma
```

指定 agent 或 model：

```bash
jjma agy "Gemini 3.1 Pro (High)"
jjma claude sonnet
jjma codex gpt-5.3-codex
```

编辑旧 change 后重新生成描述：

```bash
jj edit <change-id>
jjma

jj edit @-
jjma
```

`jj` 没有 Git 的 staged/unstaged 区分；`jjma` 总结的是调用时 `@` 相对父 revision 的全部改动。

## 大型 diff

父 shell 使用只读 `jj diff` 固定当前 `change_id` 和 `commit_id`，AI 不执行 shell 命令：

- 不超过 `204800` 字节：一次 AI 调用生成描述。
- 超过阈值：按 `262144` 字节分块总结，再聚合成一条描述。
- 默认最多 `12` 块，超过后拒绝执行，避免高费用或不完整总结。
- 分析结束和确认前都会重新校验 `commit_id`；working copy 发生变化时废弃结果。

可选配置：

```zsh
export JJMA_DIFF_FULL_BYTES=204800
export JJMA_DIFF_CHUNK_BYTES=262144
export JJMA_MAX_CHUNKS=12
export JJMA_PRINT_TIMEOUT=5m
```

允许范围：

| 环境变量 | 允许范围 |
|---|---:|
| `JJMA_DIFF_FULL_BYTES` | `1024`–`524288` |
| `JJMA_DIFF_CHUNK_BYTES` | `32768`–`524288` |
| `JJMA_MAX_CHUNKS` | `1`–`32` |

## 安全边界

- AI 只接收父 shell 已捕获的 manifest 和 diff，不读取项目或执行命令。
- Antigravity 使用 `plan + sandbox`，不需要 `--dangerously-skip-permissions`。
- AI 输出必须通过 Conventional Commits 格式、72 字符和末尾句号校验。
- 只有输入 `y` 后才会执行 `jj describe`。
- 空 change、Agent 失败、超限以及分析期间发生并发修改都会停止，不写 description。

## 查看帮助

```bash
jjma --help
```
