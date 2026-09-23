# Claude Code — Professional Development Setup

A project-scoped Claude Code configuration that turns the assistant into a disciplined development team: TDD enforced, code reviewed with fresh eyes, security audited against OWASP, performance optimized only with profiling data, and architecture planned contract-first.

Everything lives under `.claude/` and is committed to the repo so the same standards apply to every collaborator and every session.

---

## What is `.claude/`?

`.claude/` is the Claude Code configuration directory. When `claude` starts in this project it automatically reads everything inside.

```
.claude/
├── CLAUDE.md              # Project standards — loaded into every session
├── agents/                # Specialist personas — invoked via @name
│   ├── architect.md
│   ├── code-reviewer.md
│   ├── performance-analyst.md
│   ├── security-auditor.md
│   └── tdd-coach.md
└── skills/                # Atomic helpers — invoked via /name
    ├── get-diff/SKILL.md
    ├── run-tests/SKILL.md
    ├── run-linter/SKILL.md
    ├── run-formatter/SKILL.md
    ├── run-typecheck/SKILL.md
    ├── check-secrets/SKILL.md
    ├── check-deps-cve/SKILL.md
    ├── check-coverage/SKILL.md
    ├── caveman-on/SKILL.md
    ├── caveman-off/SKILL.md
    └── caveman-micro/SKILL.md
```

---

## What does it provide?

### 1. `CLAUDE.md` — persistent project standards

Loaded into every session. Defines the rules the assistant operates under without you having to repeat them:

- **Honesty hygiene** — no affirmation openers, verify before agreeing, no invented disagreement.
- **Core principles** — TDD, simplicity, evidence over claims.
- **Code style** — naming, error handling, type safety, dependency preferences.
- **Architecture** — SOLID + composition + contract-first design.
- **Security** — OWASP Top 10 hygiene baseline.
- **Git workflow** — Conventional Commits, one logical change per commit, bisect-friendly history, pre-commit checklist.
- **Performance** — no optimization without profiling.
- **Agents & skills registry** — when to invoke each.

### 2. Five specialist agents (`.claude/agents/`)

Agents are full personas with **isolated context** and **summary return**. Use them when the work calls for a specific expert mindset.

| Agent | Role | When to invoke |
|:------|:-----|:---------------|
| `@architect` | Senior Software Architect — read-only, returns the plan as a message (no file) with SOLID contracts, commit boundaries, doc impact | Major features, refactors, anything multi-phase — **before** writing code |
| `@tdd-coach` | TDD enforcer driving strict Red-Green-Refactor cycles | New features, bug fixes |
| `@code-reviewer` | Senior Staff Engineer reviewing the diff with fresh eyes — logic, readability, security, perf, tests, commit hygiene | After significant changes, before commits |
| `@security-auditor` | Cyber Security Specialist auditing against OWASP Top 10 | Auth, input handling, sensitive-data work, security-impacting diffs |
| `@performance-analyst` | Performance Engineering Specialist — refuses to optimize without baseline profile | Optimization work (with a reproducible workload) |

Each agent has a non-negotiable **rigor clause** that prevents lazy output: the architect must name a real alternative and why it loses; the code-reviewer must enumerate what was checked when reporting zero findings; the security-auditor must justify every APPROVE; the TDD coach must list three inputs that would still break the code; the performance-analyst refuses recommendations without before/after numbers.

### 3. Eight atomic skills (`.claude/skills/`)

Skills are stateless single-purpose helpers run **inline** in the main session. They are the building blocks the agents (and you) compose.

| Skill | What it does |
|:------|:-------------|
| `/get-diff` | Diff vs `main` (or `origin/main`) + working-tree status |
| `/run-tests` | Project test suite — `pytest` → `npm test` → `cargo test` → `go test` (auto-detected) |
| `/run-linter` | Lint diagnostics — `ruff check` → `flake8` → `eslint` → `clippy` → `go vet` |
| `/run-formatter` | Apply canonical formatting — `ruff format` → `black` → `prettier` → `gofmt` → `rustfmt` (modifies files) |
| `/run-typecheck` | Type check — `mypy` → `pyright` → `tsc` |
| `/check-secrets` | Greps the diff for hardcoded credential patterns (API keys, tokens, PEM blocks) |
| `/check-deps-cve` | Dependency CVE scan — `pip-audit` / `safety` / `npm audit` / `cargo audit` / `govulncheck` |
| `/check-coverage` | Coverage report — `pytest --cov` → `jest --coverage` |

Plus three response-mode modifiers:

| Skill | What it does |
|:------|:-------------|
| `/caveman-on` | Enable ultra-concise responses for the rest of the session |
| `/caveman-off` | Return to normal response style |
| `/caveman-micro` | One-shot concise response without changing session mode |

All atomic skills are **Python-first** (the user's primary stack) and fall back to Node, Rust, and Go automatically.

---

## How does it work?

### Agents vs skills — the split

Both surfaces are loaded on demand; the difference is **context isolation** and **shape of work**.

| | Agents (`@name`) | Skills (`/name`) |
|:--|:-----------------|:------------------|
| Context | Separate window, returns a summary | Inline in main session |
| Work shape | Multi-step reasoning, judgment calls | Single deterministic action |
| Typical size | Hundreds of lines of instruction + rigor clauses | A single Bash command + framing |
| Examples | "Review this diff end-to-end", "Plan the auth rewrite" | "Run the linter", "Show the diff" |

Rule of thumb: if the work needs **reasoning across files** or a **specific persona**, use an agent. If the work is a **single check or command**, use a skill.

### How agents use skills

Agents compose atomic skills inside their workflows. For example, `@code-reviewer` runs `/get-diff` first, then `/check-secrets`, `/run-tests`, `/run-linter`, `/run-typecheck`, `/check-coverage` as part of its review pass. You don't run those by hand during a review — the agent does, and you read the consolidated finding list.

### Built-in `/code-review` vs `@code-reviewer`

Claude Code ships a bundled `/code-review` skill for quick reviews. This repo also defines `@code-reviewer` — the agent — for deep reviews with rigor clauses, fresh-eyes framing, and severity-graded output. Use:

- `/code-review` → fast pre-commit gut check
- `@code-reviewer` → before pushing, before a PR, when something feels off

---

## How to use it

### 1. Start a session

```bash
cd /path/to/this/project
claude
```

`CLAUDE.md` is loaded automatically. Agent and skill descriptions become available.

### 2. Invoke an agent for substantive work

```
@tdd-coach implement email validation
@architect design the OAuth integration
@code-reviewer review the changes on this branch
@security-auditor audit the new login endpoint
@performance-analyst the user search is slow with 10k records
```

The agent runs in its own context and reports back a summary — your main context stays clean.

### 3. Invoke a skill for an atomic action

```
/get-diff
/run-tests
/run-linter
/check-secrets
/caveman-on
```

Skills run inline; output appears in the conversation immediately.

### 4. Typical workflow — feature with TDD + review

```
@tdd-coach add password strength validation
        # drives Red → Green → Refactor; runs /run-tests between phases
@code-reviewer
        # fresh-eyes review of the resulting diff
/run-formatter
        # canonicalize style
/check-secrets
        # final scan before staging
git add ... && git commit -m "feat(auth): add password strength validation"
```

### 5. Typical workflow — major change

```
@architect plan the migration from sessions to JWT
        # returns the plan with phases + commit boundaries (no file written)
@tdd-coach implement phase 1
@security-auditor audit phase 1
@code-reviewer
git commit ...
# repeat per phase
```

---

## Why this shape?

- **Stateless skills** are cheap to load, easy to compose, and don't pollute the main context. They are the right surface for "run a command, return the output."
- **Persona agents** carry a non-trivial system prompt with rigor clauses and structured output formats. Putting that in a separate context window prevents the main session from being dominated by review checklists and security taxonomies.
- **Project-scoped under `.claude/`** means the configuration is versioned with the code. Every collaborator gets the same standards; reviewers can see the standards diff alongside the feature diff.

---

## Extending the setup

### Add an agent

Create `.claude/agents/<name>.md`:

```markdown
---
name: <name>
description: <one-line summary used to decide when to invoke>
tools: Read, Grep, Glob, Bash    # least-privilege; add Edit/Write only if needed
model: inherit
---

You are <persona>. <Single-sentence mandate>.

## When invoked
1. ...

## Output format
...

## Rigor clause (non-negotiable)
<What the agent must justify before declaring done>
```

Register it in `.claude/CLAUDE.md` under **Required Agents** so the convention spreads.

### Add a skill

Create `.claude/skills/<name>/SKILL.md`:

```markdown
---
description: <one-line summary>
allowed-tools: Bash
---

## <Section>

!`<single command or short pipeline>`

Return the output as-is. Do not summarize.
```

Keep skills atomic — if the description needs "and", split it.

### Customize standards

Edit `.claude/CLAUDE.md` to add project-specific deltas (frameworks in use, naming conventions, deployment quirks). The file is intentionally short — keep it that way.

---

## File map

| Path | Purpose |
|:-----|:--------|
| `.claude/CLAUDE.md` | Project standards loaded into every session |
| `.claude/agents/*.md` | Specialist personas (`@name`) |
| `.claude/skills/*/SKILL.md` | Atomic helpers (`/name`) |
| `CLAUDE.python.md` | Python-specific style notes (reference) |
| `USAGE_GUIDE.md`, `CONTEXT_MANAGEMENT_GUIDE.md`, etc. | Background guides on Claude Code itself |

The guide documents at the project root predate this refactor and may reference the old monolithic-skills layout — they are kept as background reading on Claude Code mechanics, not as the source of truth for what this repo provides. The source of truth is this README and `.claude/CLAUDE.md`.
