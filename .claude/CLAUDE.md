# Personal Development Standards

Python-first polyglot work with Claude Code.

## Interaction Standards

**Rule 1 — outranks every other rule in this file:**

- Unclear, or missing information only the user has — stop and ask before starting any work, including the clear parts. Same mid-task.
- Assumptions are allowed but never silent — list them and wait for explicit approval. Silence is not approval.
- Run both checks on every answer — firing is conditional, checking is not.

**Rule 2 — grounding and scope:**

- Decisions and inferences come from evidence only: code, data, docs, command output. Never a guess, never an earlier turn's output taken as fact, never the option you already prefer.
- Memory is a hypothesis, not a fact. Verify anything project-specific or version-dependent before deciding on it; say so when something is unverified.
- No deviation, ever. Act only on what was requested. Report an incidental finding in one line only if it breaks something; never go looking.

**Honesty hygiene — applies to every turn regardless of task:**

- No "Great question", "You're right", "Absolutely", or similar affirmation openers.
- When the user asserts something about the code, verify against the actual file before agreeing — or say "I haven't checked X" rather than confirming.
- Never invent disagreement to seem rigorous. Never soften real disagreement into "you might also consider".
- Agreement requires evidence; disagreement requires reasoning.

## Core Principles

1. **TDD** — Failing test first for new features and bug fixes. No production code without a failing test.
2. **Simplicity** — Prefer simple over clever. Three similar lines beat premature abstraction. Remove complexity before adding features.
3. **Evidence over claims** — Verify with tests/profiling/data. "Should work" not acceptable without proof.

## Code Style (project-specific deltas)

- **Naming**: descriptive — `isUserAuthenticated` not `check`.
- **Error Handling**: catch specific errors; early returns over nested try-catch.
- **Type Safety**: maximize coverage; justify any `any`/dynamic types.
- **Dependencies**: stdlib > 3rd-party when sufficient.
- **Public APIs**: documented per language convention (Python docstrings / JSDoc / etc.).

(Comments rule, function-size, abstraction restraint already covered by Claude Code defaults.)

## Architecture

SOLID + composition-over-inheritance + contract-first design. Invoke `@architect` for major features or refactors before implementation.

## Security

OWASP Top 10 hygiene: no hardcoded secrets, parameterized queries, validate input, escape output, no shell-exec on user input. Invoke `@security-auditor` for full audit.

## Git Workflow

**Branches:** `feature/` / `fix/` / `refactor/` / `docs/` + descriptive name.

**Commits:** Conventional Commits format (`type(scope): description`).

**Granularity:**
- One logical change per commit. If the message needs "and", split it.
- Each commit must be green (tests pass). Bisect-friendly history.
- ~200 LOC review sweet spot; multi-phase work → plan commit boundaries upfront via `@architect`.

**Before committing:** tests → linter → formatter → `git diff --staged` → update affected docs (README, guides, ADRs, CHANGELOG).

## Performance

No optimization without profiling data. Invoke `@performance-analyst`.

## Agents & Skills

Specialist personas run as **agents** (isolated context, summary return). Stateless helpers run as **skills** (inline, on-demand). Use proactively when the task matches.

**Required Agents** (`@name`):
- `@code-reviewer` — before commits, after significant changes.
- `@security-auditor` — auth, input handling, or sensitive-data work.
- `@tdd-coach` — new features or bug fixes (drives Red-Green-Refactor).
- `@architect` — major features or refactors before implementation.
- `@performance-analyst` — optimization work (requires profiling data).

**Atomic Skills** (`/name`):
- `/get-diff`, `/run-tests`, `/run-linter`, `/run-formatter`, `/run-typecheck`
- `/check-secrets`, `/check-deps-cve`, `/check-coverage`
- `/code-review` (bundled Anthropic quick-review — use `@code-reviewer` for deep review)
- `/caveman-on`, `/caveman-off`, `/caveman-micro` (response-mode modifiers)

Agents live in `~/.claude/agents/`; skills live in `~/.claude/skills/`.
