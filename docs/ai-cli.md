# AI CLI 使用指南

[返回首页](../README.md) · [Shell 与插件](shell.md) · [Codex / Claude 配置](../agents/README.md)

快捷命令由 [`perfect-little-angle`](../.oh-my-zsh/custom/plugins/perfect-little-angle/perfect-little-angle.plugin.zsh) 提供；安装和升级逻辑见 [`ai-upgrade.zsh`](../.config/zsh/ai-upgrade.zsh)。工具版本以本机输出为准。

## 命令入口

- Codex：`cx` / `cxp`（默认 YOLO；`p` 后缀启用一次性代理）
- Codex 速度：`cx` / `cxp` 默认普通模式；`cxf` / `cxpf` 显式启用 fast，其他参数用法不变。
- Codex 推理摘要：默认隐藏；`cxa` 自动、`cxc` 简短、`cxd` 详细、`cxn` 关闭；`cx -r` 打开选择菜单，快捷命令支持追加参数，例如 `cxd resume --last`
- Claude：`cc` / `ccp`（默认 YOLO；`p` 后缀启用一次性代理）
- Claude 交互显示：`ccn` 简洁（关闭 verbose）、`ccd` 详细（开启 verbose）；代理入口为 `ccpn` / `ccpd`。`cc` / `ccp` 沿用原生显示设置。支持原有参数，例如 `ccd --continue`、`ccn sg plan`。
- 显示开关保留交互会话，不改变思考强度。Codex 控制模型提供的推理摘要；Claude 的 verbose 展开工具输出和执行细节，会话中可按 `Ctrl+O` 查看详细记录。
- agy：`ag` / `agp` / `agy` / `agyp`（默认 YOLO；`p` 后缀启用一次性代理）

## 模型与地区

- 模型：默认不传 `--model`，由各 CLI 选择当前默认模型；需要固定时使用 `cx|cc|agy --model <model>`
- 模型选择：`ai help cx model list`（`cc` / `agy` 同理）；选中后作为当前 shell 默认，`model default` 恢复 CLI 默认
- 默认地区：`cc region set la` / `cx region set NL`；`region current` 查看地区及配置路径。支持下表城市、IATA 三字码及国家/地区代码，同时设置 timezone 和 locale。各 CLI 独立配置，显示、速度和代理快捷命令共用所属 CLI 的设置。
- 唯一配置入口为 `${XDG_CONFIG_HOME:-$HOME/.config}/ai-cli/regions.conf`，通过软链接指向仓库文件。`region set` 修改链接目标，每次调用读取最新配置；旧 `regions/` 目录不再读取。单次地区参数和 `--timezone` / `--locale` 仍可临时覆盖。
- 不再提供内置默认值；配置缺失或无效时明确报错。原 `region reset` 改为提示使用 `region set` 显式选择地区。

城市名、IATA 三字码和国家/地区代码不区分大小写，临时参数、`--region` 和持久配置使用相同规则。`region set` 保存规范城市名；同一国家的其他城市需直接指定，例如 `cx NYC`、`cc KIX`（也可用 `new-york`、`osaka`）。带空格的城市名需加引号，例如 `cx "San Jose"`；也支持 `Düsseldorf` 和 `duesseldorf`。

## 地区参数参考

| 城市参数 | IATA 三字码 | 国家/地区代码 | 时区 |
| --- | --- | --- | --- |
| `amsterdam` | `AMS` | `NL` | `Europe/Amsterdam` |
| `dusseldorf` | `DUS` | — | `Europe/Berlin` |
| `frankfurt` | `FRA` | `DE` | `Europe/Berlin` |
| `tallinn` | `TLL` | `EE` | `Europe/Tallinn` |
| `london` | `LON` / `LHR` | `GB` / `UK` | `Europe/London` |
| `san-jose` | `SJC` | — | `America/Los_Angeles` |
| `new-york` | `NYC` / `JFK` | — | `America/New_York` |
| `seattle` | `SEA` | — | `America/Los_Angeles` |
| `hong-kong` | `HKG` | `HK` | `Asia/Hong_Kong` |
| `osaka` | `OSA` / `KIX` | — | `Asia/Tokyo` |
| `tokyo` | `TYO` / `HND` / `NRT` | `JP` | `Asia/Tokyo` |
| `sydney` | `SYD` | `AU` | `Australia/Sydney` |
| `la` | `LAX` | `US` | `America/Los_Angeles` |
| `sg` | `SIN` | `SG` | `Asia/Singapore` |
| `kl` | `KUL` | `MY` | `Asia/Kuala_Lumpur` |
| `taipei` | `TPE` | `TW` | `Asia/Taipei` |

`LON`、`NYC`、`TYO`、`OSA` 是城市代码；表中其他三字码是机场代码，在 CLI 中映射到对应城市。例如 `JFK` 指纽约肯尼迪机场，`HND` / `NRT` 指羽田 / 成田机场，`KIX` 指关西机场。完整机场名称见 `cx help`。代码可通过 [IATA 官方查询](https://www.iata.org/codes/index) 核对。

使用 IANA 时区处理夏令时。各地区的 locale 可通过 `cx help` 查看，使用 `--locale` 单次覆盖。

## 地区配置文件

地区配置示例：

```ini
cc=la
cx=la
agy=la
```

`sg` 对应 `Asia/Singapore` 和 `zh_CN.UTF-8`；`la` 对应 `America/Los_Angeles` 和 `en_US.UTF-8`。插件统一将 locale 应用于 `LANG` 和 `LC_ALL`，只影响 CLI 及其子进程。

本机 `~/.oh-my-zsh/custom/plugins/perfect-little-angle/perfect-little-angle.plugin.zsh` 通过软链接引用仓库同名文件；重新加载此文件或打开新终端即可生效。`.zshrc` 和自定义插件的代码注释统一使用英文。

## 帮助与升级

- 帮助：`cc help` / `cx help` / `cxd help` / `agy help`；保留 `ai help` / `ai help cx|cc|agy` 和 `--env-help`。`--help` 继续转发给原生 CLI。
- 升级：`ai upgrade`（无参数时升级整套 AI toolchain：claude / codex / agy / herdr / opencode；也可单升如 `ai upgrade codex`；实现在 `~/.config/zsh/ai-upgrade.zsh`）

```zsh
ai help
cx help
ai upgrade
ai upgrade claude
ai upgrade codex
```

Otty 通过应用内更新维护；Herdr 插件恢复见 [执行 prompt](herdr-restore-prompt.md)。
