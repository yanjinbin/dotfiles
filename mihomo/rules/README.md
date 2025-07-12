# Mihomo 配置脱敏（仅隐藏节点信息）

目标：

- 只脱敏 `proxies:` 段里的节点敏感字段
- 其他内容保持原样不变（包括 `dns`、`sniffer`、`proxy-groups`、`rule-providers`、`rules`）

## 脱敏字段

- `server`
- `uuid`
- `password`
- `username`
- `public-key`
- `short-id`
- `sni`
- `servername`
- `Host`（如 `ws-opts.headers.Host`）

## 无损脱敏命令（只改 proxies 段）

1. 把你的原始配置保存为 `config.raw.yaml`
2. 运行下面命令生成脱敏版 `config.sanitized.yaml`

```bash
perl -0pe '
  s{(^proxies:\n)(.*?)(^proxy-groups:\n)}{
    my ($h,$b,$t)=($1,$2,$3);
    $b =~ s/(\bserver:\s*)([^,}\n]+)/$1<REDACTED_SERVER>/g;
    $b =~ s/(\buuid:\s*)([^,}\n]+)/$1<REDACTED_UUID>/g;
    $b =~ s/(\bpassword:\s*)([^,}\n]+)/$1<REDACTED_PASSWORD>/g;
    $b =~ s/(\busername:\s*)([^,}\n]+)/$1<REDACTED_USERNAME>/g;
    $b =~ s/(\bpublic-key:\s*)([^,}\n]+)/$1<REDACTED_PUBLIC_KEY>/g;
    $b =~ s/(\bshort-id:\s*)([^,}\n]+)/$1<REDACTED_SHORT_ID>/g;
    $b =~ s/(\bsni:\s*)([^,}\n]+)/$1<REDACTED_SNI>/g;
    $b =~ s/(\bservername:\s*)([^,}\n]+)/$1<REDACTED_SERVERNAME>/g;
    $b =~ s/(\bHost:\s*)([^,}\n]+)/$1<REDACTED_HOST>/g;
    $h.$b.$t
  }gemsx;
' config.raw.yaml > config.sanitized.yaml
```

## 写入 README 的方式

如果你要把“脱敏后配置”贴到 `mihomo/rules/README.md` 作为范本：

```bash
{
  echo '# Mihomo 脱敏配置范本';
  echo;
  echo '```yaml';
  cat config.sanitized.yaml;
  echo '```';
} > mihomo/rules/README.md
```

## 自查

- [ ] `proxies:` 外的内容是否完全未改
- [ ] `proxy-groups` 引用的节点名是否保留
- [ ] 所有敏感字段是否都已替换

## 安全提醒

你刚才贴出的配置含真实凭据，建议立即轮换：`uuid/password/public-key/short-id/账号口令`。
