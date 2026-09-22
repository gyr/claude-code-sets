---
name: check-secrets
description: Greps committed and uncommitted changes for hardcoded credential patterns (API keys, tokens, passwords, private keys). Use this during security audits, as a pre-commit check, and whenever the user asks whether a secret may have leaked into a change.
allowed-tools: Bash
---

## Secret patterns in diff

!`bash ${CLAUDE_SKILL_DIR}/scan-secrets.sh`

⚠️ Matches are CANDIDATES, not confirmed secrets — review surrounding context (test fixtures, doc examples) before flagging.
