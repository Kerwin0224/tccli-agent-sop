#!/usr/bin/env bash
# 按 references/issue-schema.md 校验 issue 正文并提交至 GitHub。
# 缺少必填字段时拒绝提交。默认对正文全文脱敏（可用 --no-desensitize 关闭）；--dry-run 仅校验不创建。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DESENSE_SH="${SCRIPT_DIR}/desensitize.sh"

usage() {
  cat <<EOF
用法: submit-issue.sh --body <issue-body.md> [--repo owner/repo] [--no-desensitize] [--dry-run]
  --body            issue 正文文件路径，须含 YAML frontmatter（见 references/issue-schema.md）
  --repo            覆盖 \$TCCLI_FEEDBACK_REPO（默认 Kerwin0224/tke-cli-guide）
  --no-desensitize  跳过脱敏（默认执行 desensitize.sh）
  --desensitize     兼容旧调用方式；默认已脱敏，可省略
  --dry-run         仅校验并打印将执行的 gh 命令，不创建 issue
校验: 必填 title/type/severity/reporter；doc-bug|enhancement 另须 page_url 与 suggested_fix
EOF
}

body_file=""
repo="${TCCLI_FEEDBACK_REPO:-Kerwin0224/tke-cli-guide}"
do_desense=1
dry_run=0
while [ $# -gt 0 ]; do
  case "$1" in
    --body) body_file="$2"; shift 2 ;;
    --repo) repo="$2"; shift 2 ;;
    --desensitize) do_desense=1; shift ;;
    --no-desensitize) do_desense=0; shift ;;
    --dry-run) dry_run=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "未知参数: $1" >&2; usage; exit 2 ;;
  esac
done

[ -n "$body_file" ] || { echo "缺少 --body" >&2; usage; exit 2; }
[ -f "$body_file" ] || { echo "正文文件不存在: $body_file" >&2; exit 2; }
[ -n "$repo" ] || { echo "缺少 \$TCCLI_FEEDBACK_REPO 或 --repo" >&2; exit 2; }
command -v gh >/dev/null || { echo "未找到 gh，请先执行 gh auth login" >&2; exit 2; }

work_file="$body_file"
cleanup() { [ -n "${tmp_file:-}" ] && [ -f "${tmp_file:-}" ] && rm -f "$tmp_file"; }
trap cleanup EXIT

if [ "$do_desense" -eq 1 ]; then
  [ -x "$DESENSE_SH" ] || [ -f "$DESENSE_SH" ] || { echo "找不到 desensitize.sh: $DESENSE_SH" >&2; exit 2; }
  tmp_file="$(mktemp)"
  # shellcheck disable=SC2094
  bash "$DESENSE_SH" < "$body_file" > "$tmp_file"
  work_file="$tmp_file"
  echo "→ 已脱敏 → $work_file" >&2
else
  echo "→ 警告: 已指定 --no-desensitize，将提交未脱敏正文" >&2
fi

# 从 frontmatter 取某 key 的值（只看第一个 --- 块）
fm() {
  awk -v k="$1" '
    /^---[[:space:]]*$/ { f++; next }
    f==1 && $0 ~ "^"k":" {
      sub("^"k":[[:space:]]*", "")
      gsub(/^["'"'"']+|["'"'"']+$/, "")
      print; exit
    }
  ' "$work_file"
}

die() { echo "校验失败: $1" >&2; exit 3; }

title="$(fm title)"
type_label="$(fm type)"
severity="$(fm severity)"
reporter="$(fm reporter)"

[ -n "$title" ]      || die "frontmatter 缺少 title"
[ -n "$type_label" ] || die "frontmatter 缺少 type"
[ -n "$severity" ]  || die "frontmatter 缺少 severity"
[ -n "$reporter" ]  || die "frontmatter 缺少 reporter"

case "$type_label" in
  doc-bug|enhancement)
    page_url="$(fm page_url)"
    fix="$(fm suggested_fix)"
    [ -n "$page_url" ] || die "${type_label} 必须填写 page_url"
    case "$page_url" in
      https://tccli-agent.gitbook.io/*) ;;
      *) die "${type_label} 的 page_url 须为 https://tccli-agent.gitbook.io/ 下页面（须为本轮手册 MCP 返回的出处 URL）" ;;
    esac
    [ -n "$fix" ] || die "${type_label} 必须填写 suggested_fix"
    ;;
  tool-bug)
    [ -n "$(fm cmd)" ] || echo "提示: tool-bug 建议填写 cmd" >&2
    ;;
  process) ;;
  *) die "未知 type: ${type_label}（应为 doc-bug|tool-bug|process|enhancement）" ;;
esac

ensure_label() {
  local label="$1"
  if gh label list --repo "$repo" --json name --jq '.[].name' 2>/dev/null | grep -qx "$label"; then
    return 0
  fi
  echo "→ 尝试创建 label: $label" >&2
  gh label create "$label" --repo "$repo" 2>/dev/null || \
    echo "提示: 无法创建 label '$label'（权限或已存在竞态）；若 gh create 失败请手动建 label" >&2
}

labels="agent-feedback,${type_label}"
for l in agent-feedback "$type_label"; do
  ensure_label "$l"
done

echo "→ 校验通过，目标仓库 ${repo}（labels: ${labels}） title=${title}" >&2

if [ "$dry_run" -eq 1 ]; then
  echo "→ dry-run: 不创建 issue" >&2
  echo "gh issue create --repo ${repo} --title $(printf %q "$title") --label ${labels} --body-file ${work_file}"
  exit 0
fi

gh issue create --repo "$repo" --title "$title" --label "$labels" --body-file "$work_file"
