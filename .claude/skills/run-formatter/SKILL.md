---
description: Runs the project formatter (MODIFIES files to canonical style). Python-first: ruff format → black → prettier → gofmt → rustfmt.
allowed-tools: Bash
---

## Format

!`if ([ -f pyproject.toml ] || [ -f setup.py ]) && command -v ruff >/dev/null; then ruff format . 2>&1; elif ([ -f pyproject.toml ] || [ -f setup.py ]) && command -v black >/dev/null; then black . 2>&1; elif [ -f package.json ]; then npx --no-install prettier --write . 2>&1 || echo "Prettier not configured or not installed"; elif [ -f go.mod ]; then gofmt -w . && echo "gofmt: done"; elif [ -f Cargo.toml ]; then cargo fmt 2>&1; else echo "No formatter detected (looked for ruff format, black, prettier, gofmt, rustfmt)"; fi`

⚠️ This skill modifies files. Review the diff after running.

Return the output as-is. Do not summarize.
