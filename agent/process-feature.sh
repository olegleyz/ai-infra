#!/usr/bin/env bash
# process-feature.sh — Multi-stage feature request pipeline
#
# Usage:
#   bash agent/process-feature.sh --issue 42        # Process existing GitHub issue
#   bash agent/process-feature.sh --request "text"   # Create issue from text, then process
#
# Pipeline stages:
#   1. Product Agent   — requirements, acceptance criteria, definition of done
#   2. Architect Agent — design options, pros/cons, recommended approach, implementation plan
#   3. Review Agent    — peer review of the design, raises concerns
#   4. Resolve Agent   — addresses review comments, finalizes plan
#   5. Implement Agent — implements the plan, writes code
#   6. Test Agent      — verifies syntax, mobile compat, no regressions
#   7. Close           — updates issue with results, closes
#
# Requirements: gh, jq, claude, node

set -euo pipefail
export GIT_SSL_NO_VERIFY=1

# macOS doesn't have timeout; use gtimeout from coreutils or a shell fallback
if command -v gtimeout &>/dev/null; then
  TIMEOUT_CMD="gtimeout"
elif command -v timeout &>/dev/null; then
  TIMEOUT_CMD="timeout"
else
  # Pure bash fallback: run command in background, kill after N seconds
  run_with_timeout() {
    local secs="$1"; shift
    "$@" &
    local pid=$!
    ( sleep "$secs"; kill "$pid" 2>/dev/null ) &
    local watchdog=$!
    wait "$pid" 2>/dev/null
    local ret=$?
    kill "$watchdog" 2>/dev/null
    wait "$watchdog" 2>/dev/null
    return $ret
  }
  TIMEOUT_CMD="__fallback__"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG="$PROJECT_DIR/comments.config.json"

OWNER=$(jq -r '.github.owner' "$CONFIG")
REPO=$(jq -r '.github.repo' "$CONFIG")
FULL_REPO="$OWNER/$REPO"

# ── Parse arguments ─────────────────────────────────────────────
ISSUE_NUMBER=""
REQUEST_TEXT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --issue) ISSUE_NUMBER="$2"; shift 2 ;;
    --request) REQUEST_TEXT="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

# ── Create issue if needed ──────────────────────────────────────
if [[ -n "$REQUEST_TEXT" && -z "$ISSUE_NUMBER" ]]; then
  echo "Creating GitHub issue from request..."

  # Extract topic:node if present in the text, otherwise use generic
  if [[ "$REQUEST_TEXT" =~ \[([^:]+):([^\]]+)\] ]]; then
    TITLE="[${BASH_REMATCH[1]}:${BASH_REMATCH[2]}] ${REQUEST_TEXT:0:60}"
  else
    TITLE="[ai-dc:general] ${REQUEST_TEXT:0:60}"
  fi

  ISSUE_URL=$(gh issue create --repo "$FULL_REPO" \
    --title "$TITLE" \
    --label "enhancement,user-comment" \
    --body "**Feature Request**

---

$REQUEST_TEXT")

  ISSUE_NUMBER=$(echo "$ISSUE_URL" | grep -oE '[0-9]+$')
  echo "Created issue #$ISSUE_NUMBER: $ISSUE_URL"
fi

if [[ -z "$ISSUE_NUMBER" ]]; then
  echo "ERROR: Provide --issue NUMBER or --request TEXT" >&2
  exit 1
fi

# ── Load issue data ─────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Processing feature request: issue #$ISSUE_NUMBER"
echo "════════════════════════════════════════════════════════════"

ISSUE_JSON=$(gh issue view "$ISSUE_NUMBER" --repo "$FULL_REPO" --json title,body)
TITLE=$(echo "$ISSUE_JSON" | jq -r '.title')
BODY=$(echo "$ISSUE_JSON" | jq -r '.body')

# Extract user request (text after ---)
USER_REQUEST=$(echo "$BODY" | sed -n '/^---$/,$ p' | tail -n +2 | sed 's/^[[:space:]]*//')
if [[ -z "$USER_REQUEST" ]]; then
  USER_REQUEST="$BODY"
fi

# Parse topic:node
TOPIC_ID="ai-dc"
NODE_ID="general"
if [[ "$TITLE" =~ ^\[([^:]+):([^\]]+)\] ]]; then
  TOPIC_ID="${BASH_REMATCH[1]}"
  NODE_ID="${BASH_REMATCH[2]}"
fi

echo "  Topic: $TOPIC_ID | Node: $NODE_ID"
echo "  Request: ${USER_REQUEST:0:100}..."
echo ""

# Helper: post a stage update to the issue
post_stage() {
  local stage="$1"
  local content="$2"
  gh issue comment "$ISSUE_NUMBER" --repo "$FULL_REPO" --body "$content"
  echo "  [$stage] Posted to issue."
}

# Helper: run claude with timeout and capture output
# Stages with tools (implement/test/fix) get 5 min, others get 3 min
run_agent() {
  local label="$1"
  local prompt="$2"
  local tools="${3:-}"
  local timeout_sec="${4:-180}"
  echo "  [$label] Running (timeout: ${timeout_sec}s)..."
  local result
  local timeout_wrapper=""
  if [[ "$TIMEOUT_CMD" == "__fallback__" ]]; then
    timeout_wrapper="run_with_timeout $timeout_sec"
  else
    timeout_wrapper="$TIMEOUT_CMD $timeout_sec"
  fi

  if [[ -n "$tools" ]]; then
    result=$(cd "$PROJECT_DIR" && $timeout_wrapper claude -p "$prompt" --output-format text --allowedTools "$tools" 2>&1) || {
      local exit_code=$?
      if [[ $exit_code -eq 124 || $exit_code -eq 137 ]]; then
        echo "  [$label] TIMED OUT after ${timeout_sec}s"
        result="Agent timed out after ${timeout_sec} seconds. The feature may be too large for a single pass."
      else
        echo "  [$label] FAILED (exit $exit_code)"
      fi
      echo "$result"
      return 1
    }
  else
    result=$($timeout_wrapper claude -p "$prompt" --output-format text 2>&1) || {
      local exit_code=$?
      if [[ $exit_code -eq 124 || $exit_code -eq 137 ]]; then
        echo "  [$label] TIMED OUT after ${timeout_sec}s"
        result="Agent timed out after ${timeout_sec} seconds."
      else
        echo "  [$label] FAILED (exit $exit_code)"
      fi
      echo "$result"
      return 1
    }
  fi
  echo "$result"
}

# Helper: run_agent with 1 retry on failure
run_agent_retry() {
  local label="$1"
  local output
  output=$(run_agent "$@") && { echo "$output"; return 0; }
  echo "  [$label] First attempt failed. Retrying..."
  output=$(run_agent "$@") && { echo "$output"; return 0; }
  echo "  [$label] Second attempt also failed."
  echo "$output"
  return 1
}

# ════════════════════════════════════════════════════════════════
# STAGE 1: Product Agent — Requirements & Acceptance Criteria
# ════════════════════════════════════════════════════════════════
echo "── Stage 1: Product Agent ──────────────────────────────"

REQUIREMENTS=$(run_agent_retry "Product" "You are a Product Manager AI agent. Your job is to convert a vague user feature request into a complete, unambiguous specification.

PROJECT CONTEXT:
- Single-page knowledge map app: one index.html file containing all HTML, CSS, and JS
- Data loaded from topics/*.json via fetch()
- Responsive design: desktop + mobile (iOS Safari, Chrome)
- Dark theme UI with sidebar tree navigation, node grid, detail panel, search, breadcrumbs
- Key UI elements: #topbar, #sidebar, #graph-area (#node-grid with .node-card cards), #detail-panel, #search-box, #breadcrumbs, #notif-bell, #export-btn
- The detail panel slides open from the right when clicking a leaf node
- Navigation: click cards to drill down, breadcrumbs to go up, tree sidebar on desktop

USER'S FEATURE REQUEST:
${USER_REQUEST}

Submitted while viewing node '${NODE_ID}' in topic '${TOPIC_ID}'.

OUTPUT FORMAT — respond with exactly this structure:

## Requirements

### Problem Statement
[What specific problem does the user face? Be concrete.]

### Functional Requirements
[Numbered list. Each requirement is a testable statement. E.g., 'FR-1: When user clicks X, Y happens.']

### Non-Functional Requirements
[Performance, mobile compat, accessibility, etc.]

### Acceptance Criteria
[Numbered list of verifiable conditions that must be true when the feature is complete. Written as 'Given/When/Then' or clear assertions.]

### Definition of Done
- [ ] All acceptance criteria pass
- [ ] Works on desktop Chrome (macOS)
- [ ] Works on mobile Safari (iOS)
- [ ] No regressions to existing features
- [ ] Code committed and pushed to main

### Out of Scope
[What this feature does NOT include, to prevent scope creep.]") || {
  post_stage "Product" "**Stage 1: Product Agent** ❌ Failed to generate requirements."
  exit 1
}

post_stage "Product" "**Stage 1: Product Agent — Requirements** 📋

$REQUIREMENTS"

echo "  [Product] Done."

# ════════════════════════════════════════════════════════════════
# STAGE 2: Architect Agent — Design & Implementation Plan
# ════════════════════════════════════════════════════════════════
echo "── Stage 2: Architect Agent ─────────────────────────────"

CODEBASE_SUMMARY=$(cd "$PROJECT_DIR" && head -250 index.html | tail -235)

DESIGN=$(run_agent_retry "Architect" "You are a Principal Engineer AI agent. Your job is to design the best implementation for a feature, considering the existing codebase.

PROJECT CONTEXT:
- Single-page app: index.html (~950 lines of HTML+CSS+JS)
- No build system, no framework — vanilla JS
- CSS is in a single <style> block, JS in a single <script> block
- Mobile responsive via @media (max-width:768px)
- Data loaded from topics/*.json

CURRENT CSS STRUCTURE (first 235 lines of index.html):
\`\`\`
${CODEBASE_SUMMARY}
\`\`\`

REQUIREMENTS TO IMPLEMENT:
${REQUIREMENTS}

YOUR TASK — produce a design document with this exact structure:

## Design

### Approach Options

#### Option A: [Name]
- Description: [how it works]
- Pros: [list]
- Cons: [list]
- Effort: [low/medium/high]

#### Option B: [Name]
- Description: [how it works]
- Pros: [list]
- Cons: [list]
- Effort: [low/medium/high]

[Add Option C if there's a meaningfully different approach]

### Recommended Approach
[Which option and why. Reference specific requirements.]

### Implementation Plan
[Ordered steps. Each step specifies: what file to edit, what section, what to add/change. Be specific enough that a developer can follow without guessing.]

Step 1: [CSS changes]
Step 2: [HTML changes]
Step 3: [JS changes]
Step 4: [Mobile-specific changes]

### Risk Assessment
[What could go wrong? What existing features might break?]

### Test Plan
[How to verify each acceptance criterion. Include specific manual test steps for both desktop and mobile.]") || {
  post_stage "Architect" "**Stage 2: Architect Agent** ❌ Failed to produce design."
  exit 1
}

post_stage "Architect" "**Stage 2: Architect Agent — Design** 🏗️

$DESIGN"

echo "  [Architect] Done."

# ════════════════════════════════════════════════════════════════
# STAGE 3: Review Agent — Peer Review
# ════════════════════════════════════════════════════════════════
echo "── Stage 3: Review Agent ────────────────────────────────"

REVIEW=$(run_agent_retry "Review" "You are a Senior Engineer AI agent performing a peer review. Be critical but constructive. Your job is to catch problems BEFORE code is written.

REQUIREMENTS:
${REQUIREMENTS}

PROPOSED DESIGN:
${DESIGN}

REVIEW CHECKLIST:
1. Does the design fully address all functional requirements? Any gaps?
2. Will it work on mobile Safari (iOS)? Are there iOS-specific CSS/JS gotchas?
3. Will it work on desktop Chrome? Any Chrome-specific issues?
4. Does the implementation plan risk breaking existing features?
5. Is the approach the simplest that could work? Any over-engineering?
6. Are there edge cases not covered?
7. Is the CSS approach sound? (z-index conflicts, overflow issues, specificity)
8. Is the JS approach sound? (memory leaks, event listener cleanup, global state)
9. Any accessibility concerns?
10. Is the test plan sufficient?

OUTPUT FORMAT:

## Review

### Approval Status
[APPROVED / APPROVED WITH CHANGES / REQUEST CHANGES]

### Issues Found
[Numbered list. Each issue: severity (critical/major/minor), description, suggested fix.]

### Missing from Design
[Anything the design should cover but doesn't.]

### Suggestions
[Optional improvements that aren't blockers.]") || {
  post_stage "Review" "**Stage 3: Review Agent** ❌ Failed to review."
  exit 1
}

post_stage "Review" "**Stage 3: Review Agent — Peer Review** 🔍

$REVIEW"

echo "  [Review] Done."

# ════════════════════════════════════════════════════════════════
# STAGE 4: Resolve Agent — Address Review & Finalize Plan
# ════════════════════════════════════════════════════════════════
echo "── Stage 4: Resolve Agent ───────────────────────────────"

FINAL_PLAN=$(run_agent_retry "Resolve" "You are a Principal Engineer AI agent. You've received peer review feedback on your design. Address every issue raised and produce the FINAL implementation plan.

ORIGINAL REQUIREMENTS:
${REQUIREMENTS}

ORIGINAL DESIGN:
${DESIGN}

PEER REVIEW FEEDBACK:
${REVIEW}

YOUR TASK:
1. Address every critical and major issue from the review
2. Incorporate valid suggestions
3. Explain what you changed and why
4. Produce the FINAL implementation plan that is ready for a developer to execute

OUTPUT FORMAT:

## Final Implementation Plan

### Review Response
[For each issue raised: how you addressed it, or why you disagree.]

### Updated Plan
[Complete, step-by-step implementation instructions. Specific enough to copy-paste. Include:
- Exact CSS to add (with selectors and properties)
- Exact HTML changes (with element IDs and attributes)
- Exact JS functions to add/modify (with function names and logic)
- Mobile-specific changes
- What to test after each step]

### Files to Modify
[List of files and what changes in each]") || {
  post_stage "Resolve" "**Stage 4: Resolve Agent** ❌ Failed to finalize plan."
  exit 1
}

post_stage "Resolve" "**Stage 4: Resolve Agent — Final Plan** ✅

$FINAL_PLAN"

echo "  [Resolve] Done."

# ════════════════════════════════════════════════════════════════
# STAGE 5: Implement Agent — Write Code
# ════════════════════════════════════════════════════════════════
echo "── Stage 5: Implement Agent ─────────────────────────────"

IMPL_RESULT=$(run_agent_retry "Implement" "You are a Senior Developer AI agent. Implement the feature according to the final plan below. You have full access to read and edit files.

PROJECT DIRECTORY: ${PROJECT_DIR}
MAIN FILE: ${PROJECT_DIR}/index.html (single-page app: HTML + CSS + JS all in one file)
DATA FILES: ${PROJECT_DIR}/topics/*.json

REQUIREMENTS:
${REQUIREMENTS}

FINAL IMPLEMENTATION PLAN:
${FINAL_PLAN}

YOUR TASK:
1. Read index.html to understand current code structure
2. Implement ALL changes from the plan, step by step
3. After ALL changes are made, verify:
   a. Run: node -e \"const fs=require('fs'); const h=fs.readFileSync('index.html','utf8'); if(h.includes('<script>')) { const js=h.split('<script>')[1].split('</script>')[0]; try { new Function(js); console.log('JS syntax OK'); } catch(e) { console.error('JS ERROR:',e.message); process.exit(1); } }\"
   b. Check that opening/closing tags and braces are balanced
4. Do NOT commit yet — just make the code changes and verify they're correct
5. Output a summary of exactly what you changed (files, line ranges, what was added/modified)

RULES:
- Follow the plan precisely. Do not freelance.
- All changes go in index.html unless the plan says otherwise.
- Make sure mobile styles go inside the @media (max-width:768px) block.
- Use the Edit tool for targeted changes, not full file rewrites.
- Preserve existing indentation style." "Edit,Read,Bash(node *),Bash(jq *),Write" "300") || {
  post_stage "Implement" "**Stage 5: Implement Agent** ❌ Failed to implement.

\`\`\`
${IMPL_RESULT:0:1000}
\`\`\`"
  exit 1
}

echo "  [Implement] Done."

# ════════════════════════════════════════════════════════════════
# STAGE 6: Test Agent — Verify
# ════════════════════════════════════════════════════════════════
echo "── Stage 6: Test Agent ──────────────────────────────────"

TEST_RESULT=$(run_agent_retry "Test" "You are a QA Engineer AI agent. Verify that the implemented feature meets all requirements and doesn't break anything.

PROJECT DIRECTORY: ${PROJECT_DIR}
MAIN FILE: ${PROJECT_DIR}/index.html

REQUIREMENTS & ACCEPTANCE CRITERIA:
${REQUIREMENTS}

IMPLEMENTATION SUMMARY:
${IMPL_RESULT}

YOUR TASK:
1. Read index.html
2. Run syntax validation:
   node -e \"const fs=require('fs'); const h=fs.readFileSync('index.html','utf8'); const js=h.split('<script>')[1].split('</script>')[0]; try { new Function(js); console.log('JS: OK'); } catch(e) { console.error('JS ERROR:',e.message); process.exit(1); }\"
3. Check each acceptance criterion — read the code and verify the implementation satisfies it
4. Check mobile compatibility:
   - Are new styles properly inside @media (max-width:768px)?
   - Any use of hover-only interactions without touch alternatives?
   - Any fixed widths that would break on 375px screens?
   - Any -webkit- prefixes needed for Safari?
5. Check for regressions:
   - Are existing CSS selectors still working? (check specificity conflicts)
   - Are existing JS functions still intact? (check global variable conflicts)
   - Are existing event listeners preserved?
6. Check the JSON data files if they were modified: jq . topics/*.json > /dev/null

OUTPUT FORMAT:

## Test Results

### Syntax Validation
[PASS/FAIL — show command output]

### Acceptance Criteria Verification
[For each criterion: PASS/FAIL with evidence from the code]

### Mobile Compatibility
[PASS/FAIL for each check]

### Regression Check
[PASS/FAIL — any issues found]

### Overall Verdict
[PASS / FAIL — if FAIL, list what needs fixing]

### Fix Instructions (if FAIL)
[Specific instructions for what to fix]" "Read,Bash(node *),Bash(jq *),Bash(grep *)" "180") || {
  post_stage "Test" "**Stage 6: Test Agent** ❌ Failed to run tests."
  exit 1
}

echo "  [Test] Result: $TEST_RESULT"

# Check if tests passed
if echo "$TEST_RESULT" | grep -qi "overall verdict.*fail"; then
  echo "  [Test] FAILED — attempting fix cycle..."

  # ── Fix cycle: send failures back to implement agent ──
  FIX_RESULT=$(run_agent_retry "Fix" "You are a Senior Developer AI agent. The QA team found issues with your implementation. Fix them.

PROJECT DIRECTORY: ${PROJECT_DIR}
MAIN FILE: ${PROJECT_DIR}/index.html

TEST RESULTS WITH FAILURES:
${TEST_RESULT}

YOUR TASK:
1. Read the relevant parts of index.html
2. Fix every issue identified in the test results
3. Re-run syntax validation: node -e \"const fs=require('fs'); const h=fs.readFileSync('index.html','utf8'); const js=h.split('<script>')[1].split('</script>')[0]; try { new Function(js); console.log('JS: OK'); } catch(e) { console.error('JS ERROR:',e.message); process.exit(1); }\"
4. Output what you fixed" "Edit,Read,Bash(node *),Bash(jq *),Write" "300") || {
    post_stage "Fix" "**Stage 6b: Fix Agent** ❌ Failed to fix issues. Manual intervention needed.

Test failures:
\`\`\`
${TEST_RESULT:0:1000}
\`\`\`"
    exit 1
  }

  echo "  [Fix] Applied fixes."
fi

# ════════════════════════════════════════════════════════════════
# STAGE 7: Commit, Push, Close
# ════════════════════════════════════════════════════════════════
echo "── Stage 7: Ship ────────────────────────────────────────"

cd "$PROJECT_DIR"

# Pull latest to avoid conflicts
git pull --rebase origin main 2>/dev/null || true

# Stage and commit
git add -A
COMMIT_MSG="feat: ${USER_REQUEST:0:60} (from issue #${ISSUE_NUMBER})"
git commit -m "$COMMIT_MSG" || {
  echo "  Nothing to commit — no changes were made."
  post_stage "Ship" "**No changes were made** — the implementation agent did not modify any files. This may need manual attention."
  exit 1
}

# Push
git push origin main || {
  echo "  Push failed — attempting rebase..."
  git pull --rebase origin main
  git push origin main
}

echo "  Committed and pushed."

# ── Close issue with full summary ───────────────────────────────
CLOSE_BODY="$(cat <<EOF
**Feature implemented and shipped** ✨✅

### What was done
${IMPL_RESULT:0:500}

### Verification
Tests passed. Syntax validated. Mobile compatibility checked.

### Commit
\`$COMMIT_MSG\`

The change has been pushed to main and will be live on GitHub Pages shortly.

---
*Processed by multi-stage feature pipeline: Product → Architect → Review → Resolve → Implement → Test → Ship*
EOF
)"

gh issue comment "$ISSUE_NUMBER" --repo "$FULL_REPO" --body "$CLOSE_BODY"
gh issue close "$ISSUE_NUMBER" --repo "$FULL_REPO"

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Issue #$ISSUE_NUMBER resolved and closed."
echo "════════════════════════════════════════════════════════════"
