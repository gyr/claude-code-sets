# Personal Development Standards

Pro software engineering practices using Claude Code official features: Skills, Subagents, structured context management.

## Scope and Application

**This document defines DEFAULT behavior, not optional reference material.**

**When these standards apply:**
- **MANDATORY for:** New features, refactoring, bug fixes, performance work, security changes
- **RELAXED for:** Trivial typo fixes, comment-only changes, documentation updates
- **Default rule:** If scope unclear, follow these standards

**Enforcement:**
- Follow these standards WITHOUT waiting for explicit "follow CLAUDE.md" prompt
- Standards are standing instructions, not on-demand guidance
- Only deviate when user explicitly requests different approach

## Core Development Philosophy

**Principles override all other considerations:**

1. **Test-Driven Development** - Write tests first, always. Never write production code without failing test.

2. **Systematic over ad-hoc** - Follow process, measure, verify. Never guess or assume. Use profiling data, run tests, check metrics. "It should work" not acceptable without evidence.

3. **Simplicity as PRIMARY goal** - Prefer simple over clever. Remove complexity before adding features. Three similar lines beat premature abstraction. Reject solutions that add indirection without proven need.

4. **Evidence over claims** - Verify with tests/profiling/data before declaring success. No "should work" without proof. Run code. Check output. Measure result.

## Code Style & Standards

- **Naming**: Clear, descriptive (e.g., `isUserAuthenticated` not `check`)
- **Functions**: Small, single responsibility; early returns over deep nesting
- **Comments**: Explain WHY, not WHAT (code self-documents)
- **DRY**: Extract common patterns into reusable functions
- **Error Handling**: Explicit; catch specific errors; early returns over nested try-catch
- **Type Safety**: Maximize type coverage; avoid `any`/dynamic types without justification
- **Dependencies**: Prefer stdlib over 3rd-party when sufficient; use widely-adopted libs when needed

## Test-Driven Development (TDD) Workflow

**ALWAYS follow Red-Green-Refactor cycle:**

1. **RED Phase** - Write failing test first
   - Test must fail for right reason (feature not exist yet)
   - Run test to confirm fails
   - Never write production code without failing test

2. **GREEN Phase** - Write minimal code to pass test
   - Implement just enough to make test pass
   - No features not covered by tests
   - Run tests to verify pass

3. **REFACTOR Phase** - Improve code quality while keeping tests green
   - Clean up duplication
   - Improve naming and structure
   - Optimize performance if needed
   - Tests must stay green throughout refactoring

**Testing Best Practices:**
- Run focused tests during TDD cycle (single test or test file)
- Run full test suite before commits
- Generate coverage reports to identify untested code paths
- Use project-specific test commands (see project CLAUDE.md)

## Architecture Principles

- **SOLID Principles**: Follow Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- **Composition over Inheritance**: Prefer composing objects over class inheritance
- **Explicit over Implicit**: Make dependencies and behavior explicit in code
- **Separation of Concerns**: Keep business logic, data access, presentation separate
- **Contract-First Design**: Define interfaces before implementation

## Security Standards

- **No Hardcoded Secrets**: Use environment variables or config files (never commit secrets)
- **Input Validation**: Always validate and sanitize user input
- **SQL Injection Prevention**: Use parameterized queries, never string concatenation
- **XSS Prevention**: Escape output, validate input
- **Command Injection**: Avoid shell execution with user input; use language-specific safe APIs

## Git Workflow

**Branch Naming:**
- `feature/descriptive-name` - New features
- `fix/issue-description` - Bug fixes
- `refactor/what-changed` - Code refactoring
- `docs/what-documented` - Documentation updates

**Commit Messages:**
- Use Conventional Commits format: `type(scope): description`
- Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`
- Example: `feat(auth): add OAuth2 login support`

**Before Committing:**
1. Run tests
2. Run linter
3. Format code
4. Verify staged changes: `git diff --staged`

## Performance Guidelines

- **Algorithmic Efficiency**: Target O(1), O(log n), or O(n) complexity
- **Avoid Nested Loops**: Use hash tables/sets for O(1) lookups instead of O(n) scans
- **Lazy Loading**: Use lazy evaluation for large datasets
- **Profiling**: Use language-specific profilers to identify bottlenecks before optimizing
- **Optimization Rule**: No optimize without profiling data

## Documentation Standards

- **Public APIs**: Document all public functions with docstrings/comments
- **Complex Logic**: Add comments explaining non-obvious decisions
- **ADRs**: Maintain Architecture Decision Records in `docs/adr/`
- **README**: Keep README.md up to date with setup instructions

## Required Skills Usage

**Must use these skills when applicable** - they enforce best practices:

- `/tdd` - Execute Red-Green-Refactor TDD cycle (required for new features/bug fixes)
- `/code-review` - Perform thorough code review (required before commits)
- `/security-audit` - Security vulnerability scan (required for auth/input handling/sensitive data)
- `/performance-check` - Analyze algorithmic complexity and performance (required for optimization work)
- `/plan-architecture` - Design system architecture (required for major features/refactors)

**When to use:**
- Use proactively when task matches skill domain
- Don't wait for explicit request - invoke when adds value
- Invoke with `/skill-name` or let Claude auto-trigger

Project-specific skills may be defined in `.claude/skills/` within individual projects.