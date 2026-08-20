# iTerm2 可迁移配置

这里保存当前 macOS iTerm2 3.6.11 的可迁移偏好导出，包含默认 profile 的字体、颜色、终端类型、滚动、光标、键盘和状态栏设置。

当前默认 profile 的关键偏好：

- MesloLGS Nerd Font Regular 19
- 非 ASCII 字体：MesloLGS-NF-Regular 12
- `xterm-256color`
- 无限滚动
- 不透明窗口
- 状态栏关闭（配置内保留当前状态栏布局）
- Powerlevel10k / zsh shell integration 由仓库的 `.zshrc` 管理

## 在另一台 Mac 上恢复

先安装依赖：

```bash
brew bundle --file ./Brewfile
```

退出 iTerm2 后执行：

```bash
./iterm2/install.sh
```

脚本会在导入前备份现有偏好到
`~/Library/Preferences/com.googlecode.iterm2.plist.bak-时间戳`。

然后恢复 shell：

```bash
ln -sf "$(pwd)/.zshrc" ~/.zshrc
ln -sf "$(pwd)/.p10k.zsh" ~/.p10k.zsh
source ~/.zshrc
```

配置文件已移除当前窗口坐标、最近窗口状态、安装 ID、用户目录等机器特定信息；不会迁移 iTerm2 的登录凭据或 shell 私密环境变量。

如果另一台 Mac 没有对应字体，iTerm2 会回退字体；重新运行 `brew bundle` 安装
`font-meslo-lg-nerd-font` 后再打开 iTerm2 即可。
