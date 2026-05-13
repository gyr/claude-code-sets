# Global vs Project-Specific Claude Code Setup

**Official Anthropic best practices for organizing your configuration**

You've identified exactly the right approach! This squad setup is generic enough for `~/.claude/` (global) while project-specific customizations go in `<project>/.claude/`. This document explains how to organize it properly.

---

## 🎯 The Recommended Architecture

### Overview

```
~/.claude/                           # Global (applies to ALL projects)
├── CLAUDE.md                        # Personal coding preferences
├── skills/                          # Universal skills
│   ├── tdd/                         # ✅ TDD works for any project
│   ├── code-review/                 # ✅ Code review works everywhere
│   ├── security-audit/              # ✅ Security is universal
│   ├── performance-check/           # ✅ Performance is universal
│   └── plan-architecture/           # ✅ Architecture patterns are universal

<project>/.claude/                   # Project-specific (only this project)
├── CLAUDE.md                        # Project conventions
├── skills/                          # Project-specific workflows
│   ├── deploy-to-aws/               # ✅ Specific to this project's infra
│   └── run-migration/               # ✅ Specific to this project's DB
└── settings.json                    # Project permissions, hooks
```

### How They Merge

**Official behavior from Anthropic documentation:**

1. **CLAUDE.md files MERGE:**
   - `~/.claude/CLAUDE.md` loads first (personal preferences)
   - `<project>/.claude/CLAUDE.md` loads second (project-specific)
   - Both are in context simultaneously
   - Project-level can override or extend global

2. **Skills from BOTH locations are available:**
   - Global skills always available
   - Project skills available when in that project
   - No conflicts (can have same name, project takes precedence)

3. **Settings cascade:**
   - Enterprise settings (if any)
   - `~/.claude/settings.json` (personal)
   - `<project>/.claude/settings.json` (project)
   - Lower levels override higher levels

---

## 📁 What Belongs Where?

### Global (`~/.claude/`) - Universal, Reusable

**Put here if it applies to EVERY project you work on:**

#### Skills (Yes to all 5 current skills!)

```
~/.claude/skills/
├── tdd/                    ✅ TDD workflow is universal
├── code-review/            ✅ Code review checklist applies everywhere
├── security-audit/         ✅ OWASP Top 10 is universal
├── performance-check/      ✅ Big-O analysis is universal
└── plan-architecture/      ✅ SOLID principles are universal
```

**Why global?**
- Test-Driven Development works for Python, JavaScript, Go, Rust, etc.
- Security vulnerabilities are the same across projects
- Performance principles (Big-O) are language-agnostic
- Code review checklist applies to any codebase

#### CLAUDE.md (Personal Preferences)

```markdown
# ~/.claude/CLAUDE.md

# My Personal Coding Preferences
- I prefer verbose variable names over short ones
- I like seeing explicit error handling
- Explain your reasoning in comments when logic is complex

# My Development Environment
- I use vim keybindings
- My terminal is dark mode
- I prefer markdown tables over lists for comparisons

# My Communication Style
- Keep explanations concise (2-3 sentences max)
- Don't ask if I want to proceed, just do it
- Flag breaking changes explicitly

# Universal Principles I Follow
- Always use TDD for new features
- Security audit before any commit
- Performance check for data processing code
```

**Why global?**
- These are YOUR preferences across ALL projects

### Project-Specific (`<project>/.claude/`) - Tailored

**Put here if it ONLY applies to THIS specific project:**

#### CLAUDE.md (Project Conventions)

```markdown
# <project>/.claude/CLAUDE.md

# Project: E-commerce Backend API

## Tech Stack
- Language: Python 3.11
- Framework: FastAPI
- Database: PostgreSQL 14
- ORM: SQLAlchemy
- Cache: Redis
- Queue: Celery + RabbitMQ

## Build Commands
- Install: `poetry install`
- Run dev server: `poetry run uvicorn app.main:app --reload`
- Run tests: `poetry run pytest tests/ -v`
- Run linter: `poetry run ruff check .`
- Format: `poetry run black .`
- Type check: `poetry run mypy app/`

## Database
- Connection: Use `app/db/session.py` get_db()
- Migrations: `alembic revision --autogenerate -m "message"`
- Apply migrations: `alembic upgrade head`
- Never use raw SQL, always use SQLAlchemy ORM

## API Conventions
- URL format: `/api/v1/{resource}`
- Use plural resource names: `/users`, `/products`
- JSON format: camelCase for keys
- Always include pagination: `?page=1&limit=20`
- Error format: `{"error": {"code": "...", "message": "..."}}`

## Testing Standards
- Unit tests: `tests/unit/`
- Integration tests: `tests/integration/`
- Fixtures in: `tests/conftest.py`
- Coverage target: 90%+
- Run specific test: `pytest tests/unit/test_auth.py::test_login`

## Security
- All endpoints require JWT auth except: `/health`, `/docs`
- Rate limiting: 100 requests/minute per IP
- Input validation: Use Pydantic models
- Secrets: Load from `.env` (never commit)

## Git Workflow
- Branch naming: `feature/JIRA-123-description`
- PR requires: 2 approvals, passing CI, no conflicts
- Commit format: `feat(auth): add OAuth2 support`

## Architecture
- Layered architecture: Router → Service → Repository → Model
- Domain logic in Service layer
- Database access only in Repository layer
- DTOs for API requests/responses (in `app/schemas/`)

## Dependencies
- Add dependency: `poetry add package-name`
- Update lock file: `poetry lock`
- Critical packages: Keep pydantic, fastapi, sqlalchemy up to date
```

**Why project-specific?**
- Tech stack differs per project
- Build commands are unique to this codebase
- API conventions vary between teams/projects
- Database schema is project-specific

#### Skills (Project-Specific Workflows)

```
<project>/.claude/skills/
├── deploy-to-aws/
│   └── SKILL.md           # AWS-specific deployment
├── run-migration/
│   └── SKILL.md           # This project's migration process
├── seed-test-data/
│   └── SKILL.md           # This project's test fixtures
└── check-api-docs/
    └── SKILL.md           # Validate OpenAPI spec
```

**Example: Project-Specific Skill**

```markdown
# <project>/.claude/skills/deploy-to-aws/SKILL.md
---
name: deploy-to-aws
description: Deploy this e-commerce API to AWS ECS. Use when deploying to staging or production.
disable-model-invocation: true
allowed-tools: Bash(aws *), Bash(docker *), Bash(git push *)
---

# Deploy E-commerce API to AWS

## Prerequisites Check
1. Ensure AWS CLI is configured: `aws sts get-caller-identity`
2. Ensure Docker is running: `docker info`
3. Ensure on main branch: `git branch --show-current`

## Build & Push Docker Image
```bash
# Build
docker build -t ecommerce-api:latest .

# Tag for ECR
docker tag ecommerce-api:latest 123456789.dkr.ecr.us-east-1.amazonaws.com/ecommerce-api:latest

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789.dkr.ecr.us-east-1.amazonaws.com

# Push
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/ecommerce-api:latest
```

## Deploy to ECS
```bash
# Update ECS service (staging)
aws ecs update-service \
  --cluster ecommerce-staging \
  --service api-service \
  --force-new-deployment \
  --region us-east-1

# Wait for deployment
aws ecs wait services-stable \
  --cluster ecommerce-staging \
  --services api-service \
  --region us-east-1
```

## Verify Deployment
```bash
# Check health endpoint
curl https://staging-api.ecommerce.com/health

# Check version
curl https://staging-api.ecommerce.com/version
```

## Production (Requires Approval)
Ask user for explicit approval before deploying to production.

For production deployment:
- Use cluster: `ecommerce-production`
- URL: https://api.ecommerce.com
```

**Why project-specific skill?**
- AWS account IDs are project-specific
- ECR repository names are unique
- Deployment process differs per project

---

## 🔄 How to Migrate Current Setup

### Step 1: Move Generic Skills to Global

```bash
# Create global skills directory
mkdir -p ~/.claude/skills

# Move the 5 universal skills
mv /home/gyr/.gyr.d/gyr-data/work/tmp/claude_v2/skills/tdd ~/.claude/skills/
mv /home/gyr/.gyr.d/gyr-data/work/tmp/claude_v2/skills/code-review ~/.claude/skills/
mv /home/gyr/.gyr.d/gyr-data/work/tmp/claude_v2/skills/security-audit ~/.claude/skills/
mv /home/gyr/.gyr.d/gyr-data/work/tmp/claude_v2/skills/performance-check ~/.claude/skills/
mv /home/gyr/.gyr.d/gyr-data/work/tmp/claude_v2/skills/plan-architecture ~/.claude/skills/
```

### Step 2: Create Global CLAUDE.md

```bash
# Create global CLAUDE.md with YOUR personal preferences
touch ~/.claude/CLAUDE.md
```

```markdown
# ~/.claude/CLAUDE.md

# My Personal Preferences
- Always use TDD for new features (invoke /tdd)
- Run security audit before commits (invoke /security-audit)
- Check performance for loops/data processing (invoke /performance-check)

# My Communication Style
- Be concise (2-3 sentences per explanation)
- Show code examples, not just descriptions
- Explain WHY, not just WHAT

# My Development Setup
- Terminal: iTerm2 with dark mode
- Editor: Neovim
- Shell: zsh

# General Coding Standards I Follow
- Prefer explicit over implicit
- Composition over inheritance
- Readability over cleverness
- Tests before implementation
```

### Step 3: Split Current CLAUDE.md

The current `CLAUDE.md` in your project has both:
- Generic TDD principles (should be global)
- Project-specific (none yet, since this is a demo)

**Option A: Make it all global (since no project-specific rules yet)**

```bash
# Copy to global
cp /home/gyr/.gyr.d/gyr-data/work/tmp/claude_v2/CLAUDE.md ~/.claude/CLAUDE.md

# Then in project, create minimal project-specific one
```

```markdown
# <project>/.claude/CLAUDE.md

# This Project
This is a demo/learning project for Claude Code squad setup.

## Tech Stack
- Generic examples (Python, JavaScript)
- No specific framework

## Purpose
Learning and demonstration of Claude Code features.

See ~/.claude/CLAUDE.md for universal coding standards.
```

**Option B: Keep project-specific rules in project**

```markdown
# <project>/.claude/CLAUDE.md (project-specific)

# Project: Claude Code Squad Demo
- This is a learning/demo project
- Examples use Python and JavaScript
- Focus on teaching Claude Code features

# Specific to this demo:
- Keep examples simple and clear
- Explain each step
- Show before/after comparisons
```

```markdown
# ~/.claude/CLAUDE.md (global)

# My Universal Coding Standards
- TDD for all new features
- Security audit before commits
- Code review after major changes
- Performance check for data processing

[Rest of current CLAUDE.md content]
```

### Step 4: Verify Setup

```bash
# Start Claude Code in any directory
cd ~/any-project
claude

# Check what skills are available
/skills
# Should show: tdd, code-review, security-audit, performance-check, plan-architecture
# (From ~/.claude/skills/)

# Ask about rules
"What are my coding standards?"
# Should reference both ~/.claude/CLAUDE.md and ./.claude/CLAUDE.md (if exists)
```

---

## 📊 Decision Matrix: Global vs Project?

| Configuration | Global (~/.claude/) | Project (./.claude/) |
|:--------------|:-------------------|:---------------------|
| **TDD workflow** | ✅ YES | ❌ No (universal) |
| **Code review checklist** | ✅ YES | ❌ No (universal) |
| **Security OWASP checks** | ✅ YES | ❌ No (universal) |
| **Performance Big-O** | ✅ YES | ❌ No (universal) |
| **Architecture SOLID** | ✅ YES | ❌ No (universal) |
| **Your coding style** | ✅ YES | ❌ No (personal) |
| **Tech stack (Python/Go/JS)** | ❌ No | ✅ YES (varies) |
| **Build commands** | ❌ No | ✅ YES (project-specific) |
| **Test commands** | ❌ No | ✅ YES (project-specific) |
| **API conventions** | ❌ No | ✅ YES (team-specific) |
| **Database schema** | ❌ No | ✅ YES (project-specific) |
| **Deployment process** | ❌ No | ✅ YES (infra-specific) |
| **Git workflow** | ✅ Maybe | ✅ Maybe (team decides) |

**Rule of thumb:**
- **Global:** Works for ANY programming language, ANY project, ANY team
- **Project:** Specific to THIS codebase, THIS team, THIS infrastructure

---

## 🎯 Recommended Structure After Migration

### Your Global Setup (~/.claude/)

```
~/.claude/
├── CLAUDE.md                    # Your personal coding preferences
│                                # - TDD workflow preference
│                                # - Communication style
│                                # - Universal coding standards
│
├── skills/                      # Universal, reusable skills
│   ├── tdd/                     # ← Moved from project
│   ├── code-review/             # ← Moved from project
│   ├── security-audit/          # ← Moved from project
│   ├── performance-check/       # ← Moved from project
│   └── plan-architecture/       # ← Moved from project
│
└── settings.json (optional)     # Your personal settings
    # - Preferred permission mode
    # - Global hooks (e.g., always run linter)
    # - MCP servers you use everywhere
```

### Your Project Setup (<project>/.claude/)

```
<project>/.claude/
├── CLAUDE.md                    # THIS project's specifics
│                                # - Tech stack (FastAPI, Django, Express, etc.)
│                                # - Build commands
│                                # - Test commands
│                                # - API conventions
│                                # - Database details
│                                # - Team git workflow
│
├── skills/ (optional)           # Project-specific workflows
│   ├── deploy/                  # Deploy THIS project
│   ├── migrate/                 # THIS project's migrations
│   └── seed-data/               # THIS project's test data
│
└── settings.json (optional)     # Project-specific settings
    # - Allowed tools for this project
    # - Project-specific hooks
    # - MCP servers for this project only
```

---

## ✅ Benefits of This Approach

### 1. Reusability

**Before (all in project):**
```
Project A/.claude/skills/tdd/
Project B/.claude/skills/tdd/      # ← Duplicate!
Project C/.claude/skills/tdd/      # ← Duplicate!
```

**After (global):**
```
~/.claude/skills/tdd/              # ← Single source
[Available in ALL projects automatically]
```

### 2. Consistency

All your projects follow the same:
- TDD workflow
- Code review standards
- Security checklist
- Performance guidelines

While each project has its own:
- Tech stack
- Build process
- Deployment workflow

### 3. Easy Updates

Update TDD workflow once in `~/.claude/skills/tdd/`, affects all projects instantly.

### 4. Team Collaboration

**Your personal** `~/.claude/`:
- Not in git
- Your preferences
- Your personal skills

**Project** `.claude/`:
- In git (shared with team)
- Team conventions
- Project-specific workflows

### 5. Context Efficiency

Global skills don't duplicate across projects:
- Descriptions load once
- Full content loads on-demand
- No per-project maintenance

---

## 🔧 Migration Script (Optional)

Want to automate the migration? Here's a script:

```bash
#!/bin/bash
# migrate-to-global.sh

echo "Migrating Claude Code setup to global + project structure..."

# 1. Create global structure
mkdir -p ~/.claude/skills

# 2. Move universal skills to global
echo "Moving universal skills to ~/.claude/skills/..."
for skill in tdd code-review security-audit performance-check plan-architecture; do
  if [ -d "./skills/$skill" ]; then
    mv "./skills/$skill" ~/.claude/skills/
    echo "  ✓ Moved $skill to global"
  fi
done

# 3. Create global CLAUDE.md if doesn't exist
if [ ! -f ~/.claude/CLAUDE.md ]; then
  echo "Creating ~/.claude/CLAUDE.md..."
  cat > ~/.claude/CLAUDE.md << 'EOF'
# My Personal Coding Preferences

## Development Philosophy
- Always use TDD for new features
- Security audit before any commit
- Code review before major merges
- Performance check for data processing

## Communication Style
- Keep explanations concise
- Show code examples
- Explain WHY, not just WHAT

## Universal Standards
- Prefer explicit over implicit
- Composition over inheritance
- Readability over cleverness
EOF
  echo "  ✓ Created global CLAUDE.md"
fi

# 4. Create minimal project CLAUDE.md
echo "Creating minimal project CLAUDE.md..."
cat > ./CLAUDE.md << 'EOF'
# This Project

## Purpose
[Describe this specific project]

## Tech Stack
[List technologies used]

## Build Commands
[List build/test commands]

See ~/.claude/CLAUDE.md for universal coding standards.
EOF
echo "  ✓ Created project CLAUDE.md"

echo ""
echo "✅ Migration complete!"
echo ""
echo "Global setup: ~/.claude/"
echo "  - skills/ (5 universal skills)"
echo "  - CLAUDE.md (your preferences)"
echo ""
echo "Project setup: ./.claude/"
echo "  - CLAUDE.md (project-specific)"
echo "  - skills/ (project-specific, if any)"
echo ""
echo "Test it: Run 'claude' and check '/skills'"
```

---

## 📖 Official Documentation References

This approach follows official Anthropic guidelines:

- [Skills - Where skills live](https://code.claude.com/docs/en/skills#where-skills-live)
- [CLAUDE.md - Multiple locations](https://code.claude.com/docs/en/memory#write-an-effective-claude-md)
- [Settings - Configuration cascade](https://code.claude.com/docs/en/settings#settings-files)

---

## 🎯 Summary

**Your insight is correct!**

✅ **Global (`~/.claude/`)** = Universal squad setup
- TDD, code review, security, performance, architecture skills
- Your personal coding preferences
- Works across ALL projects

✅ **Project (`./.claude/`)** = Project-specific customization
- Tech stack details
- Build/test commands
- API conventions
- Deployment workflows
- Team git practices

This is the **official Anthropic recommended approach** and provides maximum reusability and consistency across your work!

---

**Ready to migrate?** Use the script above or do it manually. Either way, you'll have a professional, globally-available Claude Code squad! 🚀
