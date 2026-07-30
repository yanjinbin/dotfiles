# dotfiles

macOS 开发环境配置仓库，集中管理终端、编辑器、包管理与网络规则。

## 仓库内容

- Shell: `.zshrc`、`.p10k.zsh`、`.oh-my-zsh/`（插件与命令）
- Editor: `.vimrc`、`.spacemacs`、`settings.json`、`launch.json`
- Package: `Brewfile`
- Network: `mihomo/rules/*.yaml`
- Script: `Homebrew_backup.sh`
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
