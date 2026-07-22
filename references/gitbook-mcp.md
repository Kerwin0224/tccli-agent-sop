# 手册 MCP 工具

手册站点：https://tccli-agent.gitbook.io/tccli  
MCP 端点：`https://tccli-agent.gitbook.io/tccli/~gitbook/mcp`

安装与多客户端配置以文档源仓库 README 为准：  
https://github.com/Kerwin0224/tke-cli-guide  

本 skill 不修改已发布文档。

## 接入说明

手册 MCP 不可用或未安装时：进入 `SKILL.md` 中的**降级模式**，并**引导用户阅读上述仓库 README** 完成接入。完整安装步骤、多客户端配置均以该 README 为权威来源。

Claude Code 快捷示例（细节若与 README 冲突，以 README 为准）：

```sh
claude mcp add --transport http tccli-agent-docs \
  https://tccli-agent.gitbook.io/tccli/~gitbook/mcp
```

会话中 MCP server 的显示名称可能带有项目前缀；应以**当前会话已注册的工具名**为准，按短名匹配即可。该端点仅用于只读查阅手册，不调用云 API，也不持有云凭证。

## 只读工具（短名）

| 短名 | 必填参数 | 可选参数 | 作用 |
|---|---|---|---|
| `askQuestion` | `question` | `goal` | 问答并返回来源链接（执行任务时优先） |
| `searchDocumentation` | `query` | — | 按关键词检索**片段**及链接 |
| `getPage` | `url` | — | 按**完整 URL** 读取整页 |

## 查阅顺序

1. 调用 `askQuestion(question, goal?)`，`goal` 填写用户最终业务目标；将来源中的完整 URL 记为**出处 URL**（定义见 `SKILL.md`）。  
2. 确定 API Action 或摘录可执行命令前，使用完整 URL 调用 `getPage`。搜索结果摘要不得视为整页内容。  
3. `searchDocumentation` 仅用于浏览相关页面列表。

`getPage` 的 `url` 示例：  
`https://tccli-agent.gitbook.io/tccli/tke-rong-qi-fu-wu/index-1/query`

反馈须通过 GitHub issue 提交（见 `SKILL.md` 步骤 3、`issue-schema.md` 与 `scripts/submit-issue.sh`），不得使用 MCP `sendFeedback`。
