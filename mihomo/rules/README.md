# Mihomo 规则集 & Shadowrocket 配置

本目录维护自定义分流规则，同时提供对应的 Shadowrocket 专用配置。

## 目录结构

```
mihomo/
├── yunyufen.conf          # Shadowrocket 专用配置（内联所有自定义规则）
└── rules/
    ├── *.yaml             # Mihomo (Clash Meta) 格式规则集
    ├── *.list             # Surge / Shadowrocket 格式规则集（与 .yaml 一一对应）
    └── icons/             # 代理分组图标
```

## 自定义规则说明

| 文件 | 用途 | 策略 |
|------|------|------|
| `claude-pro` | Claude / Anthropic 完整域名 + IP 段 | 代理（日本出口） |
| `claude+` | Claude 核心域名精简版 | 代理（日本出口） |
| `emby-direct` | Emby 直连服务器列表 | 直连 |
| `emby-proxy` | Emby 需代理的服务器列表 | 代理 |
| `tailscale` | Tailscale 虚拟网段 + 控制域名 | 直连 |
| `bypass` | 绕过广告拦截的白名单 | 直连 |
| `auto-proxy` | 默认需要代理的域名（VSCode 等） | 代理 |
| `apns` | Apple Push Notification Service | 代理 |
| `doubaoime-block` | 豆包输入法遥测 / 日志域名 | 拒绝 |
| `gemini-plus` | Antigravity (Gemini) 补充域名 | 代理（美国出口） |
| `twitter-video` | Twitter / X 视频流域名 | 代理（油管组） |
| `dns-doh-proxy` | DoH 服务器域名 | 代理 |
| `privacy-reject` | 通用隐私遥测域名 | 拒绝 |
| `livekit` | LiveKit 实时通信域名 | 代理 |
| `apple+` | Apple 全系域名合并版（blackmatrix7） | 代理 |

## 双格式说明

同名规则同时提供两种格式：

- **`.yaml`** — Mihomo (Clash Meta) `rule-providers` 格式，`payload:` 结构
- **`.list`** — Surge / Shadowrocket `RULE-SET` 格式，每行一条规则

jsdelivr CDN 引用地址：

```
# Mihomo (.yaml)
https://cdn.jsdelivr.net/gh/yanjinbin/dotfiles@master/mihomo/rules/<name>.yaml

# Shadowrocket (.list)
https://cdn.jsdelivr.net/gh/yanjinbin/dotfiles@master/mihomo/rules/<name>.list
```

## Shadowrocket 配置

`yunyufen.conf` 是完整的 Shadowrocket 配置，对应 `yunyufen.yaml` (Mihomo) 的分流逻辑。

**导入地址：**
```
https://cdn.jsdelivr.net/gh/yanjinbin/dotfiles@master/mihomo/yunyufen.conf
```

**代理分组结构：**

```
🌐 节点选择          ← 兜底出口
  ├── ♻️ 自动选择    ← url-test 自动测速
  ├── 🛡️ 故障转移   ← fallback 故障切换
  ├── 🗽 美国出口    ← 住宅IP直连 / 链式
  └── 🗼 日本出口    ← 住宅IP直连 / 链式

🔌 美国中转          ← 住宅IP链式中转节点（手动加入订阅节点）
🔌 日本中转          ← 住宅IP链式中转节点（手动加入订阅节点）

🪬 Claude专用        ← Anthropic / Claude 域名
AI双链路             ← OpenAI / Gemini / Google / Copilot
油管                 ← YouTube / YouTube Music
社交媒体             ← Twitter / LinkedIn
TikTok媒体           ← TikTok / Telegram
流媒体               ← Netflix / HBO / Disney
Spotify-音乐         ← Spotify
Emby-观影代理        ← Emby 代理服务器
```

**使用步骤：**
1. 在「服务器」页面添加机场订阅（极风 / 渔舍 / 良心云 / 赔钱）
2. 导入配置文件 URL
3. 进「代理设置」，为各分组勾选对应地区的订阅节点
4. 全局路由切到「规则」，开启 VPN

## 三方规则集来源

| 来源 | 用途 |
|------|------|
| [blackmatrix7/ios_rule_script](https://github.com/blackmatrix7/ios_rule_script) | Apple / Google / 流媒体 / 社交等主流规则 |
| [TG-Twilight/AWAvenue-Ads-Rule](https://github.com/TG-Twilight/AWAvenue-Ads-Rule) | 广告拦截 |

## 配置脱敏

提交前需脱敏 `proxies:` 段里的节点敏感字段（`server` / `uuid` / `password` / `username`）：

```bash
perl -0pe '
  s{(^proxies:\n)(.*?)(^proxy-groups:\n)}{
    my ($h,$b,$t)=($1,$2,$3);
    $b =~ s/(\bserver:\s*)([^,}\n]+)/$1<REDACTED>/g;
    $b =~ s/(\buuid:\s*)([^,}\n]+)/$1<REDACTED>/g;
    $b =~ s/(\bpassword:\s*)([^,}\n]+)/$1<REDACTED>/g;
    $b =~ s/(\busername:\s*)([^,}\n]+)/$1<REDACTED>/g;
    $h.$b.$t
  }gemsx;
' config.raw.yaml > config.sanitized.yaml
```
