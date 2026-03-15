# Knowledge Map Agent System

## Overview

Fully autonomous agent system that processes ALL open GitHub issues to completion. Nothing is left open — every issue is classified, implemented, verified, and closed.

## Scripts

### `poll-comments.sh` — Main poller (runs every 5 min via launchd)
Classifies issues into content/bug/feature, handles content and bugs directly, delegates features to the multi-stage pipeline.

### `process-feature.sh` — Multi-stage feature pipeline
7-stage pipeline for feature requests:

| Stage | Agent Role | What it does |
|-------|-----------|--------------|
| 1 | Product Agent | Converts vague request → requirements, acceptance criteria, definition of done |
| 2 | Architect Agent | Design options, pros/cons, recommended approach, implementation plan |
| 3 | Review Agent | Peer review — catches problems before code is written |
| 4 | Resolve Agent | Addresses review feedback, produces final plan |
| 5 | Implement Agent | Writes code following the plan |
| 6 | Test Agent | Syntax validation, mobile compat, regression check. Fix cycle if failures. |
| 7 | Ship | Commit, push, close issue with full audit trail |

Every stage posts its output to the GitHub issue as a comment, creating a full audit trail.

## Usage

```bash
# Automatic — launchd runs every 5 minutes
# (already configured at ~/Library/LaunchAgents/com.aidc.poll-comments.plist)

# Manual — process all open issues
bash agent/poll-comments.sh

# Process a specific feature request from a GitHub issue
bash agent/process-feature.sh --issue 42

# Create a new feature request and process it (from Claude Code or terminal)
bash agent/process-feature.sh --request "Add dark/light theme toggle"
```

## Comment Types

| Type | Signal | Handler | Closes? |
|------|--------|---------|---------|
| content | "add info", "research", "tell me about" | Direct Claude call → edit JSON → push | Yes |
| bug | "broken", "not working", "display issue" | Direct Claude call → edit code → push | Yes |
| feature | "add button", "navigation", "UI change" | Multi-stage pipeline (7 stages) | Yes |

## Requirements

- **gh** — GitHub CLI, authenticated
- **jq** — JSON processor
- **claude** — Claude CLI
- **node** — for JS syntax validation in test stage
