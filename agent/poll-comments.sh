#!/usr/bin/env bash
# poll-comments.sh — Autonomous agent that processes ALL open issues to completion.
#
# Every issue is classified, implemented, verified, pushed, and closed.
# Nothing is left open — the agent either fixes it or explains why it couldn't.
#
# Comment types:
#   content  → Claude enriches topics/*.json with requested info, commits, pushes
#   bug      → Claude fixes the code (index.html, CSS, JS), tests, commits, pushes
#   feature  → Claude implements the feature, tests, commits, pushes
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
  echo "=== Processing issue #$NUMBER: $TITLE ==="

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

  # ── Step 1: Classify ──────────────────────────────────────────
  echo "  Classifying..."
  CLASSIFY_PROMPT="Classify this user comment into exactly one category. Reply with ONLY the category word, nothing else.

Categories:
- content: User wants information added, expanded, researched, or corrected in the knowledge base. They want to know MORE about a topic, want data/analysis added, or point out missing/wrong information. This is about WHAT the knowledge map contains.
- bug: User reports something broken, not rendering, not scrolling, crashing, display glitch, or incorrect behavior in the website UI/app.
- feature: User requests a new UI capability, navigation improvement, layout change, new interactive element, or workflow enhancement. This is about HOW the knowledge map works as software.

User comment:
${USER_COMMENT}

Reply with exactly one word: content, bug, or feature"

  CATEGORY=$(claude -p "$CLASSIFY_PROMPT" --output-format text 2>/dev/null | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z]//g') || CATEGORY="content"

  if [[ "$CATEGORY" != "content" && "$CATEGORY" != "bug" && "$CATEGORY" != "feature" ]]; then
    echo "  WARNING: Unexpected category '$CATEGORY', defaulting to 'content'"
    CATEGORY="content"
  fi

  echo "  Category: $CATEGORY"

  # ── Step 2: Build prompt based on category ────────────────────

  case "$CATEGORY" in

    content)
      gh issue edit "$NUMBER" --repo "$FULL_REPO" --add-label "$LABEL" 2>/dev/null || true
      AGENT_PROMPT="You are an autonomous agent maintaining the AI Data Centers knowledge map.
A user submitted a content request (GitHub issue #${NUMBER}).

Topic ID: ${TOPIC_ID}
Node ID: ${NODE_ID}
Topic file: ${TOPIC_FILE}
Project directory: ${PROJECT_DIR}

User's request:
${USER_COMMENT}

YOUR TASK — do ALL of these steps:
1. Read ${TOPIC_FILE} and find node '${NODE_ID}'
2. Research/generate the content the user requested
3. Update the node's 'details' field (and 'summary' if needed) with rich Markdown content addressing the request. Keep existing good content. Add new sections, tables, data, analysis as requested.
4. Validate the JSON is correct: no trailing commas, proper escaping, all brackets matched. Run: jq . ${TOPIC_FILE} > /dev/null
5. If validation fails, fix the JSON until it passes
6. Commit: git add ${TOPIC_FILE} && git commit -m 'update ${TOPIC_ID}: enrich ${NODE_ID} (from issue #${NUMBER})'
7. Pull latest and push: git pull --rebase origin main && git push origin main
8. Output ONLY a 2-3 sentence summary of what content you added.

RULES:
- Only modify the specific node. Do not touch other nodes or restructure the JSON.
- Write content in Markdown inside the details string field.
- If the JSON is large, use targeted edits (Edit tool), not full file rewrites.
- You MUST validate with jq before committing."
      ALLOWED_TOOLS="Edit,Read,Bash(git *),Bash(jq *),Bash(cat *),Write"
      ;;

    bug)
      gh issue edit "$NUMBER" --repo "$FULL_REPO" --add-label "bug" 2>/dev/null || true
      AGENT_PROMPT="You are an autonomous agent maintaining the AI Data Centers knowledge map.
A user reported a BUG (GitHub issue #${NUMBER}).

Project directory: ${PROJECT_DIR}
Main files:
- ${PROJECT_DIR}/index.html (single-page app: HTML + CSS + JS all in one file)
- ${PROJECT_DIR}/topics/*.json (data files)
- ${PROJECT_DIR}/comments.config.json (GitHub integration config)

The bug was reported while viewing node '${NODE_ID}' in topic '${TOPIC_ID}'.

User's bug report:
${USER_COMMENT}

YOUR TASK — do ALL of these steps:
1. Read index.html and understand the relevant code
2. Identify the root cause of the bug
3. Fix the code — edit index.html (CSS, JS, or HTML as needed)
4. Verify your fix makes sense (check for syntax errors, unmatched brackets, etc.)
5. Commit: git add -A && git commit -m 'fix: [brief description] (from issue #${NUMBER})'
6. Pull latest and push: git pull --rebase origin main && git push origin main
7. Output ONLY a 2-3 sentence summary of what you fixed and how.

RULES:
- Make minimal, targeted changes. Don't refactor unrelated code.
- Preserve existing functionality — only fix the reported bug.
- Test your logic mentally: will this fix work for the described scenario?
- If the bug is in the data (JSON), fix the data. If it's in the UI code, fix the code."
      ALLOWED_TOOLS="Edit,Read,Bash(git *),Bash(jq *),Bash(cat *),Bash(node *),Write"
      ;;

    feature)
      gh issue edit "$NUMBER" --repo "$FULL_REPO" --add-label "enhancement" 2>/dev/null || true
      AGENT_PROMPT="You are an autonomous agent maintaining the AI Data Centers knowledge map.
A user requested a FEATURE (GitHub issue #${NUMBER}).

Project directory: ${PROJECT_DIR}
Main files:
- ${PROJECT_DIR}/index.html (single-page app: ALL HTML + CSS + JS in one file)
- ${PROJECT_DIR}/topics/*.json (data files loaded via fetch)
- ${PROJECT_DIR}/comments.config.json (GitHub integration config)

The request was made while viewing node '${NODE_ID}' in topic '${TOPIC_ID}'.

User's feature request:
${USER_COMMENT}

YOUR TASK — do ALL of these steps:
1. Read index.html to understand the current codebase
2. Plan the implementation — keep it simple and minimal
3. Implement the feature by editing index.html (add CSS, JS, HTML as needed)
4. Verify: check for syntax errors, unmatched brackets, logic issues
5. Commit: git add -A && git commit -m 'feat: [brief description] (from issue #${NUMBER})'
6. Pull latest and push: git pull --rebase origin main && git push origin main
7. Output ONLY a 2-3 sentence summary of what you implemented.

RULES:
- Keep changes minimal. Implement exactly what was requested, no more.
- All code goes in index.html (inline CSS in <style>, inline JS in <script>).
- Don't break existing features. Be careful with CSS specificity and JS globals.
- If the feature requires data changes too, update topics/*.json as well.
- Make sure it works on both desktop and mobile (the site uses @media max-width:768px)."
      ALLOWED_TOOLS="Edit,Read,Bash(git *),Bash(jq *),Bash(cat *),Bash(node *),Write"
      ;;
  esac

  # ── Step 3: Execute ───────────────────────────────────────────
  echo "  Running Claude agent ($CATEGORY)..."
  RESPONSE=$(cd "$PROJECT_DIR" && claude -p "$AGENT_PROMPT" --output-format text --allowedTools "$ALLOWED_TOOLS" 2>&1) || {
    echo "  ERROR: Claude agent failed on issue #$NUMBER."
    echo "  Output: $RESPONSE"
    # Post failure notice but still close — don't leave issues dangling
    gh issue comment "$NUMBER" --repo "$FULL_REPO" --body "**Agent failed to process this issue.** The error has been logged. A developer will investigate.

\`\`\`
${RESPONSE:0:500}
\`\`\`"
    continue
  }

  echo "  Agent output: $RESPONSE"

  # ── Step 4: Post result and close ─────────────────────────────
  case "$CATEGORY" in
    content)
      COMMENT_BODY="**Knowledge map updated** ✅

${RESPONSE}

The change has been pushed to main and will be live shortly."
      ;;
    bug)
      COMMENT_BODY="**Bug fixed** 🐛✅

${RESPONSE}

The fix has been pushed to main and will be live shortly."
      ;;
    feature)
      COMMENT_BODY="**Feature implemented** ✨✅

${RESPONSE}

The change has been pushed to main and will be live shortly."
      ;;
  esac

  echo "  Posting result and closing issue #$NUMBER..."
  gh issue comment "$NUMBER" --repo "$FULL_REPO" --body "$COMMENT_BODY"
  gh issue close "$NUMBER" --repo "$FULL_REPO"
  echo "  Issue #$NUMBER resolved and closed."

done

echo ""
echo "Done."
