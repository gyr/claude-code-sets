---
description: Runs the project test suite. Python-first detection (pytest), then Node (npm test), then Rust (cargo test).
allowed-tools: Bash
---

## Test run

!`if [ -f pyproject.toml ] || [ -f pytest.ini ] || [ -f setup.py ] || [ -f tox.ini ]; then pytest 2>&1; elif [ -f package.json ]; then npm test 2>&1; elif [ -f Cargo.toml ]; then cargo test 2>&1; elif [ -f go.mod ]; then go test ./... 2>&1; else echo "No test runner detected (looked for pyproject.toml, pytest.ini, setup.py, tox.ini, package.json, Cargo.toml, go.mod)"; fi`

Return the output as-is. Do not summarize.
