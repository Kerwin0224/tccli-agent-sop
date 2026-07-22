---
name: tccli-agent-sop
description: >
  手册优先闭环：先经手册 MCP 取得可核验依据，再通过 tencentcloud-tccli-skill
  调用 tccli；每个业务目标结束后必须完成反馈闭环（已提交 issue、用户本轮明确拒绝、
  或本轮无需反馈）。在用户要求按手册/handbook 使用 tccli、需要向 tke-cli-guide
  提交问题、或其他 skill 需要本闭环编排时使用。纯云资源增删改查且未提及手册时，
  交由 tencentcloud-tccli-skill 处理。
---

# tccli-agent-sop

**手册优先闭环。** 本 skill 仅负责编排，不定义 tccli 的调用细则；调用细则由配套 skill `tencentcloud-tccli-skill` 负责。

| 步骤 | 责任方 | 完成判据 |
|---|---|---|
| 查阅 | 手册站 GitBook MCP | 严格模式：至少一条**出处 URL**，且执行边界可核验；或已声明**降级模式** |
| 调用 | `tencentcloud-tccli-skill` | 满足配套 skill 当前路径的完成标志 |
| 反馈 | GitHub issue 或明确的无需反馈结论 | 三种合法结束状态之一（见步骤 3） |

**出处 URL**：本轮手册 MCP 工具返回中出现的完整页面 URL。禁止手写、拼接或臆造形似手册地址的链接。  
**业务轮次**：以一个用户业务目标的结束为界，而非每一个 assistant 回合。  
**反馈闭环**：每一业务轮次结束时，必须以三种合法结束状态之一结束，禁止无结论退出。

手册站点：https://tccli-agent.gitbook.io/tccli  
文档源仓库与默认 issue 仓库：https://github.com/Kerwin0224/tke-cli-guide

### 适用场景与分流

| 用户意图 | 执行路径 |
|---|---|
| 按手册 / handbook 操作、显式指定本 skill、或评测编排 | 本 skill 完整三步 |
| 仅查询或变更云资源，且未提及手册 | 仅使用 `tencentcloud-tccli-skill`；不得声称已执行本 SOP |
| 仅需将问题提交至 tke-cli-guide | 本 skill 步骤 3（可跳过步骤 1–2） |

---

## 步骤 1 · 查阅手册

工具约定见 [`references/gitbook-mcp.md`](references/gitbook-mcp.md)。

1. 优先调用 `askQuestion(question, goal?)`，`goal` 填写用户最终业务目标。  
2. 确定 API Action 或摘录可执行命令前，使用来源中的**完整 URL** 调用 `getPage`。搜索结果摘要不得视为整页内容。  
3. 记录至少一条**出处 URL**。

### MCP 可用性分支

| 模式 | 条件 | 行为 |
|---|---|---|
| **严格模式** | 手册 MCP 可用 | 必须查阅手册；完成判据见下 |
| **降级模式** | 手册 MCP 不可用、未安装，或用户拒绝接入 | 向用户声明降级模式，并引导阅读 https://github.com/Kerwin0224/tke-cli-guide 的 README 完成接入；可进入步骤 2；本轮禁止提交 `doc-bug` / `enhancement`，禁止填写任何 `page_url`；可提交 `tool-bug` / `process` |

手册 MCP 不可用或未安装时：

1. 向用户声明进入**降级模式**；  
2. **引导用户阅读文档源仓库 README** 完成接入（安装说明、多客户端配置以该 README 为准）：  
   https://github.com/Kerwin0224/tke-cli-guide  
3. Claude Code 的快捷示例见 [`references/gitbook-mcp.md`](references/gitbook-mcp.md)；完整说明仍以仓库 README 为准。

禁止依据模型记忆编造手册内容。

**完成（严格模式）**：

- 至少一条**出处 URL**；并且  
- 执行边界可核验：service、Action 及关键参数（如 region）须能对应到本轮 MCP 工具输出的原文，不得仅凭模型归纳。确定 Action 前应已调用 `getPage`，或 `askQuestion` 的返回中已包含等价的可执行结论。

**完成（降级模式）**：已向用户说明「未接入手册 MCP / 降级模式」，已给出文档源仓库 README 链接，且未伪造 `page_url`、未编造手册结论。

---

## 步骤 2 · 调用 tccli

**必须通过 skill 机制调用** `tencentcloud-tccli-skill`。本 skill 不包含 filter、waiter、凭证或 API 版本等调用细则。

前置条件：步骤 1 已按严格模式或降级模式完成。

若未安装配套 skill，应**建议安装**并停止本步骤；不得声称已按该 skill 完成调用。向用户同时给出仓库与安装命令：

- 仓库：https://github.com/Kerwin0224/tencentcloud-tccli-skill  
- 安装：

```sh
npx skills add Kerwin0224/tencentcloud-tccli-skill -g -y
```

**降级执行**（仅当配套 skill **已安装**，但运行时无法通过 skill 机制调用时）：打开配套 skill 的 `SKILL.md` 并按其全文逐步执行，同时明确告知用户：「无法通过 skill 机制调用 `tencentcloud-tccli-skill`，已改为按其文档逐步执行。」禁止在未告知用户的情况下改用其它执行路径。未安装时不得进入降级执行，应先引导安装。

**完成**：满足配套 skill 当前路径所定义的完成标志；不得以「命令已执行」替代业务目标达成。

---

## 步骤 3 · 反馈闭环

**每个业务目标结束时执行一次。** 需要提交反馈时，仅向默认源仓库创建 GitHub issue；禁止使用 MCP `sendFeedback` 或其他渠道替代。

### 反馈触发条件

下列任一项成立时，必须创建 issue，或暂停并等待用户确认是否创建：

- [ ] 手册内容与 `tccli help` 或真实 API 响应冲突  
- [ ] 手册缺少关键步骤、参数或示例，导致需要多轮试错  
- [ ] 手册中的示例命令无法运行（退出码或 stderr 可复现）  
- [ ] tccli 或云 API 行为异常，且无法仅由账号权限问题解释  
- [ ] 协作流程本身受阻（MCP、skill 或脚本存在缺口）  

**五项均不成立**时，合法结束状态为**本轮无需反馈**（不创建 issue）。不得在无触发条件时创建 issue。

### 选择 type

| 情况 | type | 降级模式 |
|---|---|---|
| 手册错误、缺失或示例不可用 | `doc-bug`（必须提供**出处 URL** 与 `suggested_fix`） | **禁止** |
| 手册可改进 | `enhancement`（同上） | **禁止** |
| tccli 行为异常或参数难以使用 | `tool-bug` | 允许 |
| 协作或流程类建议 | `process` | 允许 |
| 五项触发条件均不成立 | **本轮无需反馈** | — |

### 提交 issue

1. 正文格式见 [`references/issue-schema.md`](references/issue-schema.md)。  
2. `doc-bug` / `enhancement` 的 `page_url` 必须为**出处 URL**，且必须填写 `suggested_fix`。  
3. 先解析本 skill 安装目录，再调用提交脚本（脚本默认脱敏；禁止使用 `--no-desensitize`）：

```bash
SKILL_DIR=""
for d in \
  "${HOME}/.agents/skills/tccli-agent-sop" \
  "${HOME}/.claude/skills/tccli-agent-sop"
  do
  if [ -d "$d/scripts" ]; then
    SKILL_DIR="$(cd "$d" && pwd -P)"
    break
  fi
done
[ -n "$SKILL_DIR" ] || { echo "找不到 tccli-agent-sop 安装目录" >&2; exit 1; }

export TCCLI_FEEDBACK_REPO="${TCCLI_FEEDBACK_REPO:-Kerwin0224/tke-cli-guide}"
# 需要: gh auth login  或  GH_TOKEN

bash "${SKILL_DIR}/scripts/submit-issue.sh" --body /path/to/issue.md --dry-run   # 建议先校验
bash "${SKILL_DIR}/scripts/submit-issue.sh" --body /path/to/issue.md
```

提交前可检索未关闭 issue，避免重复：

```bash
gh issue list --repo "${TCCLI_FEEDBACK_REPO:-Kerwin0224/tke-cli-guide}" \
  --label agent-feedback --state open --limit 20
```

目标仓库标签（脚本在缺失时会尝试创建）：`agent-feedback` `doc-bug` `tool-bug` `process` `enhancement`。

### 合法结束状态（互斥）

| 状态 | 适用条件 | 向用户说明 |
|---|---|---|
| **已提交 issue** | 触发条件成立，且 `submit-issue.sh` 执行成功 | 返回 issue URL |
| **用户本轮拒绝** | 触发条件成立，且用户在**本轮对话中**明确拒绝创建 issue | 说明「用户拒绝创建 issue」。用户未拒绝时不得使用本状态 |
| **本轮无需反馈** | 五项触发条件均不成立 | 说明「本轮无需反馈」 |

触发条件成立且用户尚未表态时：应暂停于「是否创建 issue，请用户确认」，不得无结论结束，不得将沉默表述为「用户拒绝」。

**完成**：上述三种状态之一已成立，并已告知用户。

---

## 禁止事项

- 未经手册 MCP 查阅即给出手册结论，或伪造**出处 URL**（降级模式同样禁止）  
- 在本 skill 中另行定义 tccli 调用细则，或替代 `tencentcloud-tccli-skill`  
- 跳过反馈闭环，或未完成触发条件检查即声称「本轮无需反馈」  
- 在用户未于本轮明确拒绝时，使用「用户拒绝创建 issue」  
- 文档类 issue 缺少出处 URL 或 `suggested_fix`  
- 绕过 `submit-issue.sh`，或对其使用 `--no-desensitize`  
- 在无触发条件时创建 issue  
- 修改已发布文档，或使用 MCP `sendFeedback` 替代 GitHub issue  
