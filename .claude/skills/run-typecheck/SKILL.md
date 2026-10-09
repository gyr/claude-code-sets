---
name: run-typecheck
description: Runs the project type checker on the paths you pass and returns the raw output — never the whole tree. Use this after any change touching types, signatures, or public APIs, before a commit, or when the user asks to typecheck. Invoke as `/run-typecheck <path>...`; without paths it stops with an error. Detection order: uv-locked (uv run mypy) → mypy → pyright → tsc.
argument-hint: <path>...
allowed-tools: Bash
---

## Type check

!`TARGETS='$ARGUMENTS'; if [ -z "$TARGETS" ]; then echo "ERROR: no paths given. Usage: /run-typecheck <path>... — the caller names the files to check; the whole tree is never checked."; elif [ -f uv.lock ] && command -v uv >/dev/null && uv run mypy --version >/dev/null 2>&1; then uv run mypy $TARGETS 2>&1; elif ([ -f pyproject.toml ] || [ -f mypy.ini ] || [ -f setup.cfg ]) && command -v mypy >/dev/null; then mypy $TARGETS 2>&1; elif ([ -f pyproject.toml ] || [ -f mypy.ini ] || [ -f setup.cfg ]) && command -v uv >/dev/null && uv run mypy --version >/dev/null 2>&1; then uv run mypy $TARGETS 2>&1; elif [ -f pyrightconfig.json ] && command -v pyright >/dev/null; then pyright $TARGETS 2>&1; elif [ -f tsconfig.json ]; then echo "STOP: tsc has no per-file mode — passing files makes it ignore tsconfig.json, so it only checks the whole project. Not run."; else echo "No type checker detected (looked for uv.lock, mypy, pyright, tsc)"; fi`

If the output starts with `ERROR:`, stop and report it — never rerun without paths or with `.`.

If the output starts with `STOP:`, stop. Explain to the operator that this type checker can only run on the whole project, and ask whether to proceed. Run it only after an explicit yes.

Otherwise return the output as-is. Do not summarize.
