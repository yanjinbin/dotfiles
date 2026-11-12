# ImmortalWRT + Nikki/Mihomo 网络优化审查

> 适用：ImmortalWRT 25.12 + Nikki 透明代理。固件大版本升级后需重新执行 sysctl 部分。

---

## 一、审查 Prompt（可复用）

发给 Claude，自动 SSH 收集信息并审查。需确保路由器 SSH 无密码可达。

```
我有一台 ImmortalWRT 路由器（Nikki 透明代理），请 SSH 进去做网络优化审查。
路由器：root@192.168.1.1
Mihomo 配置文件：[yaml 路径]

第一步，执行以下命令收集信息：

ssh root@192.168.1.1 "
cat /etc/config/network
cat /etc/config/firewall
cat /etc/config/dhcp
cat /etc/config/nikki
sysctl -a 2>/dev/null | grep -E 'tcp_congestion|default_qdisc|tcp_fastopen|rmem|wmem|rps|rfs|conntrack'
tc qdisc show
cat /proc/interrupts | grep -E 'eth|wlan'
cat /proc/cpuinfo | grep processor | wc -l
free -m
opkg list-installed 2>/dev/null | grep -E 'homeproxy|nikki'
ls /var/run/homeproxy/ 2>/dev/null || echo 'homeproxy not running'
"

第二步，按以下维度逐项分析，给出优先级（🔴/🟡/🟢）和修复命令：

【系统层】
- IRQ 分布：各核中断是否均衡，MSI-X 队列利用率，RPS/RFS 是否开启
- TCP 拥塞控制：是否 BBR，qdisc 是否适合 PPPoE（CAKE > fq_codel）
- 流量卸载：透明代理下 flow_offloading 必须为 0，确认是否正确
- IPv6 一致性：Nikki ipv6_proxy/ipv6_dns_hijack 与 Mihomo ipv6 设置是否矛盾
- 僵尸 firewall include：已卸载插件（homeproxy 等）留下的死 include 块
- PPPoE：norelease、mtu_fix、MTU=1492 是否配置

【Mihomo YAML】
- DNS：respect-rules 与 #RULES 是否矛盾；default-nameserver 单点；proxy-server-nameserver 含未知第三方
- 代理组 lazy：url-test/fallback/load-balance 的 lazy:true 导致冷启动盲选；provider health-check.interval 与 group interval 错配
- 僵尸 rule-provider：定义了但 rules 里从未引用的规则集
- 规则路由：YouTube 与 googleapis.com 是否分流到不同组；apple-music 路由是否与其他音乐服务一致
- 电源组：dialer-proxy 命名与实际节点范围是否一致（如东京住宅 IP 是否走日本节点）
- 安全：secret 是否为空
```

---

## 二、R5C 优化清单（ImmortalWRT 25.12.0）

| 优先级 | 类别 | 问题 | 修复 | 状态 |
|--------|------|------|------|------|
| 🔴 | 系统 | IRQ 不均：CPU1 空闲，eth0/eth1 各 32 队列只有 4 个工作 | 手动设 `/proc/irq/*/smp_affinity` 分散到 4 核 | 待做 |
| 🔴 | Nikki | IPv6 proxy 开启但 Mihomo 全部 REJECT，双重处理 | `ipv6_proxy=0`, `ipv6_dns_hijack=0`, `dns_ipv6=0` | ✅ |
| 🔴 | 防火墙 | homeproxy 未安装但留有 3 个死 include，fw4 报错 | 删 `/etc/config/firewall` 中 homeproxy_forward/input/post | ✅ |
| 🟡 | 系统 | TCP 拥塞控制为 CUBIC | 改 BBR（已写入 sysctl.conf）| ✅ |
| 🟡 | 系统 | tcp_mtu_probing=0，conntrack_max 默认值偏小 | 见下方 sysctl 部分 | ✅ |
| 🟡 | Mihomo | 关键代理组 `lazy: true`，YouTube 等冷启动延迟 | 删除 `sakuracat-测试` 等组的 `lazy: true` | 待做 |
| 🟡 | Mihomo | Provider health-check 300s vs Group interval 60s 错配 | Provider 改为 60s | 待做 |
| 🟡 | Mihomo | `respect-rules: false` 但 nameserver 带 `#RULES`（死配置） | 删除 `#RULES` 后缀 | 待做 |
| 🟡 | Mihomo | googleapis.com 与 YouTube 分流到不同策略组 | YouTube 规则前补 googleapis.com | 待做 |
| 🟡 | Mihomo | 东京住宅 IP 经"🔌 🇭🇰"（含 SG/KR）出口，链路绕远 | 拆出 `🔌 🇯🇵` 专用日本电源组 | 待做 |
| 🟢 | Mihomo | `emby-direct` provider 定义但未引用 | 补规则或删 provider | 待做 |
| 🟢 | Mihomo | `ChinaMedia`、`IPTVMainland`、`STUN` 僵尸 provider | 删除 | 待做 |
| 🟢 | Mihomo | `default-nameserver` 单点（仅 223.5.5.5） | 加 `119.29.29.29` | 待做 |
| 🟢 | Mihomo | `proxy-server-nameserver` 含未知 `sh.dns44.cn` | 删除，只留 223.5.5.5 | 待做 |
| 🟢 | Mihomo | `Crypto` + `Cryptocurrency` 规则集大量重叠 | 合并或删其一 | 待做 |
| 🟢 | Mihomo | `apple-music` 走通用入口而非 `🎵音乐` 组 | 改路由 | 待做 |
| 🟢 | Mihomo | `keep-alive-idle: 600` 路由器场景偏长 | 改为 60-120s | 待做 |

---

## 三、已执行：系统参数优化

### sysctl（/etc/sysctl.conf）

```bash
# 去重后写入，sysctl -p 立即生效
for key in net.core.rmem_max net.core.wmem_max \
           net.ipv4.tcp_rmem net.ipv4.tcp_wmem \
           net.ipv4.tcp_mtu_probing net.netfilter.nf_conntrack_max \
           net.ipv4.tcp_fastopen; do
  sed -i "/^${key}/d" /etc/sysctl.conf
done

cat >> /etc/sysctl.conf << 'EOF'
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.ipv4.tcp_mtu_probing=1
net.netfilter.nf_conntrack_max=131072
net.ipv4.tcp_fastopen=3
EOF

sysctl -p
```

**验证：**
```bash
sysctl net.core.rmem_max net.core.wmem_max net.ipv4.tcp_mtu_probing \
       net.netfilter.nf_conntrack_max net.ipv4.tcp_fastopen \
       net.ipv4.tcp_rmem net.ipv4.tcp_wmem
```

### Nikki UCI

```bash
uci set nikki.mixin.log_level='error'
uci set nikki.log.scheduled_clear_cron='*/30 * * * *'
uci set nikki.log.scheduled_clear_size_limit='5'
uci set nikki.log.scheduled_clear_size_limit_unit='MB'
uci commit nikki && service nikki restart
```

**验证：**
```bash
uci show nikki.mixin.log_level nikki.log.scheduled_clear_cron \
         nikki.log.scheduled_clear_size_limit nikki.log.scheduled_clear_size_limit_unit
```

---

## 四、2026-11-12 追加：R5C 实测修正

起因：Android 微信发送图片偶发失败（红色感叹号），失败瞬时；同一 Wi-Fi 下 macOS 微信正常，手机切移动数据正常。

排查结论：微信域名在规则层已是 `GEOSITE,cn → DIRECT`，但 **DIRECT 只表示不走节点，流量仍需经 mihomo 转发**。真正的风险在 mihomo 之外：

| 优先级 | 问题 | 实际值 | 修复 |
|--------|------|--------|------|
| 🔴 | 流量卸载未关（透明代理下必须为 0，见第一节） | `flow_offloading=1`、`flow_offloading_hw=1` | 均设 `0` 后 `fw4 reload` |
| 🟡 | 双 DNS 劫持：fw4 `DNSMASQ HIJACK` 与 nikki `redirect to :1053` 叠加 | `dns_redirect=1` | 设 `0`，DNS 只由 nikki 劫持 |
| 🟡 | dnsmasq 最短缓存过长，CDN 节点 IP 被锁死 | `min_cache_ttl=3600` | 改 `300` |
| 🟡 | 快速重载保留旧连接，易产生僵尸连接 | `fast_reload=1` | 改 `0`；`clear_connections_on_reload` 保持 `1` |
| 🟡 | mihomo DNS fallback 用 DoT 853，走代理节点失败后反复重试（实测 26 分钟失败 564 次） | `tls://8.8.4.4`、`tls://1.1.1.1` | 通过 `mixin.yaml` 清空 `fallback`，分流交给 `nameserver-policy` |

### 执行

```bash
uci set firewall.@defaults[0].flow_offloading='0'
uci set firewall.@defaults[0].flow_offloading_hw='0'
uci set dhcp.cfg01411c.dns_redirect='0'
uci set dhcp.cfg01411c.min_cache_ttl='300'
uci set nikki.procd.fast_reload='0'
uci commit firewall && uci commit dhcp && uci commit nikki
fw4 reload
/etc/init.d/dnsmasq restart
```

`fast_reload` 与 `clear_connections_on_reload` 在下次重载时生效，无需重启 nikki。

### 验证

```bash
# 流量卸载必须为空
nft list table inet fw4 | grep -c flowtable          # 期望 0
# 只剩 nikki 的 DNS 劫持
nft list ruleset | grep -c "DNSMASQ HIJACK"          # 期望 0
# 配置值
uci get firewall.@defaults[0].flow_offloading
uci get dhcp.cfg01411c.dns_redirect
uci get nikki.procd.fast_reload
```

### 回滚

```bash
uci set firewall.@defaults[0].flow_offloading='1'
uci set firewall.@defaults[0].flow_offloading_hw='1'
uci set dhcp.cfg01411c.dns_redirect='1'
uci set dhcp.cfg01411c.min_cache_ttl='3600'
uci set nikki.procd.fast_reload='1'
uci commit firewall && uci commit dhcp && uci commit nikki && fw4 reload
```

### 注意

- LuCI 的 Nikki 页面保存时会按页面勾选状态写回 `nikki.procd.*`，改完别在网页上点保存。
- 试过用 nft 集合 + DSCP=4 让微信流量完全绕过 tproxy（nikki 内置 `bypass_dscp`），机制可行且已实测生效，但 IP 需脚本维护、微信 HTTPDNS 覆盖不全，最终放弃，保持规则层 DIRECT。
- `dns.fallback` 已在 `/etc/nikki/mixin.yaml` 清空，并置 `nikki.mixin.mixin_file_content=1`。改动前用 yq 模拟过一次合并：`dns.fallback` 变空、其余 dns 键与规则数不变。**需要重启 nikki 才生效**（重启会中断当前连接 2～5 秒）。

### mihomo DNS 剖析（mixin.yaml）

原则：**不用 fallback**。fallback 的语义是"两套解析并发 + 按 geoip 结果择一"，在"国内 + 代理"的组合下，未命中就要等超时，解析时快时慢（实测 26 分钟 564 次 DoT 失败）。分流交给 `nameserver-policy` 更直接。

```yaml
dns:
  fallback: []
  default-nameserver:              # 引导解析 DoH 域名，单点 223.5.5.5 太薄
    - 223.5.5.5
    - 119.29.29.29
  proxy-server-nameserver:         # 解析代理节点域名，必须不依赖代理
    - https://doh.pub/dns-query
    - https://dns.alidns.com/dns-query
  nameserver:                      # 国内域名
    - https://doh.pub/dns-query
    - https://dns.alidns.com/dns-query
  nameserver-policy:               # 国外域名走代理上的 DoH
    geosite:geolocation-!cn:
      - https://1.1.1.1/dns-query
      - https://8.8.8.8/dns-query
```

实测的 DoH 延迟（路由器直连）：`doh.pub` 147ms、`dns.alidns.com` 137ms、`sh.dns44.cn:44443` 800ms。第三方那个慢 5 倍，已从 `proxy-server-nameserver` 移除。
