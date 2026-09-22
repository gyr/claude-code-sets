---
name: check-coverage
description: Generates and reports test coverage. Use this whenever the user asks about coverage or untested code, before merging a branch, or to verify a new feature actually has tests. Detection order: uv-locked (uv run pytest --cov) → pytest --cov → npm test --coverage. Coverage scope comes from the project config, not from this skill.
allowed-tools: Bash
---

## Coverage report

!`if [ -f uv.lock ] && command -v uv >/dev/null && uv run pytest --version >/dev/null 2>&1; then uv run pytest --cov --cov-report=term-missing 2>&1; elif ([ -f pyproject.toml ] || [ -f setup.py ] || [ -f pytest.ini ]) && command -v pytest >/dev/null; then pytest --cov --cov-report=term-missing 2>&1; elif ([ -f pyproject.toml ] || [ -f setup.py ] || [ -f pytest.ini ]) && command -v uv >/dev/null && uv run pytest --version >/dev/null 2>&1; then uv run pytest --cov --cov-report=term-missing 2>&1; elif [ -f package.json ]; then npm test -- --coverage 2>&1; elif [ -f Cargo.toml ]; then echo "Rust coverage requires tarpaulin or llvm-cov; not auto-detected."; else echo "No supported coverage runner detected"; fi`

Return the output as-is. Do not summarize.
