# Knowledge Map Comment Agent

## Overview

This agent polls GitHub Issues for user comments submitted from the knowledge map, generates responses using Claude, posts them back, and closes the issues.

## How to Run

```bash
# One-shot (process all open issues)
bash agent/poll-comments.sh

# Periodic (every 5 minutes via cron)
*/5 * * * * cd /path/to/aidc && bash agent/poll-comments.sh >> /tmp/poll-comments.log 2>&1

# Manual loop
while true; do bash agent/poll-comments.sh; sleep 300; done
```

## Requirements

- **gh** — GitHub CLI, authenticated (`gh auth login`)
- **jq** — JSON processor
- **claude** — Claude CLI (`claude --print` for non-interactive mode)

## Issue Format

Issues submitted from the knowledge map follow this format:

**Title:** `[topicId:nodeId] First 60 chars of user comment...`

**Body:**
```
**Topic:** AI Data Centers
**Node:** Grid Interconnection Crisis (grid-queues)
**Path:** root › Value Chain Layers › Layer 1: Power & Energy › Grid Interconnection Crisis

---

User's full comment text here
```

**Label:** `user-comment`

## How the Agent Processes Issues

1. Reads `comments.config.json` for owner/repo
2. Lists all open issues with the `user-comment` label
3. For each issue:
   - Parses `[topicId:nodeId]` from the title
   - Extracts the user comment (text after `---` in the body)
   - Loads node context from `topics/{topicId}.json`
   - Builds a prompt with node summary + user comment
   - Calls `claude --print` for a response
   - Posts the response as an issue comment
   - Closes the issue
4. Unparseable or missing topic/node → posts an explanatory comment and closes

## Updating the Knowledge Graph

When a user comment suggests a factual correction or valuable addition:

1. Edit the relevant `topics/{topicId}.json` file
2. Update the node's `details`, `summary`, or other fields as appropriate
3. Run `validate.html` to check the JSON is valid
4. Commit with message: `update {topicId}: {brief description} (from issue #{number})`

## Configuration

Edit `comments.config.json`:

```json
{
  "github": {
    "owner": "your-github-username",
    "repo": "your-repo-name",
    "labels": ["user-comment"]
  }
}
```

The owner/repo must match where the knowledge map site is hosted. No secrets needed — the `gh` CLI handles authentication.
