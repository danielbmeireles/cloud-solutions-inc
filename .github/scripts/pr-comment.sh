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

# Build the comment body
COMMENT_BODY=$(cat <<EOF
## 🚀 Terraform Deployment Preview

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

<sub>👤 Triggered by **@${GITHUB_ACTOR}** | 🔄 Action: \`${GITHUB_EVENT_NAME}\` | ⏰ $(date -u)</sub>
EOF
)

# Post comment using gh CLI
gh pr comment "$PR_NUMBER" --body "$COMMENT_BODY"
