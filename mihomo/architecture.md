# 订阅与分流架构

一套「单订阅源、多端渲染」的自建代理方案：软路由、桌面、安卓、iOS 共用一份节点数据和规则。

## 1. 拓扑

```
                ┌──────────── 订阅服务（VPS + nginx + oralcure-subscription）────────────┐
                │  https://<订阅域名>/subscribe/<token>?device=&dns=&format=&hosts=       │
                │                                                                        │
                │  template.yaml    mihomo 主模板（含兜底版 DNS）                          │
                │  dns-split.yaml   智能分流 DNS 覆盖（dns=split）                         │
                │  nodes.yaml       自建节点                                              │
                │  state.json       hosts 映射 + token                                    │
                │  accounts.json    账号 / 密码 hash / 每账号 hosts                        │
                └───────────────┬────────────────────────────────────────────────────────┘
                                │
        ┌──────────────┬────────┴─────────┬──────────────────┬──────────────────┐
   软路由            Windows / macOS     Android             iOS
   Nikki(mihomo)     Clash Verge Rev     FlClash             SFI(sing-box)
   YAML              YAML                YAML                JSON
```

## 2. 组件职责

| 组件 | 职责 |
|---|---|
| 订阅服务 | 把 `template + nodes + state` 渲染成各端配置；鉴权、hosts 注入、设备参数微调 |
| `template.yaml` | mihomo 主模板：fake-ip、DNS、策略组、rule-providers、规则顺序 |
| `dns-split.yaml` | 只覆盖 DNS：`dns=split` 时叠加，得到「智能分流」版本 |
| `nodes.yaml` | 自建节点（订阅里的节点也可以来自 proxy-providers） |
| `state.json` | hosts 映射、订阅 token |
| dotfiles `mihomo/rules/*` | 规则集（auto-direct / auto-proxy / 各站专用 / 拒广告），通过 jsDelivr 下发 |

## 3. 参数矩阵

| 参数 | 取值 | 说明 |
|---|---|---|
| `device` | `nikki` / `windows` / `ios` / `android` / `mobile` / `desktop` | 设备级微调（端口、TUN、allow-lan、进程模式） |
| `format` | `yaml`（默认）/ `singbox` | mihomo YAML 或 sing-box JSON |
| `dns` | `split` / `unified` | DNS 版本，见 `dns-versions.md` |
| `hosts` | `true` | 注入 hosts 映射（局域网设备名） |
| `ipv6` | `true` | 节点 IPv6 偏好 |

## 4. 各端接入

| 端 | 推荐客户端 | 链接参数 |
|---|---|---|
| 软路由 | Nikki（mihomo） | `device=nikki&dns=split&ipv6=true&hosts=true` |
| Windows / macOS | Clash Verge Rev、Mihomo Party | `device=windows&dns=split&format=yaml&hosts=true` |
| Android | FlClash、Clash Meta | `device=android&dns=split&format=yaml&hosts=true` |
| iOS | SFI（sing-box） | `device=ios&dns=split&format=singbox&hosts=true` |

只有 mihomo 内核的客户端能吃 YAML；iOS 走 sing-box JSON，不依赖 mihomo 语法。

## 5. DNS

两套版本，切换只改一个参数：

- `dns=split`：智能分流（国内 DoH → 境外 `geosite:geolocation-!cn` 走境外 DoH → 可疑结果 fallback DoT）；iOS 对应 local/remote 双 DoH
- `dns=unified`：兜底（mihomo 全部国内 DoH；iOS 明文 UDP，最大兼容）

细节见 [`dns-versions.md`](./dns-versions.md)。

要点：

- fake-ip 保留，但**微信/腾讯/音乐/苹果推送/本地域名**走真实 IP，避免「假 IP 映射失效」类故障
- 机场节点域名单独用一条 DoH 解析（`proxy-server-nameserver`），防止节点域名被污染
- `respect-rules` + `proxy-server-nameserver` 避免 DNS 走代理时的鸡蛋问题

## 6. 分流规则

顺序（简化）：

```
进程规则 → auto-proxy → auto-direct（微信/腾讯在这里）→ 广告 REJECT
        → GEOSITE,cn 直连 → 各类代理分组 → MATCH
```

- 规则托管在 dotfiles，改完推送即可，客户端按 provider interval 自动更新
- jsDelivr 有缓存，必要时 purge 或用 `?v=` 验证

## 7. 抗故障

| 环节 | 机制 |
|---|---|
| 订阅拉取失败 | 客户端保留上次配置，照常运行 |
| 规则集拉取失败 | 本地已有缓存继续用 |
| DNS 污染 | DoH/DoT + fallback-filter；关键域名走真实 IP |
| 服务端升级 | `releases/` + `current` 软链，切链即回滚 |
| 配置改动 | 全部 `*.bak.<时间戳>` 备份 |
| iOS 兼容性 | sing-box JSON 自洽（rule_set），绕开 mihomo 语法 |

## 8. 维护手册

| 想改什么 | 改哪里 | 影响范围 |
|---|---|---|
| 节点 | `nodes.yaml` | 全端 |
| 分流规则 | `mihomo/rules/*` | 全端（等 provider 刷新） |
| 智能版 DNS | `dns-split.yaml` | 所有 `dns=split` |
| 兜底版 DNS | `template.yaml` | 所有 `dns=unified` |
| hosts 映射 | 后台 Hosts 页 / `state.json` | 全端 |
| 服务端版本 | `releases/` + symlink | 全端 |

## 9. 边界

1. iOS 必须用 sing-box 内核（SFI）；Shadowrocket / Stash 不兼容这份配置
2. iOS 的 `unified` 版仍是明文 UDP（有意为之，追求兼容）
3. 订阅服务是单点：挂了只影响「新设备/重新拉取」，老设备不受影响
4. 规则集依赖 jsDelivr（有本地缓存兜底）
