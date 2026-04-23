# dotfiles

macOS 开发环境配置仓库，集中管理终端、编辑器、包管理与网络规则。

## 仓库内容

- Shell: `.zshrc`、`.p10k.zsh`、`.oh-my-zsh/`（插件与命令别名）
- Editor: `.vimrc`、`.spacemacs`、`settings.json`、`launch.json`
- Package: `Brewfile`（Homebrew taps/brews/casks 快照）
- Network: `mihomo/rules/*.yaml`（自定义分流与拦截规则）
- Script: `Homebrew_backup.sh`（导出 Brewfile 与基础工具安装脚本）

## 快速恢复

```bash
brew bundle --file ./Brewfile
ln -sf "$(pwd)/.zshrc" ~/.zshrc
ln -sf "$(pwd)/.p10k.zsh" ~/.p10k.zsh
ln -sf "$(pwd)/.vimrc" ~/.vimrc
ln -sf "$(pwd)/.tmux.conf" ~/.tmux.conf
```

## 说明

- 默认面向 `macOS + zsh + Homebrew`。
- 配置包含个人化 alias、代理和路径设置，使用前建议先审阅并按需裁剪。
