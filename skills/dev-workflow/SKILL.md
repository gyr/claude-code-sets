---
name: dev-workflow
description: Complete development workflow from TDD through code review to commit preparation
disable-model-invocation: true
allowed-tools: Bash Skill Read Edit Write
---

# Development Workflow

Execute complete development workflow for task implementation.

## Workflow Steps

### 1. TDD Implementation
Run `/tdd` - Red-Green-Refactor cycle:
- Write failing test
- Implement minimal code to pass
- Refactor while keeping tests green

### 2. Code Review
Run `/code-review` - Review for:
- Code quality
- Logic bugs
- Maintainability
- Best practices

### 3. Security Audit (Conditional)
Run `/security-audit` if task involves:
- Authentication/authorization
- User input handling
- Sensitive data (passwords, tokens, PII)
- Database queries
- File operations with user input

### 4. Performance Check (Conditional)
Run `/performance-check` if:
- Performance-critical code
- Large dataset processing
- Algorithmic complexity matters
- Frequent execution (hot path)

### 5. Git Commit Preparation

Execute pre-commit workflow:

1. **Run tests** - Use project-specific test command from CLAUDE.md
2. **Run linter** - Use project-specific lint command from CLAUDE.md  
3. **Run formatter** - Use project-specific format command from CLAUDE.md
4. **Review changes** - `git diff --staged`
5. **Stage files** - `git add file1.py file2.py ...`
   - **MUST list specific files by name**
   - **NEVER use `git add .` or `git add -A`**
   - Prevents accidental staging of secrets (.env, credentials)

**Show commit message** following conventional format:
```
type(scope): description

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

**DO NOT execute `git commit`** - User runs manually for GPG signing.

## Summary

Workflow ensures:
- ✅ Test coverage (TDD)
- ✅ Code quality (review)
- ✅ Security (if needed)
- ✅ Performance (if needed)
- ✅ Clean commits (pre-commit checks)

User executes final commit with GPG signature.
