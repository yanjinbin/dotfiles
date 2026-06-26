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
