---
description: Runs the project type checker. Python-first: mypy → pyright → tsc.
allowed-tools: Bash
---

## Type check

!`if ([ -f pyproject.toml ] || [ -f mypy.ini ] || [ -f setup.cfg ]) && command -v mypy >/dev/null; then mypy . 2>&1; elif [ -f pyrightconfig.json ] && command -v pyright >/dev/null; then pyright 2>&1; elif [ -f tsconfig.json ]; then npx --no-install tsc --noEmit 2>&1; else echo "No type checker detected (looked for mypy, pyright, tsc)"; fi`

Return the output as-is. Do not summarize.
