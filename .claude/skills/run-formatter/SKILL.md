---
name: run-formatter
description: Runs the project formatter, MODIFYING files to canonical style. Use this when the user asks to format code, or as the last step before staging a commit. Detection order: uv-locked (uv run ruff format) → ruff format → black → prettier → gofmt → cargo fmt.
allowed-tools: Bash
---

## Format

!`if [ -f uv.lock ] && command -v uv >/dev/null && uv run ruff --version >/dev/null 2>&1; then uv run ruff format . 2>&1; elif ([ -f pyproject.toml ] || [ -f setup.py ]) && command -v ruff >/dev/null; then ruff format . 2>&1; elif ([ -f pyproject.toml ] || [ -f setup.py ]) && command -v uv >/dev/null && uv run ruff --version >/dev/null 2>&1; then uv run ruff format . 2>&1; elif ([ -f pyproject.toml ] || [ -f setup.py ]) && command -v black >/dev/null; then black . 2>&1; elif [ -f package.json ]; then npx --no-install prettier --write . 2>&1 || echo "Prettier not configured or not installed"; elif [ -f go.mod ]; then gofmt -w . && echo "gofmt: done"; elif [ -f Cargo.toml ]; then cargo fmt 2>&1; else echo "No formatter detected (looked for ruff format, black, prettier, gofmt, rustfmt)"; fi`

⚠️ This skill modifies files. Review the diff after running.

Return the output as-is. Do not summarize.
