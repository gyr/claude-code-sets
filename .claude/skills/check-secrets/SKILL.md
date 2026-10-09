---
name: check-secrets
description: Greps committed changes and the paths you pass — including new, unstaged files — for hardcoded credential patterns (API keys, tokens, passwords, private keys); never the whole tree. Use this during security audits, as a pre-commit check, and whenever the user asks whether a secret may have leaked into a change. Invoke as `/check-secrets <path>...`; without paths it stops with an error.
argument-hint: <path>...
allowed-tools: Bash
---

## Secret patterns in diff

!`bash ${CLAUDE_SKILL_DIR}/scan-secrets.sh $ARGUMENTS`

If the output starts with `ERROR:`, stop and report it — never rerun without paths or with `.`.

⚠️ Matches are CANDIDATES, not confirmed secrets — review surrounding context (test fixtures, doc examples) before flagging.
