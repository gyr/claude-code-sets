# Claude Code Squad - TDD Development Environment

Python project following Test-Driven Development (TDD) and professional software engineering practices.

**Note**: General development standards are in `~/.claude/CLAUDE.md`. This file contains Python-specific project configuration.

## Python Testing Commands
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
# Install dependencies (using uv)
uv pip install -r requirements.txt

# Or sync project dependencies
uv sync

# Run linter (using ruff)
ruff check src/ tests/

# Format code (using ruff)
ruff format src/ tests/

# Type checking
mypy src/

# Run the application
uv run python -m src.main
```

## Python Standards

**Style:**
- PEP 8 strict: 4 spaces, snake_case funcs/vars, PascalCase classes
- Type hints all function signatures; use `|` syntax (3.10+); avoid `Any`
- Docstrings: Google/NumPy style, include summary/Args/Returns

**Idioms:**
- f-strings for interpolation (not %, format)
- List comps over map/filter
- Context managers (`with`) for files/locks/DB
- Truthiness: `if items:` not `if len(items) > 0:`
- Early returns, avoid deep nesting

**Data/Async:**
- dataclasses/Pydantic over raw dicts
- Generator expressions for large datasets
- `async`/`await` for I/O-bound tasks

**Error Handling:**
- EAFP style: try/except over LBYL
- Catch specific exceptions, never bare `Exception`
- Early returns for error cases

**Performance:**
- `cProfile` for bottlenecks
- dict/set lookups O(1) over list scans O(n)

## Project Documentation

- `CONTEXT_MANAGEMENT_GUIDE.md` - Context window management strategies
- `TOKEN_OPTIMIZATION_GUIDE.md` - Subagent usage and token optimization
- `docs/adr/` - Architecture Decision Records
