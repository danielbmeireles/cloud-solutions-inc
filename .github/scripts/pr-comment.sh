#!/bin/bash

set -e

# Function to get status emoji
get_status_emoji() {
  case "$1" in
    success) echo "✅" ;;
    failure) echo "❌" ;;
    skipped) echo "⏭️" ;;
    *) echo "⚠️" ;;
  esac
}

# Function to get status badge
get_status_badge() {
  case "$1" in
    success) echo "🟢 **Success**" ;;
    failure) echo "🔴 **Failed**" ;;
    skipped) echo "⚪ **Skipped**" ;;
    *) echo "🟡 **Unknown**" ;;
  esac
}

# Determine workflow type and set appropriate title
if [ "${WORKFLOW_TYPE}" == "kubernetes" ]; then
  WORKFLOW_TITLE="☸️ Kubernetes Deployment Preview"
  WORKFLOW_EMOJI="☸️"
else
  WORKFLOW_TITLE="🏗️ Terraform Deployment Preview"
  WORKFLOW_EMOJI="🏗️"
fi

# Build the comment body
COMMENT_BODY=$(cat <<EOF
## ${WORKFLOW_TITLE}

### Validation Results

| Step | Status | Result |
|------|--------|--------|
| 🖌 **Format & Style** | $(get_status_emoji "$FMT_OUTCOME") | $(get_status_badge "$FMT_OUTCOME") |
| ⚙️ **Initialization** | $(get_status_emoji "$INIT_OUTCOME") | $(get_status_badge "$INIT_OUTCOME") |
| 📋 **Plan** | $(get_status_emoji "$PLAN_OUTCOME") | $(get_status_badge "$PLAN_OUTCOME") |

---

<details><summary><b>📖 View Terraform Plan Details</b></summary>

\`\`\`terraform
${PLAN}
\`\`\`

</details>

---

<sub>👤 Triggered by **@${GITHUB_ACTOR}** | 🔄 Action: \`${GITHUB_EVENT_NAME}\` | ${WORKFLOW_EMOJI} Workflow: \`${WORKFLOW_TYPE:-terraform}\` | ⏰ $(date -u)</sub>
EOF
)

# Output the comment body to a file for the GitHub Action to use
echo "$COMMENT_BODY" > /tmp/pr-comment.txt
echo "Comment body saved to /tmp/pr-comment.txt"
