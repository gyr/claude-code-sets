---
name: run-linter
description: Runs the project linter (diagnose only, never modifies files) and returns the raw output. Use this after code changes, before a commit, or when the user asks to lint or check code quality. Detection order: uv-locked (uv run ruff) → ruff → flake8 → eslint → clippy → go vet.
allowed-tools: Bash
---

## Lint report

!`if [ -f uv.lock ] && command -v uv >/dev/null && uv run ruff --version >/dev/null 2>&1; then uv run ruff check . 2>&1; elif ([ -f pyproject.toml ] || [ -f setup.py ]) && command -v ruff >/dev/null; then ruff check . 2>&1; elif ([ -f pyproject.toml ] || [ -f setup.py ]) && command -v uv >/dev/null && uv run ruff --version >/dev/null 2>&1; then uv run ruff check . 2>&1; elif ([ -f pyproject.toml ] || [ -f setup.py ]) && command -v flake8 >/dev/null; then flake8 2>&1; elif [ -f package.json ]; then npx --no-install eslint . 2>&1 || echo "ESLint not configured or not installed"; elif [ -f Cargo.toml ]; then cargo clippy 2>&1; elif [ -f go.mod ]; then go vet ./... 2>&1; else echo "No linter detected (looked for ruff, flake8, eslint, clippy, go vet)"; fi`

Return the output as-is. Do not summarize.
