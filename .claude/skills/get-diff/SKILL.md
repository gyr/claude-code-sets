---
description: Returns the diff between current branch and main (or origin/main) plus working-tree status. Use to see what changed before review.
allowed-tools: Bash
---

## Current diff vs main

!`git diff main...HEAD 2>/dev/null || git diff origin/main...HEAD 2>/dev/null || git diff HEAD`

## Working tree status

!`git status --short`

Return the output as-is. Do not summarize.
