---
name: run-formatter
description: Runs the project formatter on the paths you pass, MODIFYING them to canonical style — never the whole tree. Use this when the user asks to format code, or as the last step before staging a commit. Invoke as `/run-formatter <path>...`; without paths it stops with an error. Detection order: uv-locked (uv run ruff format) → ruff format → black → prettier → gofmt → cargo fmt.
argument-hint: <path>...
allowed-tools: Bash
---

## Format

!`TARGETS='$ARGUMENTS'; if [ -z "$TARGETS" ]; then echo "ERROR: no paths given. Usage: /run-formatter <path>... — the caller names the files to format; the whole tree is never formatted."; elif [ -f uv.lock ] && command -v uv >/dev/null && uv run ruff --version >/dev/null 2>&1; then uv run ruff format $TARGETS 2>&1; elif ([ -f pyproject.toml ] || [ -f setup.py ]) && command -v ruff >/dev/null; then ruff format $TARGETS 2>&1; elif ([ -f pyproject.toml ] || [ -f setup.py ]) && command -v uv >/dev/null && uv run ruff --version >/dev/null 2>&1; then uv run ruff format $TARGETS 2>&1; elif ([ -f pyproject.toml ] || [ -f setup.py ]) && command -v black >/dev/null; then black $TARGETS 2>&1; elif [ -f package.json ]; then npx --no-install prettier --write $TARGETS 2>&1 || echo "Prettier not configured or not installed"; elif [ -f go.mod ]; then gofmt -w $TARGETS && echo "gofmt: done"; elif [ -f Cargo.toml ]; then echo "STOP: cargo fmt has no per-file mode — it formats the whole project. Not run."; else echo "No formatter detected (looked for ruff format, black, prettier, gofmt, rustfmt)"; fi`

⚠️ This skill modifies files. Review the diff after running.

If the output starts with `ERROR:`, stop and report it — never rerun without paths or with `.`.

If the output starts with `STOP:`, stop. Explain to the operator that this formatter can only run on the whole project, and ask whether to proceed. Run it only after an explicit yes.

Otherwise return the output as-is. Do not summarize.
