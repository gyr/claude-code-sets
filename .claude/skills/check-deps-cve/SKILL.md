---
name: check-deps-cve
description: Scans project dependencies for known CVEs. Use this during security audits, before releasing or merging a dependency bump, and whenever the user asks about vulnerable or outdated packages. Detection order: uv-locked (uv run pip-audit) → pip-audit → safety → npm audit → cargo audit → govulncheck.
allowed-tools: Bash
---

## Dependency vulnerabilities

!`if [ -f uv.lock ] && command -v uv >/dev/null && uv run pip-audit --version >/dev/null 2>&1; then uv run pip-audit 2>&1; elif [ -f uv.lock ] || [ -f poetry.lock ] || [ -f pyproject.toml ] || [ -f requirements.txt ] || [ -f Pipfile ]; then if command -v pip-audit >/dev/null; then pip-audit 2>&1; elif command -v safety >/dev/null && safety scan --help >/dev/null 2>&1; then safety scan 2>&1; elif command -v safety >/dev/null; then safety check 2>&1; else echo "Install pip-audit (pip install pip-audit) or safety (pip install safety) for Python CVE scanning"; fi; elif [ -f package.json ]; then npm audit 2>&1; elif [ -f Cargo.toml ]; then if command -v cargo-audit >/dev/null; then cargo audit 2>&1; else echo "Install cargo-audit: cargo install cargo-audit"; fi; elif [ -f go.mod ]; then if command -v govulncheck >/dev/null; then govulncheck ./... 2>&1; else echo "Install govulncheck: go install golang.org/x/vuln/cmd/govulncheck@latest"; fi; else echo "No dependency manifest detected"; fi`

⚠️ A uv-locked project audited with an ambient pip-audit reports the wrong environment. If the uv branch is skipped, check that `uv run pip-audit` is available before trusting a clean result.

Return the output as-is. Do not summarize.
