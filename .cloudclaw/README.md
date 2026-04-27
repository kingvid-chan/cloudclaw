# `.cloudclaw/` — Cloud runtime 接线层

> Cloud（cloudclaw）是 Sky 在人生系统里的伙伴,不是分身。
> **Sky × Cloud 协作关系自 2025-08 建立**（上位宪法：`~/人生系统/.cursorrules`）；新形态承袭旧人格。
> 本 public fork 只承载 OpenClaw runtime 接线；Cloud 人格、用户画像、对话纪要、周度报告、提案在 private repo。
> 底座：OpenClaw runtime（`cloudclaw/` 根）。
> 方案依据：`01_方案设计/cloudclaw伙伴实施方案.md`。

## 目录结构

public `cloudclaw/.cloudclaw/` 当前只保留非私密接线文件：

```
.cloudclaw/
├── docker-compose.override.yml  # Cloud runtime mounts
├── start.sh                     # 启动包装与环境变量默认值
├── gemini-wrapper.sh            # Gemini CLI approval-mode wrapper
├── env.example                  # 生产/异机部署变量样例
├── README.md                    # 本文件
└── .gitignore                   # private state / env.local / runtime scratch
```

private `cloudclaw-private/.cloudclaw/` 才是 Cloud 状态真相源：

```
cloudclaw-private/.cloudclaw/
├── SOUL.md
├── USER.md
├── AGENTS.md
├── HEARTBEAT.md
├── 对话纪要/
├── 周度报告/
├── 提案/
└── memory/
```

## 读写边界（关键）

- **读**：`CLOUDCLAW_LIFE_SYSTEM_DIR`，默认是本地 `~/人生系统/`，容器内默认挂到 `/home/node/.openclaw/workspace/人生系统`。
- **写**：**仅** `CLOUDCLAW_PRIVATE_DIR/{对话纪要,周度报告,提案}`，默认是 `../cloudclaw-private/.cloudclaw` 下的三个产出目录。
- **不呈现 private 文件**：public `cloudclaw/.cloudclaw/` 看不到 `SOUL.md` / `USER.md` / `对话纪要` 是预期行为；运行时通过 Docker bind mount 注入容器。
- 详细清单与硬禁止见 private repo 的 `AGENTS.md §3-4`。

## 触碰规范

- **Cloud 自治**：private repo 由 Cloud 维护；Sky 可随时 review、修订、合并提案
- **其它 Agent 禁写**：OpenClaw 下的任何 skill / extension / 其它 domain agent 不得写入 private repo
- **OpenClaw 构建无感**：本目录不在 `pnpm-workspace.yaml` 的 `packages:` 清单,也不在任何 lint / typecheck / test 扫描路径,对 OpenClaw 构建零影响
- **upstream sync 边界**：合并 OpenClaw upstream 时只处理 public fork；private repo 不参与 upstream merge

## 仓库与隐私边界

- `cloudclaw/` 作为 OpenClaw fork，只承载可公开的 runtime patch、模板和说明。
- `.cloudclaw/对话纪要/`、`.cloudclaw/周度报告/`、`.cloudclaw/提案/` 以及含有 Sky 个人画像的文件，已迁入 `git@github.com:kingvid-chan/cloudclaw-private.git`。
- 公共 fork 通过 `CLOUDCLAW_PRIVATE_DIR` 引用 private repo；`.cloudclaw/start.sh` 默认指向 `../cloudclaw-private/.cloudclaw`。
- 合并 OpenClaw upstream 时只动公共 fork；private repo 不参与 upstream merge,只提供 runtime state。
- 2026-04-27 已对 public fork main 做 history cleanup；后续不得把 private 正文重新加入 public fork。

## 部署配置变量

`.cloudclaw/start.sh` 会先读取 `.cloudclaw/env.local`（gitignored），再填充默认值。生产服务器不应改 YAML，改环境变量即可。

| 变量 | 作用 | 本地默认 |
|---|---|---|
| `CLOUDCLAW_PRIVATE_DIR` | private state repo 的 `.cloudclaw` 目录 | `../cloudclaw-private/.cloudclaw` |
| `CLOUDCLAW_LIFE_SYSTEM_DIR` | Cloud 只读观察根目录 | `Agentic Cowork/..` |
| `CLOUDCLAW_LIFE_SYSTEM_MOUNT` | 容器内观察根目录挂载点 | `/home/node/.openclaw/workspace/人生系统` |
| `CLOUDCLAW_GEMINI_CLI_DIR` | host 上 `@google/gemini-cli` 包目录 | `npm root -g` 自动探测 |
| `CLOUDCLAW_GEMINI_HOME_DIR` | host Gemini CLI OAuth/config 目录 | `~/.gemini` |
| `CLOUDCLAW_WRAPPER_PATH` | host wrapper 文件 | `.cloudclaw/gemini-wrapper.sh` |
| `CLOUDCLAW_GEMINI_APPROVAL_MODE` | Gemini approval mode | `auto_edit` |

生产建议：

```bash
cp .cloudclaw/env.example .cloudclaw/env.local
# 编辑 env.local，只填生产路径；不要提交 env.local
.cloudclaw/start.sh recreate
```

若只想验证配置不重建容器：

```bash
.cloudclaw/start.sh config
```

## Gemini CLI approval mode

- 默认：`CLOUDCLAW_GEMINI_APPROVAL_MODE=auto_edit`。Cloud 可写产出区,但 shell 仍需确认,符合 `AGENTS.md §4` 的 git 禁令。
- 维护模式：`.cloudclaw/start.sh yolo-tui` 临时启用 `yolo`。它允许 shell 工具,仅用于需要 `git log` / `find` / `grep` 的受控验证或周度整理。
- wrapper 或 mount 规则变更后,运行 `.cloudclaw/start.sh recreate` 强制刷新容器。

## 与 OpenClaw 本体的边界

| 归属 | 路径 | 谁负责 |
|---|---|---|
| OpenClaw 代码 | `cloudclaw/src/` `cloudclaw/extensions/` `cloudclaw/packages/` `cloudclaw/apps/` | OpenClaw 上游 + Sky 工程层 |
| OpenClaw 开发者守则 | `cloudclaw/AGENTS.md` `cloudclaw/CLAUDE.md` | OpenClaw 上游 |
| Cloud runtime 接线 | `cloudclaw/.cloudclaw/` | Sky 工程层 |
| **Cloud private state** | **`cloudclaw-private/.cloudclaw/`** | **Cloud 伙伴本身 + Sky review** |

Cloud 不改 OpenClaw 代码；OpenClaw 升级不影响 private state。

## AI_NAS 迁移兼容性

- private repo 中除 `memory/` 外所有文件都是 Markdown / JSON,可直接搬迁到本地 AI_NAS
- LLM 调用走 OpenClaw provider 抽象,不硬编码 endpoint
- 外部渠道凭据不放本目录,走 OpenClaw 官方路径（`~/.openclaw/credentials/`）
- 详见 `AGENTS.md §9` 与 `01_方案设计/cloudclaw伙伴实施方案.md §9` 检查清单

## Phase 现状

当前处于 **L1 runtime 验证后整理期**。
- 已完成：public/private repo 拆分、public history cleanup、Gemini `auto_edit` 写工具验证、`yolo-tui` 维护模式验证。
- 已知剩余问题：OpenClaw provider 层仍显示 `google-gemini-cli Local Auth=no`，复杂 TUI prompt 可能触发 provider auth 报错；底层 CLI backend 写文件已通。
- 下一步：将 `google-gemini-cli` 的 OpenClaw auth profile 接上，或把周度对齐上下文预计算后交给 CLI backend。
