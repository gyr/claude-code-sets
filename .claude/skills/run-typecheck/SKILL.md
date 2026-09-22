---
name: run-typecheck
description: Runs the project type checker and returns the raw output. Use this after any change touching types, signatures, or public APIs, before a commit, or when the user asks to typecheck. Detection order: uv-locked (uv run mypy) → mypy → pyright → tsc.
allowed-tools: Bash
---

## Type check

!`if [ -f uv.lock ] && command -v uv >/dev/null && uv run mypy --version >/dev/null 2>&1; then uv run mypy . 2>&1; elif ([ -f pyproject.toml ] || [ -f mypy.ini ] || [ -f setup.cfg ]) && command -v mypy >/dev/null; then mypy . 2>&1; elif ([ -f pyproject.toml ] || [ -f mypy.ini ] || [ -f setup.cfg ]) && command -v uv >/dev/null && uv run mypy --version >/dev/null 2>&1; then uv run mypy . 2>&1; elif [ -f pyrightconfig.json ] && command -v pyright >/dev/null; then pyright 2>&1; elif [ -f tsconfig.json ]; then npx --no-install tsc --noEmit 2>&1; else echo "No type checker detected (looked for uv.lock, mypy, pyright, tsc)"; fi`

Return the output as-is. Do not summarize.
