# Claude Code Squad - TDD Development Environment

This project follows Test-Driven Development (TDD) and professional software engineering practices using Claude Code's official features: Skills, Subagents, and structured context management.

## Core Development Philosophy

**These principles override all other considerations:**

1. **Test-Driven Development** - Write tests first, always. Never write production code without a failing test.

2. **Systematic over ad-hoc** - Follow process, measure, verify. Never guess or assume. Use profiling data, run tests, check metrics. "It should work" is not acceptable without evidence.

3. **Simplicity as PRIMARY goal** - Prefer simple over clever. Remove complexity before adding features. Three similar lines beats premature abstraction. Reject solutions that add indirection without proven need.

4. **Evidence over claims** - Verify with tests/profiling/data before declaring success. No "should work" without proof. Run the code. Check the output. Measure the result.

## Code Style & Standards

- **Naming**: Use clear, descriptive names for functions, variables, and classes
- **Functions**: Keep functions small and focused on a single responsibility
- **Comments**: Write comments explaining WHY, not WHAT (code should be self-documenting)
- **DRY Principle**: Don't Repeat Yourself - extract common patterns into reusable functions
- **Error Handling**: Always handle errors explicitly, never silently catch and ignore

## Test-Driven Development (TDD) Workflow

**ALWAYS follow the Red-Green-Refactor cycle:**

1. **RED Phase** - Write a failing test first
   - Test must fail for the right reason (feature doesn't exist yet)
   - Run the test to confirm it fails
   - Never write production code without a failing test

2. **GREEN Phase** - Write minimal code to pass the test
   - Implement just enough to make the test pass
   - Don't add features not covered by tests
   - Run tests to verify they pass

3. **REFACTOR Phase** - Improve code quality while keeping tests green
   - Clean up duplication
   - Improve naming and structure
   - Optimize performance if needed
   - Tests must stay green throughout refactoring

**Testing Commands:**
```bash
# Run all tests (use sparingly, prefer focused tests)
pytest

# Run specific test file (preferred for faster feedback)
pytest tests/test_specific.py

# Run single test function (best for TDD workflow)
pytest tests/test_specific.py::test_function_name

# Run with coverage report
pytest --cov=src --cov-report=term-missing
```

## Build & Development Commands

```bash
# Install dependencies
pip install -r requirements.txt

# Run linter
flake8 src/ tests/

# Format code
black src/ tests/

# Type checking (if using type hints)
mypy src/

# Run the application
python -m src.main
```

## Architecture Principles

- **SOLID Principles**: Follow Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- **Composition over Inheritance**: Prefer composing objects over class inheritance
- **Explicit over Implicit**: Make dependencies and behavior explicit in code
- **Separation of Concerns**: Keep business logic, data access, and presentation separate
- **Contract-First Design**: Define interfaces before implementation

## Security Standards

- **No Hardcoded Secrets**: Use environment variables or `.env` files (never commit `.env`)
- **Input Validation**: Always validate and sanitize user input
- **SQL Injection Prevention**: Use parameterized queries, never string concatenation
- **XSS Prevention**: Escape output, validate input
- **Command Injection**: Never use `shell=True` in subprocess calls; use argument lists

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
1. Run tests: `pytest`
2. Run linter: `flake8 src/ tests/`
3. Format code: `black src/ tests/`
4. Verify staged changes: `git diff --staged`

## Performance Guidelines

- **Algorithmic Efficiency**: Target O(1), O(log n), or O(n) complexity
- **Avoid Nested Loops**: Use dictionaries/sets for O(1) lookups instead of O(n) list scans
- **Lazy Loading**: Use generators for large datasets
- **Profiling**: Use `cProfile` to identify bottlenecks before optimizing
- **Optimization Rule**: Don't optimize without profiling data

## Documentation Standards

- **Public APIs**: Document all public functions with docstrings
- **Complex Logic**: Add comments explaining non-obvious decisions
- **ADRs**: Maintain Architecture Decision Records in `docs/adr/`
- **README**: Keep README.md up to date with setup instructions

## Skills Available

This project uses Claude Code Skills for common workflows:

- `/tdd` - Execute Red-Green-Refactor TDD cycle
- `/code-review` - Perform thorough code review
- `/security-audit` - Security vulnerability scan
- `/performance-check` - Analyze algorithmic complexity and performance
- `/plan-architecture` - Design system architecture
- `/git-best-practices` - Git workflow best practices

Invoke skills with `/skill-name` or let Claude use them automatically when relevant.

## Context Management

**Important**: Claude Code's context window fills during long sessions. To maintain quality:

- Use `/context` to check context usage
- Use `/clear` between unrelated tasks
- Use `/compact focus on X` to manually compact with preservation
- Put persistent rules in this CLAUDE.md file, not in conversation
- Use subagents for research that would read many files (invoke with `"Use an Explore subagent to [task]"`)

See `CONTEXT_MANAGEMENT_GUIDE.md` for detailed guidance.
See `TOKEN_OPTIMIZATION_GUIDE.md` for how to invoke subagents and reduce token usage.

## Compact Instructions

When auto-compaction triggers, preserve:
- List of all modified files with their paths
- Test commands that were run
- Architecture decisions made during the session
- Security considerations identified
- Performance optimization decisions
- Any failing tests and their error messages
