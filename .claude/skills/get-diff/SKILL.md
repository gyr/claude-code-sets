---
name: get-diff
description: Returns the diff between the current branch and the repository's default branch, plus working-tree status. Use this before a code review, before a commit, or whenever the user asks what changed on this branch.
allowed-tools: Bash
---

## Current diff vs default branch

!`BASE=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null); if [ -z "$BASE" ] && git rev-parse --verify --quiet origin/main >/dev/null; then BASE=origin/main; fi; if [ -z "$BASE" ] && git rev-parse --verify --quiet origin/master >/dev/null; then BASE=origin/master; fi; if [ -z "$BASE" ] && git rev-parse --verify --quiet main >/dev/null; then BASE=main; fi; if [ -z "$BASE" ] && git rev-parse --verify --quiet master >/dev/null; then BASE=master; fi; if [ -z "$BASE" ]; then echo "Base: none found — showing working tree vs HEAD only"; git diff HEAD; else echo "Base: $BASE"; git diff "$BASE...HEAD"; fi`

## Working tree status

!`git status --short`

Return the output as-is. Do not summarize.
