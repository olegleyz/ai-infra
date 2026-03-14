# Knowledge Map Comment Agent

## Overview

This agent polls GitHub Issues for user comments submitted from the knowledge map. For each issue it:
1. Invokes Claude with file editing tools to update the relevant node in `topics/*.json`
2. Commits and pushes the change to main
3. Posts a summary back to the issue and closes it

The knowledge map site auto-deploys from main via GitHub Pages, so changes go live within minutes.

## How to Run

```bash
# One-shot (process all open issues)
bash agent/poll-comments.sh

# Cron (every 5 minutes)
*/5 * * * * export PATH="..." && bash /path/to/agent/poll-comments.sh >> /tmp/poll-comments.log 2>&1
```

## Requirements

- **gh** — GitHub CLI, authenticated (`gh auth login`)
- **jq** — JSON processor
- **claude** — Claude CLI (needs tool access: Edit, Read, Bash for git)

## Issue Format

**Title:** `[topicId:nodeId] First 60 chars of user comment...`

**Body:**
```
**Topic:** AI Data Centers
**Node:** Nuclear & SMRs (nuclear-smrs)
**Path:** root › Value Chain Layers › ...

---

User's full comment text here
```

**Label:** `user-comment`

## What Claude Does Per Issue

1. Reads `topics/{topicId}.json`
2. Finds the node by ID
3. Updates the node's `details` (and `summary` if needed) with enriched content addressing the user's comment
4. Keeps JSON valid, doesn't touch other nodes
5. Commits: `update {topicId}: enrich {nodeId} (from issue #{number})`
6. Pushes to origin main

## Edge Cases

- **Unparseable title** → posts notice, closes issue
- **Missing topic file** → posts notice, closes issue
- **Claude fails** → logs error, skips to next issue
- **No open issues** → exits cleanly
