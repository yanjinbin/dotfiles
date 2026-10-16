# Otty、Herdr 与 Herdr.app 配置

配置快照来自本机 2026-10-16 的文件。通过 `symlinks.json` 按文件建立软链接，仓库作为配置源。

## 配置位置

| 组件 | 仓库路径 / 本机相对 `$HOME` 路径 | 内容 |
| --- | --- | --- |
| Otty | `.config/otty/config.toml` | Apple Graphite 主题、字体、复制行为、Shell Integration 和项目标签 |
| Otty 主题 | `.config/otty/themes/` | 包含 Apple Graphite、One Dark Unified 等主题 |
| Otty 字体 | `.config/otty/fonts/` | Herdr Agent Icons Max 图标字体 |
| Herdr CLI / daemon | `.config/herdr/config.toml` | 快捷键、侧栏、配额显示及配色 |
| Herdr.app | `.config/herdr/config-gpui.local.toml` | GUI 布局、字体、字号、状态图标和交互偏好 |
| Herdr 插件偏好 | `.config/herdr/plugins/config/` | Agent Usage 和 Radar 的个人设置 |
| Herdr 插件清单 | `.config/herdr/plugins.json` | 已安装插件、版本、来源及固定 commit 的参考快照 |
| Herdr Shell 集成 | `.oh-my-zsh/plugins/herdr/herdr.plugin.zsh` | 官方别名、补全和 `hrdrs` 会话选择器 |

Herdr.app 的 `config-gpui.toml` 文件头明确说明它是自动生成的默认值，启动和 GUI 配置重载时会更新。个人修改放在 `config-gpui.local.toml`，未设置的字段继承默认值，表按字段合并。因此仓库只保存个人覆盖文件。

本机 `so.pen.herdr-gpui.plist` 中没有主题或字体设置；主要是文件选择器状态，另有 `NSAutoFillHeuristicControllerEnabled=false`。不复制目录书签和窗口状态。如需恢复该开关，在退出 Herdr.app 后执行：

```bash
defaults write so.pen.herdr-gpui NSAutoFillHeuristicControllerEnabled -bool false
```

不收录会话、socket、锁、日志、缓存、备份或 `Library/Application Support` 中的数据库及认证状态。已有插件源码快照保留，但不作为新机器上的插件注册入口。

## 恢复配置

先安装 Otty、Herdr CLI、Herdr.app 和所需字体。在仓库根目录预览差异，合并后创建软链接：

```bash
python3 scripts/sync.py
python3 scripts/sync.py --apply
python3 scripts/sync.py --check
```

脚本自动备份被替换的配置；有内容差异时先审阅，确认合并结果后用 `--apply --replace`。只链接个人配置、主题、字体及插件偏好，不链接整个应用目录。插件注册表仍由 Herdr 管理。

Otty 的 Shell Integration 由应用提供，仓库 `.zshrc` 按 `OTTY_SHELL_INTEGRATION` 加载。不要复制临时目录中的 Otty CLI 或 integration 文件。

当前字体依赖包括 `MesloLGS NF Herdr`、`MesloLGS NF Herdr Fit`、`JetBrains Mono Herdr`、`MesloLGL Nerd Font` 和 `JetBrains Mono`。这些字体的本机 Regular 文件已收录到 [`fonts/`](fonts/README.md)，并附校验值和许可证；按其中的恢复步骤安装到 `~/Library/Fonts/`。两个 Herdr 图标字体版本均保留，Otty 原有版本不重复存储。Otty 的应用内字体目录不会替 Herdr.app 安装字体。

## 恢复 Herdr 插件

`plugins.json` 含本机绝对路径，是参考快照，不直接复制到新机器。通过 CLI 重建注册信息；下列来源与 commit 对应本次快照，`--ref` 已通过本机 CLI 帮助核对：

```bash
herdr plugin install jeffarese/herdr-bar --ref 5dbc33404218f23e16c724a5675534c96fb67882
herdr plugin install mrolafsson/herdr-linear --ref b6da0a22c832769af58810f7748fa6973f9a6704
herdr plugin install hhdebb/herdr-radar --ref 2425fa080b7b72f30c1299481282b23003a2ee61
herdr plugin install NathanFlurry/herdr-plugin-jj-workspace --ref ee71c3ce112ce97b494f4f77a92ac8589df12274
```

Agent Usage 来自本地开发仓库。先恢复其源码与构建依赖，再按实际路径注册：

```bash
herdr plugin link "$HOME/WebstormProjects/herdr-agent-usage"
```

安装动作可能调整配置；完成后对比并恢复上面的主配置和插件偏好。Linear 等服务需要在新机器上单独登录。恢复步骤不会迁移认证数据。

启动应用并检查主题、字体和插件状态。已有 Herdr daemon 时，可按需重载配置：

```bash
herdr plugin list
herdr server reload-config
```

完整可复制的执行指令见 [Herdr 恢复 prompt](docs/herdr-restore-prompt.md)。插件安装、认证及应用重启应在恢复时单独验证。
