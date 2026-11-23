# 订阅图标 (mihomo/rules/icons)

供 `oralcure-subscription` 订阅模板通过 jsDelivr 引用：

```
https://testingcf.jsdelivr.net/gh/yanjinbin/dotfiles@main/mihomo/rules/icons/<name>.webp
```

## 约定

- 根目录只放**当前订阅模板在用或准备上线**的图标，新图标优先转成 WebP。
- 命名：
  - `<service>.webp`：默认/单色版本，例如 `openai.webp`、`claude.webp`。
  - `<service>-color.webp`：彩色版本，例如 `claude-color.webp`、`claudecode-color.webp`。
  - 地区用英文小写，例如 `hongkong.webp`、`usa.webp`、`netherlands.webp`。
- 转换参数：照片类用 `cwebp -q 90 -alpha_q 100`，纯色 logo 用 `cwebp -lossless -z 9`。
- SVG 仅在需要无损缩放时保留，不参与订阅引用。

## 遗留格式

以下非 WebP 文件仅用于兼容已经缓存的旧订阅，不再新增引用：

| 文件 | 替代 |
| --- | --- |
| `e.png` | `e.webp` |
| `youtube-02.png` | `youtube-02.webp` |
| `google-color.png` | `google-color.webp` |
| `openai.png` | `openai.webp` |
| `usa.png` | `usa.webp` |
| `caishenye.jpeg` | 暂无，仅线上旧模板引用 |

确认旧订阅已过期后可以删除。

## `_unused/`

未被任何仓库配置引用的历史图标，已归档到这里，可安全删除或按需移回根目录。
