---
name: tdd
description: Execute Test-Driven Development (TDD) Red-Green-Refactor cycle. Use when implementing new features, fixing bugs, or when the user explicitly asks for TDD workflow. Trigger phrases - "write tests first", "TDD", "test-driven", "red-green-refactor".
when_to_use: Use this skill whenever implementing new functionality or fixing bugs. The skill enforces strict TDD discipline - no production code without a failing test first.
---

# Test-Driven Development (TDD) Workflow

You are guiding the implementation of code using strict Test-Driven Development.

## Core TDD Cycle: Red-Green-Refactor

### Phase 1: RED - Write a Failing Test

**Before writing ANY production code:**

1. **Understand the requirement** from the user's request
2. **Write ONE test** that describes the desired behavior
3. **Run the test** - It MUST fail
4. **Verify it fails for the right reason** (feature doesn't exist, not syntax error)

**Test Guidelines:**
- Test ONE behavior at a time
- Use descriptive test names that explain what's being tested
- Include edge cases: nulls, empty strings, boundary values
- Make assertions specific and clear

**Example Test Structure:**
```python
def test_validate_email_accepts_valid_email():
    """Should return True for properly formatted email addresses"""
    result = validate_email("user@example.com")
    assert result is True

def test_validate_email_rejects_missing_at_symbol():
    """Should return False when @ symbol is missing"""
    result = validate_email("userexample.com")
    assert result is False
```

**Run the test:**
```bash
pytest tests/test_specific.py::test_function_name -v
```

### Phase 2: GREEN - Write Minimal Code

**Goal: Make the test pass with the SIMPLEST possible code**

1. **Write the minimum code** needed to pass the test
2. **Don't add extra features** not covered by tests
3. **Don't worry about perfection** - just make it work
4. **Run the test** to verify it passes

**Green Phase Rules:**
- ✅ Hardcoding values is OK if it passes the test
- ✅ Ugly code is OK - refactoring comes next
- ✅ Duplication is OK - we'll clean it up in refactor
- ❌ Don't add functionality not tested
- ❌ Don't optimize prematurely

**Run the test again:**
```bash
pytest tests/test_specific.py::test_function_name -v
```

### Phase 3: REFACTOR - Improve Code Quality

**Goal: Clean up while keeping tests green**

1. **Look for code smells:**
   - Duplication (DRY violation)
   - Long functions
   - Unclear naming
   - Magic numbers/strings
   - Nested conditionals

2. **Refactor incrementally:**
   - Make ONE change at a time
   - Run tests after EACH change
   - If tests fail, revert and try a different approach

3. **Run ALL related tests:**
```bash
pytest tests/test_specific.py -v
```

**Common Refactorings:**
- Extract methods to reduce duplication
- Rename for clarity
- Replace magic values with named constants
- Simplify conditional logic
- Improve data structures (lists → dicts for O(1) lookup)

### Phase 4: REPEAT

**After refactoring, go back to RED:**
1. Write the next failing test for the next behavior
2. Implement it (GREEN)
3. Refactor
4. Repeat until feature is complete

## Testing Best Practices

**Test Isolation:**
- Each test should be independent
- Use mocks for external dependencies (network, database, filesystem)
- Tests should not depend on execution order

**Test Coverage:**
- Aim for 90%+ branch coverage for new code
- Focus on critical paths and edge cases
- Don't test framework code, test YOUR logic

**Mocking Guidelines:**
```python
from unittest.mock import Mock, patch

@patch('module.external_api_call')
def test_with_mocked_api(mock_api):
    mock_api.return_value = {"status": "success"}
    result = function_that_calls_api()
    assert result == expected_value
```

## Adversarial Testing Mindset

**Your job: Find ways to BREAK the code**

Test these scenarios:
- ✅ Null/None values
- ✅ Empty strings/lists/dicts
- ✅ Boundary values (0, -1, max int)
- ✅ Invalid types
- ✅ Race conditions (for concurrent code)
- ✅ Large payloads
- ✅ Network failures (timeouts, errors)
- ✅ Missing required fields
- ✅ Malformed input

## Output Format

After completing the TDD cycle, provide:

1. **Test Code** - Show all tests written
2. **Production Code** - Show implementation
3. **Test Results** - Paste test output showing all tests passing
4. **Coverage** - Show coverage report if available
5. **Next Steps** - Suggest next test to write, if feature incomplete

## Strict TDD Rules

❌ **NEVER write production code without a failing test first**
❌ **NEVER skip running tests between phases**
❌ **NEVER implement features not covered by tests**
❌ **NEVER refactor without green tests**

✅ **ALWAYS write the test before the code**
✅ **ALWAYS run tests to verify each phase**
✅ **ALWAYS refactor only when tests are green**
✅ **ALWAYS keep refactorings small and incremental**
