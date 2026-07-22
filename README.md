# tccli-agent-sop

> **手册优先闭环**：经手册 MCP 取得可核验依据 → 由 `tencentcloud-tccli-skill` 调用 tccli → 业务目标结束时完成反馈闭环。

## 相关仓库

| 仓库 | 角色 |
|---|---|
| [Kerwin0224/tke-cli-guide](https://github.com/Kerwin0224/tke-cli-guide) | 文档源仓库；MCP 接入与 skill 安装见该仓库首页；issue 默认提交至此 |
| [Kerwin0224/tencentcloud-tccli-skill](https://github.com/Kerwin0224/tencentcloud-tccli-skill) | 配套 skill：定义 tccli 调用方式 |
| **本仓库** | 查阅手册 → 调用配套 skill → 反馈闭环 |

```
手册站 (tke-cli-guide → GitBook)
        ↑ MCP 只读 / Issues 回写
agent ──┼── tencentcloud-tccli-skill（调用 tccli）
        └── tccli-agent-sop（编排）  ← 本 skill
```

## 范围

| 包含 | 不包含 |
|---|---|
| 手册优先的三步编排与反馈闭环 | 自动修改已发布文档 |
| 手册 MCP 不可用时的降级模式 | 替代配套 skill 的 tccli 调用说明 |
| 反馈：GitHub issue，或触发条件均不成立时的「本轮无需反馈」 | MCP 多客户端安装教程（见文档源仓库首页） |
| 纯云资源操作且未提及手册时，交由配套 skill | 使用 MCP `sendFeedback` |

步骤与完成判据以 **`SKILL.md`** 为准。issue 字段见 [`references/issue-schema.md`](references/issue-schema.md)。

## 依赖

1. 建议接入手册 MCP。未安装时，引导阅读文档源仓库 README：  
   https://github.com/Kerwin0224/tke-cli-guide  
   （Claude Code 快捷示例见 [`references/gitbook-mcp.md`](references/gitbook-mcp.md)，完整说明以该 README 为准）  
2. 步骤 2 需要 `tencentcloud-tccli-skill`。未安装时，建议安装：  
   https://github.com/Kerwin0224/tencentcloud-tccli-skill  
3. 提交 issue 需要 `gh` 及目标仓库权限  

## 安装

```sh
npx skills add Kerwin0224/tccli-agent-sop -g -y
npx skills add Kerwin0224/tencentcloud-tccli-skill -g -y
```

| 场景 | 命令 |
|---|---|
| 仅安装本 skill（全局） | `npx skills add Kerwin0224/tccli-agent-sop -g -y` |
| 安装到当前项目 | `npx skills add Kerwin0224/tccli-agent-sop -y` |
| 更新 | `npx skills update tccli-agent-sop -g -y` |
| 卸载 | `npx skills remove tccli-agent-sop -g -y` |

### 备用安装方式

```sh
git clone https://github.com/Kerwin0224/tccli-agent-sop.git ~/.agents/skills/tccli-agent-sop
```

若客户端仅识别 `~/.claude/skills`：

```sh
git clone https://github.com/Kerwin0224/tccli-agent-sop.git ~/.claude/skills/tccli-agent-sop
```

### 提交 issue 的前置准备

默认仓库为 [tke-cli-guide](https://github.com/Kerwin0224/tke-cli-guide)：

```sh
export TCCLI_FEEDBACK_REPO="Kerwin0224/tke-cli-guide"
gh auth login   # 或 export GH_TOKEN=...
```

`submit-issue.sh` 默认执行脱敏；标签缺失时尝试创建。也可一次性创建标签：

```sh
for l in agent-feedback doc-bug tool-bug process enhancement; do
  gh label create "$l" --repo Kerwin0224/tke-cli-guide 2>/dev/null || true
done
```

## 使用

见 **`SKILL.md`**。也可直接使用如下表述：

- 「按手册做 TKE 查询」  
- 「用手册 MCP 查命令」  
- 「把这次文档问题提到仓库 issue」  
- 「按 tccli-agent-sop 执行」  

纯云资源增删改查且未提及手册时，直接使用 `tencentcloud-tccli-skill`，无需强制使用本 skill。

## 目录结构

```
tccli-agent-sop/
├── SKILL.md
├── README.md
├── skill-card.md
├── references/
│   ├── gitbook-mcp.md
│   └── issue-schema.md
└── scripts/
    ├── desensitize.sh
    └── submit-issue.sh
```

## 安全

- 提交 issue 时使用 `submit-issue.sh`（默认脱敏；禁止使用 `--no-desensitize`）  
- 不索取、不打印 SecretId / SecretKey  
- 写操作规则以 `tencentcloud-tccli-skill` 为准  

## 许可

MIT。若发布至 GitHub，请在仓库根目录补充 `LICENSE` 文件。
