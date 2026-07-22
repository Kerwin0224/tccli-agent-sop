# skill-card

| 字段 | 值 |
|---|---|
| name | tccli-agent-sop |
| display_name | tccli 手册流程 |
| version | 0.5.2 |
| description | 手册优先闭环：经手册 MCP 取得可核验依据后，由 tencentcloud-tccli-skill 调用 tccli；业务目标结束时完成反馈闭环（已提交 issue、用户本轮明确拒绝、或本轮无需反馈） |
| tags | tccli, gitbook, mcp, handbook, feedback, agent, closed-loop |
| install | `npx skills add Kerwin0224/tccli-agent-sop -g -y` |
| companion_skill | https://github.com/Kerwin0224/tencentcloud-tccli-skill · `npx skills add Kerwin0224/tencentcloud-tccli-skill -g -y` |
| feedback_repo | Kerwin0224/tke-cli-guide |
| handbook | https://tccli-agent.gitbook.io/tccli · https://github.com/Kerwin0224/tke-cli-guide |
| requires | 手册 MCP 未安装时引导阅读 tke-cli-guide README；未安装 tencentcloud-tccli-skill 时建议安装其仓库 skill；提交 issue 需要 gh |
| not_included | 自动修改已发布文档、tccli 调用细则、MCP 多客户端安装教程、MCP sendFeedback |
