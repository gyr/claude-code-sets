---
name: run-linter
description: Runs the project linter on the paths you pass (diagnose only, never modifies files) and returns the raw output — never the whole tree. Use this after code changes, before a commit, or when the user asks to lint or check code quality. Invoke as `/run-linter <path>...`; without paths it stops with an error. Detection order: uv-locked (uv run ruff) → ruff → flake8 → eslint → clippy → go vet.
argument-hint: <path>...
allowed-tools: Bash
---

## Lint report

!`TARGETS='$ARGUMENTS'; if [ -z "$TARGETS" ]; then echo "ERROR: no paths given. Usage: /run-linter <path>... — the caller names the files to lint; the whole tree is never linted."; elif [ -f uv.lock ] && command -v uv >/dev/null && uv run ruff --version >/dev/null 2>&1; then uv run ruff check $TARGETS 2>&1; elif ([ -f pyproject.toml ] || [ -f setup.py ]) && command -v ruff >/dev/null; then ruff check $TARGETS 2>&1; elif ([ -f pyproject.toml ] || [ -f setup.py ]) && command -v uv >/dev/null && uv run ruff --version >/dev/null 2>&1; then uv run ruff check $TARGETS 2>&1; elif ([ -f pyproject.toml ] || [ -f setup.py ]) && command -v flake8 >/dev/null; then flake8 $TARGETS 2>&1; elif [ -f package.json ]; then npx --no-install eslint $TARGETS 2>&1 || echo "ESLint not configured or not installed"; elif [ -f Cargo.toml ]; then echo "STOP: cargo clippy has no per-file mode — it lints the whole project. Not run."; elif [ -f go.mod ]; then echo "STOP: go vet has no per-file mode — it lints whole packages. Not run."; else echo "No linter detected (looked for ruff, flake8, eslint, clippy, go vet)"; fi`

If the output starts with `ERROR:`, stop and report it — never rerun without paths or with `.`.

If the output starts with `STOP:`, stop. Explain to the operator that this linter can only run on the whole project or whole packages, and ask whether to proceed. Run it only after an explicit yes.

Otherwise return the output as-is. Do not summarize.
