#!/usr/bin/env bash
# poll-comments.sh — Polls open GitHub issues labeled "user-comment",
# generates a Claude response, posts it, and closes the issue.
#
# Requirements: gh (GitHub CLI, authenticated), jq, claude (Claude CLI)

set -euo pipefail

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

  # Load node context from topic JSON
  TOPIC_FILE="$PROJECT_DIR/topics/${TOPIC_ID}.json"
  NODE_CONTEXT=""
  if [[ -f "$TOPIC_FILE" ]]; then
    NODE_LABEL=$(jq -r --arg id "$NODE_ID" '.nodes[$id].label // "Unknown"' "$TOPIC_FILE")
    NODE_SUMMARY=$(jq -r --arg id "$NODE_ID" '.nodes[$id].summary // ""' "$TOPIC_FILE")
    NODE_CATEGORY=$(jq -r --arg id "$NODE_ID" '.nodes[$id].category // ""' "$TOPIC_FILE")
    NODE_CONTEXT="Node: $NODE_LABEL ($NODE_ID)
Category: $NODE_CATEGORY
Summary: $NODE_SUMMARY"
  else
    echo "  WARNING: Topic file $TOPIC_FILE not found."
    NODE_CONTEXT="Topic: $TOPIC_ID, Node: $NODE_ID (topic file not found)"
  fi

  # Build prompt for Claude
  PROMPT="You are responding to a user comment on the AI Data Centers knowledge map.

Context about the node they're commenting on:
$NODE_CONTEXT

The user's comment/question:
$USER_COMMENT

Please provide a helpful, concise response. If the comment suggests a factual correction or valuable addition, note that clearly. If it's a question, answer it based on your knowledge. Keep the response focused and actionable."

  echo "  Calling Claude for response..."
  RESPONSE=$(echo "$PROMPT" | claude --print 2>/dev/null) || {
    echo "  ERROR: Claude CLI failed. Skipping issue #$NUMBER."
    continue
  }

  # Post response and close
  echo "  Posting response to issue #$NUMBER..."
  gh issue comment "$NUMBER" --repo "$FULL_REPO" --body "$RESPONSE"
  gh issue close "$NUMBER" --repo "$FULL_REPO"
  echo "  Issue #$NUMBER resolved and closed."
done

echo ""
echo "Done."
