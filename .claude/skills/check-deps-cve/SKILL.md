---
description: Scans project dependencies for known CVEs. Python-first: pip-audit → safety → npm audit → cargo audit.
allowed-tools: Bash
---

## Dependency vulnerabilities

!`if [ -f pyproject.toml ] || [ -f requirements.txt ] || [ -f Pipfile ]; then if command -v pip-audit >/dev/null; then pip-audit 2>&1; elif command -v safety >/dev/null; then safety check 2>&1; else echo "Install pip-audit (pip install pip-audit) or safety (pip install safety) for Python CVE scanning"; fi; elif [ -f package.json ]; then npm audit 2>&1; elif [ -f Cargo.toml ]; then if command -v cargo-audit >/dev/null; then cargo audit 2>&1; else echo "Install cargo-audit: cargo install cargo-audit"; fi; elif [ -f go.mod ]; then if command -v govulncheck >/dev/null; then govulncheck ./... 2>&1; else echo "Install govulncheck: go install golang.org/x/vuln/cmd/govulncheck@latest"; fi; else echo "No dependency manifest detected"; fi`

Return the output as-is. Do not summarize.
