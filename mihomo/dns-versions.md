# DNS 分流版本说明

订阅服务（aliyun-yanjinbin / sub.oralcure.icu）提供两套 DNS 版本，用 `dns=` 参数切换。

## A. 默认版：智能分流（`dns=split`）

| 域名类型 | 上游 | 查询次数 |
|---|---|---|
| 国内域名 | doh.pub / dns.alidns.com（国内 DoH） | 1 |
| 境外主流域名（geosite:geolocation-!cn） | 1.1.1.1 / 8.8.8.8（境外 DoH） | 1 |
| 境外未收录域名 | 国内 DoH → 结果非 CN → fallback（tls://8.8.4.4 / tls://1.1.1.1） | 2 |
| 腾讯/微信/音乐/本地设备 | 真实 IP（不进 fake-ip） | 1 |
| 机场节点域名 | 223.5.5.5 + https://sh.dns44.cn:44443/dns-query | 1 |

- `respect-rules: true`（DNS 走代理时也能解析节点域名）
- `fake-ip` + 白名单（微信/腾讯、音乐、苹果推送、本地域名走真实 IP）
- 适用：**日常使用**

## B. 兜底版：全国内 DoH（`dns=unified`）

- 所有域名 → doh.pub / dns.alidns.com，**无 fallback、无境外 DNS、无策略表**
- `respect-rules: false`（不依赖代理）
- `fake-ip` + 同一份白名单
- 代价：境外域名解析质量可能下降（但走代理的流量由代理端解析域名，影响有限）

适用：**代理节点异常、境外 DNS 不通、出差/弱网、排查问题时**

## 版本选择

| 场景 | 用哪个 |
|---|---|
| 日常 | A（默认） |
| 代理挂了/境外 DNS 超时 | B |
| 怀疑境外解析被污染 | A |
| 排查“某站打不开” | 先切 B 再 dig 对比 |

## iOS / sing-box 的 DNS

iOS 走 `format=singbox`，DNS 由服务端单独渲染：

| 版本 | local-dns | remote-dns | final |
|---|---|---|---|
| `dns=split` | `https://223.5.5.5/dns-query`（SNI `dns.alidns.com`，direct） | `https://1.1.1.1/dns-query`（SNI `cloudflare-dns.com`，走代理组） | `remote-dns` |
| `dns=unified` | `udp://223.5.5.5` | `udp://119.29.29.29` | `local-dns` |

split 版规则：`geosite-cn` → local-dns，其余 → remote-dns，即「国内直查、国外经代理 DoH」，与服务端 mihomo 的思路一致。

## 链接模板

```
Nikki / 路由：
  A: https://sub.oralcure.icu/subscribe/<token>?device=nikki&dns=split&ipv6=true&hosts=true
  B: https://sub.oralcure.icu/subscribe/<token>?device=nikki&dns=unified&ipv6=true&hosts=true

Windows / MacBook（Clash Verge Rev / Mihomo Party）：
  A: ...?device=windows&dns=split&format=yaml&hosts=true
  B: ...?device=windows&dns=unified&format=yaml&hosts=true

Android（FlClash / Clash Meta）：
  A: ...?device=android&dns=split&format=yaml&hosts=true
  B: ...?device=android&dns=unified&format=yaml&hosts=true

iOS（sing-box / SFI）：
  A: ...?device=ios&dns=split&format=singbox&hosts=true
  B: ...?device=ios&dns=unified&format=singbox&hosts=true
```

`<token>` 在 `/var/lib/oralcure-subscription/state.json` 或后台账号页。

## 切换后生效

- Nikki：`/etc/init.d/nikki update_subscription oralcure && /etc/init.d/nikki reload`
- 其他客户端：更新订阅即可

## 验证

```bash
# 解析结果（fake-ip 正常）
dig @192.168.1.1 www.baidu.com +short

# mihomo 实际解析链路
curl -s -H "Authorization: Bearer <secret>" \
  "http://127.0.0.1:9090/dns/query?name=www.google.com&type=A"

# 当前生效版本
grep -E "nameserver-policy|respect-rules" /etc/nikki/run/config.yaml
```

## 维护约定

- 两套版本**共用同一份 fake-ip 白名单**（在 `template.yaml`），改一处两端同时生效
- A 版的境外 DNS 依赖代理（`respect-rules`）；如果代理长期不可用，请切 B
- 服务端文件：`template.yaml`（B 版 DNS 基线）、`dns-split.yaml`（A 版覆盖）
