---
name: run-tests
description: Runs the project test suite and returns the raw output. Use this whenever tests need running — after code changes, before a commit, during TDD red/green cycles, or when the user asks to run tests. Detection order: uv-locked (uv run pytest) → pytest → npm test → cargo test → go test.
allowed-tools: Bash
---

## Test run

!`if [ -f uv.lock ] && command -v uv >/dev/null && uv run pytest --version >/dev/null 2>&1; then uv run pytest 2>&1; elif ([ -f pyproject.toml ] || [ -f pytest.ini ] || [ -f setup.py ] || [ -f tox.ini ]) && command -v pytest >/dev/null; then pytest 2>&1; elif ([ -f pyproject.toml ] || [ -f pytest.ini ] || [ -f setup.py ] || [ -f tox.ini ]) && command -v uv >/dev/null && uv run pytest --version >/dev/null 2>&1; then uv run pytest 2>&1; elif [ -f package.json ]; then npm test 2>&1; elif [ -f Cargo.toml ]; then cargo test 2>&1; elif [ -f go.mod ]; then go test ./... 2>&1; else echo "No test runner detected (looked for uv.lock, pyproject.toml, pytest.ini, setup.py, tox.ini, package.json, Cargo.toml, go.mod)"; fi`

Coverage is a separate concern — use `/check-coverage` for that.

Return the output as-is. Do not summarize.
