#!/usr/bin/env bash
# poll-comments.sh — Polls open GitHub issues, classifies them,
# and routes to the appropriate handler.
#
# Comment types:
#   content    → Claude edits topics/*.json, commits, pushes, closes issue
#   question   → Claude answers in a comment, closes issue
#   bug        → Labels as "bug", leaves open for developer
#   feature    → Labels as "enhancement", leaves open for developer
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

echo "Polling open issues in $FULL_REPO..."

# Fetch labeled issues + all open issues matching [topic:node] title pattern
LABELED=$(gh issue list --repo "$FULL_REPO" --label "$LABEL" --state open --json number,title,body --limit 50)
ALL_OPEN=$(gh issue list --repo "$FULL_REPO" --state open --json number,title,body --limit 50)
PATTERN_MATCH=$(echo "$ALL_OPEN" | jq '[.[] | select(.title | test("^\\[.+:.+\\]"))]')
ISSUES=$(echo "$LABELED $PATTERN_MATCH" | jq -s 'add | unique_by(.number)')
COUNT=$(echo "$ISSUES" | jq 'length')

if [[ "$COUNT" -eq 0 ]]; then
  echo "No open issues found."
  exit 0
fi

echo "Found $COUNT open issue(s)."

# Ensure labels exist
gh label create bug --repo "$FULL_REPO" --description "Bug report" --color "d73a4a" 2>/dev/null || true
gh label create enhancement --repo "$FULL_REPO" --description "Feature request" --color "a2eeef" 2>/dev/null || true

echo "$ISSUES" | jq -c '.[]' | while read -r issue; do
  NUMBER=$(echo "$issue" | jq -r '.number')
  TITLE=$(echo "$issue" | jq -r '.title')
  BODY=$(echo "$issue" | jq -r '.body')

  echo ""
  echo "--- Processing issue #$NUMBER: $TITLE ---"

  # Ensure the user-comment label
  gh issue edit "$NUMBER" --repo "$FULL_REPO" --add-label "$LABEL" 2>/dev/null || true

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

  # ── Step 1: Classify the comment ──────────────────────────────
  echo "  Classifying comment..."
  CLASSIFY_PROMPT="Classify this user comment into exactly one category. Reply with ONLY the category word, nothing else.

Categories:
- content: User wants more information added to this topic, asks to research something, requests data/analysis, or suggests a factual correction. The request is about WHAT the knowledge map says.
- question: User asks a question that can be answered without changing the knowledge map.
- bug: User reports something broken, not working, display issue, error, or incorrect behavior in the website/app UI.
- feature: User requests a new capability, UI improvement, navigation change, or workflow enhancement. The request is about HOW the knowledge map works, not what it contains.

User comment:
${USER_COMMENT}

Reply with exactly one word: content, question, bug, or feature"

  CATEGORY=$(claude -p "$CLASSIFY_PROMPT" --output-format text 2>/dev/null | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]') || CATEGORY="content"

  # Normalize — sometimes Claude adds punctuation
  CATEGORY=$(echo "$CATEGORY" | sed 's/[^a-z]//g')
  if [[ "$CATEGORY" != "content" && "$CATEGORY" != "question" && "$CATEGORY" != "bug" && "$CATEGORY" != "feature" ]]; then
    echo "  WARNING: Unexpected category '$CATEGORY', defaulting to 'content'"
    CATEGORY="content"
  fi

  echo "  Category: $CATEGORY"

  # ── Step 2: Route based on category ───────────────────────────

  case "$CATEGORY" in

    # ── BUG: label and leave open for developer ──
    bug)
      echo "  Routing as bug report..."
      gh issue edit "$NUMBER" --repo "$FULL_REPO" --add-label "bug" 2>/dev/null || true
      REPLY="**Classified as: Bug Report** 🐛

This has been tagged for developer attention. The automated agent does not modify UI/application code — a developer will review and address this.

**Summary of report:** ${USER_COMMENT:0:200}"
      gh issue comment "$NUMBER" --repo "$FULL_REPO" --body "$REPLY"
      echo "  Labeled as bug, left open."
      ;;

    # ── FEATURE: label and leave open for developer ──
    feature)
      echo "  Routing as feature request..."
      gh issue edit "$NUMBER" --repo "$FULL_REPO" --add-label "enhancement" 2>/dev/null || true
      REPLY="**Classified as: Feature Request** ✨

This has been tagged for developer attention. The automated agent handles content updates only — UI and feature changes require a developer.

**Summary of request:** ${USER_COMMENT:0:200}"
      gh issue comment "$NUMBER" --repo "$FULL_REPO" --body "$REPLY"
      echo "  Labeled as enhancement, left open."
      ;;

    # ── QUESTION: answer and close ──
    question)
      echo "  Answering question..."
      NODE_CONTEXT=""
      if [[ -f "$TOPIC_FILE" ]]; then
        NODE_LABEL=$(jq -r --arg id "$NODE_ID" '.nodes[$id].label // "Unknown"' "$TOPIC_FILE")
        NODE_SUMMARY=$(jq -r --arg id "$NODE_ID" '.nodes[$id].summary // ""' "$TOPIC_FILE")
        NODE_CONTEXT="Node: $NODE_LABEL ($NODE_ID)\nSummary: $NODE_SUMMARY"
      fi

      ANSWER_PROMPT="A user asked a question about the AI Data Centers knowledge map.

Node context:
$NODE_CONTEXT

User's question:
$USER_COMMENT

Provide a helpful, concise answer. Keep it under 300 words."

      ANSWER=$(claude -p "$ANSWER_PROMPT" --output-format text 2>/dev/null) || {
        echo "  ERROR: Claude failed. Skipping."
        continue
      }

      gh issue comment "$NUMBER" --repo "$FULL_REPO" --body "$ANSWER"
      gh issue close "$NUMBER" --repo "$FULL_REPO"
      echo "  Question answered and closed."
      ;;

    # ── CONTENT: update the knowledge map ──
    content)
      echo "  Updating knowledge map content..."

      if [[ ! -f "$TOPIC_FILE" ]]; then
        echo "  WARNING: Topic file $TOPIC_FILE not found. Closing with notice."
        gh issue comment "$NUMBER" --repo "$FULL_REPO" --body "Topic file \`topics/${TOPIC_ID}.json\` not found. Could not process this comment."
        gh issue close "$NUMBER" --repo "$FULL_REPO"
        continue
      fi

      CONTENT_PROMPT="A user submitted a content request on the AI Data Centers knowledge map (GitHub issue #${NUMBER}).

Topic ID: ${TOPIC_ID}
Node ID: ${NODE_ID}
Topic file: ${TOPIC_FILE}

User's comment/request:
${USER_COMMENT}

Your job:
1. Read the topic file: ${TOPIC_FILE}
2. Find the node '${NODE_ID}' in the JSON
3. Update the node's 'details' field (and 'summary' if appropriate) to address the user's request — add the requested information, fix errors, or enrich the content. Write in Markdown. Keep existing good content, add new content that addresses the request.
4. Make sure the JSON remains valid (no trailing commas, proper escaping)
5. Commit the change with message: 'update ${TOPIC_ID}: enrich ${NODE_ID} (from issue #${NUMBER})'
6. Push to origin main
7. Output a brief summary (2-3 sentences) of what you changed, so it can be posted back to the GitHub issue.

IMPORTANT: Only modify the specific node's content. Do not restructure the JSON or modify other nodes. Write content in Markdown format inside the details field."

      RESPONSE=$(cd "$PROJECT_DIR" && claude -p "$CONTENT_PROMPT" --output-format text --allowedTools "Edit,Read,Bash(git *),Bash(jq *),Write" 2>&1) || {
        echo "  ERROR: Claude agent failed. Skipping issue #$NUMBER."
        echo "  Output: $RESPONSE"
        continue
      }

      echo "  Claude response: $RESPONSE"

      COMMENT_BODY="$(cat <<EOF
**Knowledge map updated** ✅

${RESPONSE}

The change has been pushed to main and will be live on the site shortly.
EOF
)"
      gh issue comment "$NUMBER" --repo "$FULL_REPO" --body "$COMMENT_BODY"
      gh issue close "$NUMBER" --repo "$FULL_REPO"
      echo "  Content updated, issue closed."
      ;;
  esac

done

echo ""
echo "Done."
