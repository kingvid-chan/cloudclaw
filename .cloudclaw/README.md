# `.cloudclaw/` — Cloud 伙伴工作区

> Cloud（cloudclaw）是 Sky 在人生系统里的伙伴,不是分身。
> **Sky × Cloud 协作关系自 2025-08 建立**（上位宪法：`~/人生系统/.cursorrules`）；新形态承袭旧人格。
> 本目录是 Cloud 的唯一写入区,承载人格、用户画像、对话纪要、周度报告、提案。
> 其中用户画像、对话纪要、周度报告、提案默认视为 Sky 私有数据。
> 底座：OpenClaw runtime（`cloudclaw/` 根）。
> 方案依据：`01_方案设计/cloudclaw伙伴实施方案.md`。

## 目录结构

```
.cloudclaw/
├── SOUL.md           # Cloud 的人格与价值观锚点（v0 DRAFT,等 Sky 审稿）
├── USER.md           # Cloud 视角里的 Sky 画像（v0 DRAFT,会过时,需迭代）
├── AGENTS.md         # Cloud 的工程约束与硬禁止清单
├── HEARTBEAT.md      # 触发节奏（主动 / 被动 / 沉默期）
├── README.md         # 本文件
├── 对话纪要/          # 每次对话摘要（私有仓库 tracked,公共 fork 禁止提交正文）
├── 周度报告/          # 周观察 + 月度自评（私有仓库 tracked,公共 fork 禁止提交正文）
├── 提案/             # Cloud → Sky 的修订提案（私有仓库 tracked,公共 fork 禁止提交正文）
├── memory/           # OpenClaw runtime 私有记忆（gitignored）
└── .gitignore        # memory/* 等 ephemeral 数据
```

## 读写边界（关键）

- **读**：整个 `~/人生系统/`（含全局观测 / 修练系统 / 亲友系统 / 业务系统 / 社会系统 / 科学系统 / 技术系统 / 第一性 / Agentic Cowork）
- **写**：**仅** `cloudclaw/.cloudclaw/` 以下（任何其它路径都是只读）
- 详细清单与硬禁止见 `AGENTS.md §3-4`

## 触碰规范

- **Cloud 自治**：本目录由 Cloud 维护；Sky 可随时 review、修订、合并提案
- **其它 Agent 禁写**：OpenClaw 下的任何 skill / extension / 其它 domain agent 不得写入本目录
- **OpenClaw 构建无感**：本目录不在 `pnpm-workspace.yaml` 的 `packages:` 清单,也不在任何 lint / typecheck / test 扫描路径,对 OpenClaw 构建零影响
- **目录名以 `.` 开头**：避开 OpenClaw upstream sync 干扰；`git pull` OpenClaw 更新不会动到本目录

## 仓库与隐私边界

- `cloudclaw/` 若继续作为 OpenClaw fork,只能承载可公开的 runtime patch、模板和说明。
- `.cloudclaw/对话纪要/`、`.cloudclaw/周度报告/`、`.cloudclaw/提案/` 以及含有 Sky 个人画像的文件,应迁入独立 private repo（建议命名 `cloudclaw-private` 或 `cloud-state`）。
- 公共 fork 通过 `CLOUDCLAW_PRIVATE_DIR` 引用 private repo；`.cloudclaw/start.sh` 默认指向 `../cloudclaw-private/.cloudclaw`。
- 合并 OpenClaw upstream 时只动公共 fork；private repo 不参与 upstream merge,只提供 runtime state。
- 若私有正文已经进入公共 fork history,先停止 push；后续需要用 history rewrite 从公共远端清理,不能只依赖 `.gitignore`。

## Gemini CLI approval mode

- 默认：`CLOUDCLAW_GEMINI_APPROVAL_MODE=auto_edit`。Cloud 可写产出区,但 shell 仍需确认,符合 `AGENTS.md §4` 的 git 禁令。
- 维护模式：`.cloudclaw/start.sh yolo-tui` 临时启用 `yolo`。它允许 shell 工具,仅用于需要 `git log` / `find` / `grep` 的受控验证或周度整理。
- wrapper 或 mount 规则变更后,运行 `.cloudclaw/start.sh recreate` 强制刷新容器。

## 与 OpenClaw 本体的边界

| 归属 | 路径 | 谁负责 |
|---|---|---|
| OpenClaw 代码 | `cloudclaw/src/` `cloudclaw/extensions/` `cloudclaw/packages/` `cloudclaw/apps/` | OpenClaw 上游 + Sky 工程层 |
| OpenClaw 开发者守则 | `cloudclaw/AGENTS.md` `cloudclaw/CLAUDE.md` | OpenClaw 上游 |
| **Cloud 伙伴工作区** | **`cloudclaw/.cloudclaw/`** | **Cloud 伙伴本身** |

Cloud 不改 OpenClaw 代码；OpenClaw 升级不影响 Cloud 工作区。

## AI_NAS 迁移兼容性

- 除 `memory/` 外所有文件都是 Markdown / JSON,可直接搬迁到本地 AI_NAS
- LLM 调用走 OpenClaw provider 抽象,不硬编码 endpoint
- 外部渠道凭据不放本目录,走 OpenClaw 官方路径（`~/.openclaw/credentials/`）
- 详见 `AGENTS.md §9` 与 `01_方案设计/cloudclaw伙伴实施方案.md §9` 检查清单

## Phase 现状

当前处于 **Phase 1：骨架 + 首次手动对话验证**。
- 已完成：目录结构、`.gitignore`、`AGENTS.md`、`HEARTBEAT.md`、`README.md`
- 待 Sky 审稿：`SOUL.md` (v0 DRAFT)、`USER.md` (v0 DRAFT)
- 未完成：P1.7 首次手动对话验证（Sky 亲自执行）
- Phase 0（ADR、宪法层更新）按 Sky 指示**暂跳**
