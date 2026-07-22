# Issue 字段约定

issue 正文供人阅读；文首 YAML 供脚本校验。

**出处 URL**（定义见 `SKILL.md`）：`doc-bug` 与 `enhancement` 的 `page_url` 必须为出处 URL，且位于 `https://tccli-agent.gitbook.io/` 之下。另须填写 `suggested_fix`。

## 模板

```markdown
---
title: 一句话标题（与 issue 标题一致）
type: doc-bug        # doc-bug | tool-bug | process | enhancement
severity: med        # low | med | high
reporter: agent      # agent | human
page_url: https://tccli-agent.gitbook.io/tccli/...   # doc-bug / enhancement 必填；须为出处 URL
page_section: 章节标题或锚点                          # 可选
cmd: tccli tke DescribeClusterStatus                 # tool-bug 建议填写
agent_model: tke/glm-latest
agent_session: <session-id>
suggested_fix: 建议将 X 修改为 Y，原因是 Z            # doc-bug / enhancement 必填；单行
---

## 现象
实际现象，以及与预期不符之处。

## 复现
命令、参数、region（提交时由脚本默认脱敏）。

## 期望
正确行为，或手册应补充的内容。

## 证据
输出片段或手册原文。`submit-issue.sh` 默认执行脱敏；禁止传入 `--no-desensitize`。
```

## 字段

| 字段 | 何时必填 | 用途 |
|---|---|---|
| `title` `type` `severity` `reporter` | 全部类型 | 分类 |
| `page_url` `suggested_fix` | `doc-bug` / `enhancement` | 定位手册页面并给出修改建议 |
| `cmd` | `tool-bug` 建议填写 | 工具问题排查 |
| `page_section` `agent_model` `agent_session` | 可选 | 追溯 |

不要填写无意义的 `status: open`（issue 创建时由 GitHub 决定状态）。

## type

| type | 含义 | 降级模式 |
|---|---|---|
| `doc-bug` | 手册错误、缺失或过期 | **禁止**（无出处 URL） |
| `enhancement` | 手册可改进 | **禁止** |
| `tool-bug` | tccli 或云 API 行为问题 | 允许 |
| `process` | 协作或流程建议 | 允许 |

类型选择的主表见 `SKILL.md` 步骤 3。本文供撰写 issue 正文时对照。

## 标签

`agent-feedback`，以及与 type 同名的标签。`submit-issue.sh` 会自动添加；标签缺失时尝试执行 `gh label create`。

## 去重

```bash
gh issue list --repo "${TCCLI_FEEDBACK_REPO:-Kerwin0224/tke-cli-guide}" \
  --label agent-feedback --state open --json number,title,body --limit 20
```

文首一对 `---` 之间为 YAML，其余为正文。`suggested_fix` 保持单行；复杂说明写入 `## 期望`。

`submit-issue.sh` 在缺少必填字段时拒绝提交。默认脱敏：

```bash
bash "${SKILL_DIR}/scripts/submit-issue.sh" --body issue.md --dry-run
bash "${SKILL_DIR}/scripts/submit-issue.sh" --body issue.md
```
