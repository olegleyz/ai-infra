#!/usr/bin/env bash
# poll-comments.sh — Polls open GitHub issues labeled "user-comment",
# uses Claude to update the knowledge map, commits, pushes, and closes the issue.
#
# Requirements: gh (GitHub CLI, authenticated), jq, claude (Claude CLI)

set -euo pipefail
export GIT_SSL_NO_VERIFY=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG="$PROJECT_DIR/comments.config.json"

if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: $CONFIG not found" >&2
  exit 1
fi

OWNER=$(jq -r '.github.owner' "$CONFIG")
REPO=$(jq -r '.github.repo' "$CONFIG")
LABEL=$(jq -r '.github.labels[0] // "user-comment"' "$CONFIG")
FULL_REPO="$OWNER/$REPO"

if [[ "$OWNER" == "OWNER" || "$REPO" == "REPO" ]]; then
  echo "ERROR: Update owner/repo in $CONFIG (still has placeholder values)" >&2
  exit 1
fi

echo "Polling open issues in $FULL_REPO with label '$LABEL'..."

ISSUES=$(gh issue list --repo "$FULL_REPO" --label "$LABEL" --state open --json number,title,body --limit 50)
COUNT=$(echo "$ISSUES" | jq 'length')

if [[ "$COUNT" -eq 0 ]]; then
  echo "No open issues found."
  exit 0
fi

echo "Found $COUNT open issue(s)."

echo "$ISSUES" | jq -c '.[]' | while read -r issue; do
  NUMBER=$(echo "$issue" | jq -r '.number')
  TITLE=$(echo "$issue" | jq -r '.title')
  BODY=$(echo "$issue" | jq -r '.body')

  echo ""
  echo "--- Processing issue #$NUMBER: $TITLE ---"

  # Parse [topicId:nodeId] from title
  if [[ "$TITLE" =~ ^\[([^:]+):([^\]]+)\] ]]; then
    TOPIC_ID="${BASH_REMATCH[1]}"
    NODE_ID="${BASH_REMATCH[2]}"
  else
    echo "  WARNING: Could not parse topic:node from title. Posting notice and closing."
    gh issue comment "$NUMBER" --repo "$FULL_REPO" --body "Could not parse topic/node from issue title. Expected format: \`[topicId:nodeId] comment text\`. Please resubmit with the correct format."
    gh issue close "$NUMBER" --repo "$FULL_REPO"
    continue
  fi

  # Extract user comment (text after --- in body)
  USER_COMMENT=$(echo "$BODY" | sed -n '/^---$/,$ p' | tail -n +2 | sed 's/^[[:space:]]*//')
  if [[ -z "$USER_COMMENT" ]]; then
    USER_COMMENT="$BODY"
  fi

  TOPIC_FILE="$PROJECT_DIR/topics/${TOPIC_ID}.json"

  if [[ ! -f "$TOPIC_FILE" ]]; then
    echo "  WARNING: Topic file $TOPIC_FILE not found. Closing with notice."
    gh issue comment "$NUMBER" --repo "$FULL_REPO" --body "Topic file \`topics/${TOPIC_ID}.json\` not found. Could not process this comment."
    gh issue close "$NUMBER" --repo "$FULL_REPO"
    continue
  fi

  # Build the full prompt for Claude with tool access
  PROMPT="A user submitted a comment on the AI Data Centers knowledge map (GitHub issue #${NUMBER}).

Topic ID: ${TOPIC_ID}
Node ID: ${NODE_ID}
Topic file: ${TOPIC_FILE}

User's comment/request:
${USER_COMMENT}

Your job:
1. Read the topic file: ${TOPIC_FILE}
2. Find the node '${NODE_ID}' in the JSON
3. Update the node's 'details' field (and 'summary' if appropriate) to address the user's comment — add the requested information, fix errors, or enrich the content. Write in Markdown. Keep existing good content, add new content that addresses the comment.
4. Make sure the JSON remains valid (no trailing commas, proper escaping)
5. Commit the change with message: 'update ${TOPIC_ID}: enrich ${NODE_ID} (from issue #${NUMBER})'
6. Push to origin main
7. Output a brief summary (2-3 sentences) of what you changed, so it can be posted back to the GitHub issue.

IMPORTANT: Only modify the specific node's content. Do not restructure the JSON or modify other nodes. Write content in Markdown format inside the details field."

  echo "  Running Claude agent to update knowledge map..."
  RESPONSE=$(cd "$PROJECT_DIR" && claude -p "$PROMPT" --output-format text --allowedTools "Edit,Read,Bash(git *),Bash(jq *),Write" 2>&1) || {
    echo "  ERROR: Claude agent failed. Skipping issue #$NUMBER."
    echo "  Output: $RESPONSE"
    continue
  }

  echo "  Claude response: $RESPONSE"

  # Post summary to the issue and close
  COMMENT_BODY="$(cat <<EOF
**Knowledge map updated** ✅

${RESPONSE}

The change has been pushed to main and will be live on the site shortly.
EOF
)"

  echo "  Posting summary to issue #$NUMBER..."
  gh issue comment "$NUMBER" --repo "$FULL_REPO" --body "$COMMENT_BODY"
  gh issue close "$NUMBER" --repo "$FULL_REPO"
  echo "  Issue #$NUMBER resolved and closed."
done

echo ""
echo "Done."
