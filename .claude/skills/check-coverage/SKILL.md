---
description: Generates and reports test coverage. Python-first: pytest --cov → jest --coverage.
allowed-tools: Bash
---

## Coverage report

!`if [ -f pyproject.toml ] || [ -f setup.py ] || [ -f pytest.ini ]; then pytest --cov --cov-report=term-missing 2>&1; elif [ -f package.json ]; then npm test -- --coverage 2>&1; elif [ -f Cargo.toml ]; then echo "Rust coverage requires tarpaulin or llvm-cov; not auto-detected."; else echo "No supported coverage runner detected"; fi`

Return the output as-is. Do not summarize.
