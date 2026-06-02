---
description: Greps the current diff for hardcoded credential patterns (API keys, tokens, passwords). Use during security audits and pre-commit checks.
allowed-tools: Bash
---

## Secret patterns in diff

!`(git diff main...HEAD 2>/dev/null || git diff origin/main...HEAD 2>/dev/null || git diff HEAD) | grep -nEi '(api[_-]?key|secret|password|token|aws_access|private[_-]?key)\s*[:=]|-----BEGIN.*PRIVATE KEY-----|sk_(live|test)_[a-zA-Z0-9]+|ghp_[a-zA-Z0-9]{20,}|AKIA[0-9A-Z]{16}' || echo "No obvious secret patterns found in diff."`

⚠️ Matches are CANDIDATES, not confirmed secrets — review surrounding context (test fixtures, doc examples) before flagging.
