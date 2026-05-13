# Claude Code Usage Guide - Skills, Subagents, and Tools

**For developers transitioning from Claude Code chat to professional AI-assisted development**

This guide explains WHEN and HOW to use each Claude Code feature following official Anthropic guidelines.

## Table of Contents

1. [Quick Decision Tree](#quick-decision-tree)
2. [CLAUDE.md - Persistent Context](#claudemd---persistent-context)
3. [Skills - Reusable Procedures](#skills---reusable-procedures)
4. [Built-in Subagents](#built-in-subagents)
5. [Custom Subagents](#custom-subagents)
6. [Commands](#commands)
7. [Real-World Workflows](#real-world-workflows)
8. [Common Mistakes to Avoid](#common-mistakes-to-avoid)

---

## Quick Decision Tree

```
Do you need persistent rules that apply to EVERY session?
│
├─ YES → Use CLAUDE.md (code style, build commands, TDD rules)
│
└─ NO
   │
   Do you need a reusable procedure you'll use multiple times?
   │
   ├─ YES → Create a Skill (TDD workflow, code review checklist)
   │
   └─ NO
      │
      Will the task read MANY files and you only need a summary?
      │
      ├─ YES → Use a Subagent (research, exploration)
      │
      └─ NO
         │
         Is context getting messy between unrelated tasks?
         │
         ├─ YES → Use /clear
         │
         └─ NO → Just ask Claude in normal conversation!
```

---

## CLAUDE.md - Persistent Context

### What It Is
A markdown file that Claude reads **at the start of every session**. Think of it as "permanent instructions that never go away."

### When to Use
**Use CLAUDE.md for:**
- ✅ Code style standards (ES modules vs CommonJS, naming conventions)
- ✅ Build commands Claude can't guess (`npm run build:production`)
- ✅ Test commands and framework preferences
- ✅ Git workflow (branch naming, commit message format)
- ✅ Architecture principles for this project
- ✅ Security standards (no hardcoded secrets, input validation rules)
- ✅ Performance guidelines (target Big-O complexity)

**DON'T use CLAUDE.md for:**
- ❌ Information Claude can read from code
- ❌ Standard language conventions Claude already knows
- ❌ Detailed API documentation (link to docs instead)
- ❌ Long tutorials or explanations
- ❌ File-by-file descriptions of the codebase
- ❌ Information that changes frequently

### Example: Good vs Bad CLAUDE.md

**✅ GOOD (Concise, actionable):**
```markdown
# Code Style
- Use ES modules (import/export), not CommonJS (require)
- Destructure imports: import { foo } from 'bar'

# Testing
- Run single tests: pytest tests/test_file.py::test_name
- Never run full suite during development (too slow)
- Use pytest-mock, not unittest.mock

# Git Workflow
- Branch naming: feature/description, fix/description
- Commit format: type(scope): description
```

**❌ BAD (Too long, obvious info):**
```markdown
# Introduction
This is a Python project that uses the Flask framework for web development.
Flask is a micro web framework written in Python. It is classified as a 
microframework because it does not require particular tools or libraries...

# How to Write Good Code
Always write clean, maintainable code that follows best practices...

# File Structure
- src/main.py: This is the main entry point
- src/utils.py: This contains utility functions
- src/models.py: This contains database models
... (50 more lines of file descriptions)
```

### How to Use

**Create it:**
```bash
claude --init  # Guided creation
# OR
/init          # Inside Claude Code session
```

**Location:** `./CLAUDE.md` in your project root

**Test it:** Start a new session and ask: "What code style should I use?"

### Keep It Short

**Rule of thumb:** If CLAUDE.md is > 200 lines, Claude will ignore parts of it.

For each line, ask: **"Would removing this cause Claude to make mistakes?"**
- If YES → Keep it
- If NO → Delete it or move to a Skill

---

## Skills - Reusable Procedures

### What They Are
Self-contained workflows that Claude can invoke automatically or you can trigger manually with `/skill-name`.

Think of skills as **"cookbooks" or "checklists"** that load only when needed.

### When to Use

**Use Skills for:**
- ✅ Multi-step procedures you repeat (TDD workflow, deployment checklist)
- ✅ Domain knowledge (API conventions, security checklist)
- ✅ Reference material (coding patterns, best practices)
- ✅ Workflows with side effects you control (`/deploy`, `/commit`)

**DON'T use Skills for:**
- ❌ One-time tasks
- ❌ Information already in CLAUDE.md
- ❌ Simple one-liners

### Skills in This Project

We have 5 skills configured:

#### 1. `/tdd` - Test-Driven Development
**When to invoke:**
- Implementing new features
- Fixing bugs
- User says "write tests first" or "TDD"

**What it does:**
- Enforces Red-Green-Refactor cycle
- Writes failing test → minimal code → refactor
- Prevents code without tests

**Example:**
```
User: Add a validate_email function using TDD
Claude: [Automatically uses /tdd skill]
        Phase 1: RED - Writing failing test...
```

#### 2. `/code-review` - Code Quality Audit
**When to invoke:**
- After finishing a feature
- Before committing
- User says "review this" or "check my code"

**What it does:**
- Logic audit (off-by-one errors, edge cases)
- Readability check
- Security review
- Performance analysis
- Test quality check

**Example:**
```
/code-review

OR (automatic):
User: Review my authentication changes
Claude: [Automatically uses code-review skill]
```

#### 3. `/security-audit` - Vulnerability Scan
**When to invoke:**
- Before merging code
- Handling user input, auth, or sensitive data
- User says "security check" or "vulnerabilities"

**What it does:**
- OWASP Top 10 checks
- Scans for hardcoded secrets
- Checks for SQL injection, XSS, command injection
- Reviews crypto usage

**Example:**
```
/security-audit

# After changes:
git add src/auth/
/security-audit
```

#### 4. `/performance-check` - Performance Analysis
**When to invoke:**
- Code is slow
- Processing large datasets
- User mentions "performance" or "optimize"

**What it does:**
- Profiles code
- Analyzes Big-O complexity
- Identifies bottlenecks
- Suggests optimizations with evidence

**Example:**
```
The search is slow with 10k users
[Claude automatically uses performance-check]

OR manual:
/performance-check
```

#### 5. `/plan-architecture` - System Design
**When to invoke:**
- Planning new features
- Major refactors
- Need architecture blueprint

**What it does:**
- Applies SOLID principles
- Designs component structure
- Defines interfaces
- Creates implementation plan

**Example:**
```
/plan-architecture

# Then describe what to build:
I need to add OAuth login
```

### How Skills Save Context

**Without skills:**
```
Total context: 100KB (loaded at session start)
- TDD procedure: 15KB
- Code review checklist: 12KB  
- Security checklist: 18KB
- Performance guide: 15KB
- Architecture guide: 20KB
= 80KB always loaded, only 20KB for actual work
```

**With skills:**
```
Total context: 100KB
- Skill descriptions: 3KB
- Available for work: 97KB

When /tdd invoked:
- TDD skill content: 15KB loads
- Still have 82KB for work (vs 20KB before!)
```

### Creating Your Own Skills

**Structure:**
```
.claude/skills/
└── my-skill/
    └── SKILL.md
```

**SKILL.md format:**
```markdown
---
name: my-skill
description: What it does and when to use it. Include trigger phrases.
when_to_use: Additional context for Claude on when to invoke.
---

# Skill Content

Step-by-step instructions...
```

**Example - Deployment Skill:**
```markdown
---
name: deploy
description: Deploy application to production. Use when user requests deployment or says "ship it", "go live", "deploy to prod".
disable-model-invocation: true
allowed-tools: Bash(git push *), Bash(npm run deploy)
---

# Production Deployment Checklist

1. **Run full test suite:**
   ```bash
   pytest tests/
   ```

2. **Check for uncommitted changes:**
   ```bash
   git status
   ```

3. **Build for production:**
   ```bash
   npm run build:prod
   ```

4. **Deploy:**
   ```bash
   npm run deploy
   ```

5. **Verify deployment:**
   ```bash
   curl https://api.example.com/health
   ```

6. **Monitor for errors:**
   - Check logs for 5 minutes
   - Verify error rate < 0.1%
```

**Invoke it:**
```
/deploy
```

---

## Built-in Subagents

### What They Are
Specialized AI assistants that run in **separate context windows**. They do work, return a summary, and their full context **never enters your main conversation**.

Think of subagents as **"interns you delegate to"** - they handle messy research and give you clean reports.

### Why Use Them

**Problem: Context Rot**
```
You: Debug this auth bug
Claude: [Reads 50 files, runs 30 commands, fills 80% of context]
        I found the bug in line 234 of auth.py

Your context: Now 80% full of file reads you don't need
```

**Solution: Subagent**
```
You: Use a subagent to debug this auth bug
Claude: [Spawns subagent]
Subagent: [Reads 50 files, runs 30 commands in ITS OWN context]
          [Returns 3-paragraph summary]
Claude: [Only the summary enters main context - 0.5% used]
```

### Built-in Subagents

#### 1. **Explore** (Read-only, Fast)
- **Model:** Haiku (fast, cheap)
- **Tools:** Read-only (no Write, no Edit)
- **Use for:** Finding files, reading code, searching codebase

**Example:**
```
Use the Explore subagent to find where we handle OAuth tokens

OR (automatic):
Where do we validate user permissions?
[Claude automatically uses Explore if it needs to search many files]
```

#### 2. **Plan** (Used in Plan Mode)
- **Model:** Inherits from main session
- **Tools:** Read-only
- **Use for:** Research during plan mode

**Example:**
```
[In plan mode - Shift+Tab twice]
Research how we currently handle sessions, then design OAuth integration
[Claude uses Plan subagent automatically]
```

#### 3. **general-purpose** (Full Capabilities)
- **Model:** Inherits from main session
- **Tools:** All tools
- **Use for:** Complex multi-step tasks

**Example:**
```
Use a subagent to implement the password reset flow with tests
```

### When to Use Subagents

**Use subagents when:**
- ✅ Task will read MANY files (>10)
- ✅ You only need a summary, not full details
- ✅ Task is self-contained (doesn't need conversation history)
- ✅ You want to try something risky in isolation

**Don't use subagents when:**
- ❌ Task needs back-and-forth refinement
- ❌ Task builds on previous conversation
- ❌ Task is quick (<3 file reads)

### How to Invoke Subagents

**IMPORTANT:** Use natural language only. No `@` syntax, no `/` commands, no special flags.

**Method 1: Explicit (Recommended)**
```bash
# Specify which subagent type you want
"Use an Explore subagent to find all files that handle user sessions"
"Use a Plan subagent to design the OAuth integration architecture"
"Use a general-purpose subagent to experiment with refactoring auth"
```

**Method 2: Generic (Let Claude choose)**
```bash
# Just say "subagent" - Claude picks the right type
"Use a subagent to research the database schema"
"Use a subagent to find authentication logic"
```

**Method 3: Automatic (No subagent keyword)**
```bash
# If task requires extensive research, Claude may use subagent automatically
"Where is the authentication logic implemented?"
# Claude might use Explore subagent if it needs to search many files
```

**Complete invocation guide:** See **TOKEN_OPTIMIZATION_GUIDE.md** section "How to Invoke Each Subagent Type" for detailed examples and common mistakes

---

## Plan Mode vs Plan Subagent (Important Distinction!)

**Common confusion:** "Plan Mode" and "Plan Subagent" sound similar but are **completely different features**.

### What is Plan Mode?

**Plan Mode** is when your **main Claude session** enters planning mode before implementation.

**How to activate:**
- `Shift+Tab` twice (desktop app)
- OR: Claude may suggest EnterPlanMode for non-trivial tasks

**What happens:**
1. Your main session switches to "planning mode"
2. Claude explores codebase **in your main context**
3. Claude creates a plan file (e.g., `IMPLEMENTATION_PLAN.md`)
4. You review and can ask questions about the plan
5. You approve (or reject) via ExitPlanMode
6. Claude implements in the **same session**

**Context impact:** Medium-High (exploration happens in main context)

**Example flow:**
```bash
# You have a non-trivial task
You: "Add OAuth2 login integration"

# Enter plan mode (Shift+Tab twice)
[Plan Mode activated]

Claude: [Explores current auth implementation in main context]
        [Reads 15 files, analyzes architecture]
        [Creates IMPLEMENTATION_PLAN.md with 5 phases]
        "I've created a plan. Would you like to review before I implement?"

You: "Looks good, proceed with phase 1"

# Exit plan mode, continue in same session
Claude: [Exits plan mode]
        [Implements phase 1 using TDD skill]

# Context after: 55% (exploration + planning + implementation all in main)
```

---

### What is a Plan Subagent?

**Plan Subagent** is a **separate agent** that does planning in its own context window.

**How to activate:**
```bash
"Use a Plan subagent to design the OAuth2 login architecture"
```

**What happens:**
1. Claude spawns a **separate agent** (Plan subagent)
2. Subagent explores codebase **in its own context**
3. Subagent creates plan **in its own context**
4. Subagent returns **summary** to main context (~2-3k tokens)
5. Main context stays clean

**Context impact:** Low (only summary enters main context)

**Example flow:**
```bash
# You want planning but context is high
You: "Use a Plan subagent to design the OAuth2 login architecture"

# Plan subagent spawns in separate context
Claude: [Spawns Plan subagent]

Plan Subagent (in its own context):
  [Explores current auth implementation]
  [Reads 15 files, analyzes architecture]
  [Creates detailed plan with 5 phases]
  [Returns 2-page summary to main]

# Summary returned to main context
Claude: [Receives summary]
        "The Plan subagent recommends a 5-phase approach..."
        [Summary: ~2k tokens added to main context]

You: "Based on that plan, implement phase 1 using TDD"

Claude: [Implements in main context based on summary]

# Context after: 47% (only summary in main, not full exploration)
```

---

### Side-by-Side Comparison

| Feature | Plan Mode (Shift+Tab twice) | Plan Subagent ("Use a Plan subagent...") |
|---------|------------------------------|------------------------------------------|
| **What it is** | Main session enters planning mode | Separate agent in own context |
| **Activation** | `Shift+Tab` twice (desktop) OR EnterPlanMode | `"Use a Plan subagent to [task]"` |
| **Where planning happens** | Main context | Separate context window |
| **Context impact** | Medium-High (20-40k tokens) | Low (2-3k tokens summary only) |
| **File exploration** | In main context (bloats context) | In separate context (stays clean) |
| **Approval step** | Yes (ExitPlanMode to proceed) | No (just returns summary) |
| **Implementation** | Same session after approval | You implement based on summary |
| **Plan detail** | Full details in main context | Summary only in main |
| **Best when context is** | <50% (plenty of room) | >50% (need to stay clean) |
| **Best for** | Non-trivial tasks, want review | Heavy research, keep main clean |

---

### When to Use Each?

#### Use Plan Mode (Shift+Tab twice) when:

✅ **Task is non-trivial** (not obvious how to implement)
- Adding new feature with multiple approaches
- Refactoring that touches many files
- Architectural decision needed

✅ **Context is healthy** (<50%)
- Plenty of room for exploration
- Don't need to worry about context bloat

✅ **Want interactive review**
- Review plan before implementation
- Ask questions about the approach
- Modify plan before proceeding

✅ **Want seamless flow**
- Plan → Approve → Implement in same session
- No context switch

**Example:**
```bash
# Context at 30%, adding new feature
[Shift+Tab twice]
"Design and implement user role-based permissions system"
[Claude plans, you approve, Claude implements - all in one session]
```

---

#### Use Plan Subagent when:

✅ **Context is already high** (>50%)
- Need to keep main context clean
- Can't afford 20-40k token exploration in main

✅ **Planning requires heavy research**
- Will read 20+ files to understand current system
- Need to map complex architecture
- Research multiple subsystems

✅ **Just need the plan summary**
- Don't need every detail in main context
- Just need high-level approach to implement

✅ **Want to preserve main context**
- Currently mid-implementation of something else
- Don't want planning to bloat current work

**Example:**
```bash
# Context at 65%, need architecture plan
"Use a Plan subagent to design the user role-based permissions system"
[Subagent does heavy research in separate context]
[Returns summary: ~2k tokens]
[Main context: 65% → 67%]
"Based on that plan, implement the User role model using TDD"
```

---

### Common Scenarios

#### Scenario 1: Clean slate, moderate task
```bash
# Context: 25%
# Task: Add email notifications

✅ USE: Plan Mode (Shift+Tab twice)
WHY: Context is healthy, task is non-trivial, want seamless plan→implement flow

[Shift+Tab twice]
"Design email notification system"
[Plan created, you review, approve]
[Implement in same session]
[Final context: ~50%]
```

---

#### Scenario 2: High context, complex task
```bash
# Context: 70%
# Task: Redesign database schema

✅ USE: Plan Subagent
WHY: Context already high, redesign needs heavy research, need to keep main clean

"Use a Plan subagent to design the database schema redesign"
[Subagent explores in separate context]
[Returns summary: 2k tokens]
[Main context: 70% → 72%]
[Implement based on summary]
```

---

#### Scenario 3: Mid-implementation, new blocker
```bash
# Context: 55%
# Currently: Implementing feature A (15 turns in)
# Blocker: Need to understand auth system to proceed

✅ USE: Plan Subagent OR Explore Subagent
WHY: Don't want to bloat context with research while mid-implementation

"Use an Explore subagent to research how our auth system works"
[Subagent researches in separate context]
[Returns summary]
[Continue implementing feature A with clean context]
```

---

#### Scenario 4: Starting new project, architectural decisions needed
```bash
# Context: 10%
# Task: Design entire microservice architecture

✅ USE: Plan Mode (Shift+Tab twice)
WHY: Fresh context, need interactive design discussion, want to approve before implementing

[Shift+Tab twice]
"Design microservice architecture for payment processing"
[Claude explores, proposes architecture]
[You discuss trade-offs, adjust approach]
[Approve final design]
[Implement in same session]
```

---

### Quick Decision Tree

```
Need to plan implementation?
│
├─ Context < 50%?
│  ├─ Yes → Use Plan Mode (Shift+Tab twice)
│  │         Seamless plan→implement in same session
│  │
│  └─ No (context > 50%) → Use Plan Subagent
│                          "Use a Plan subagent to [task]"
│                          Keeps main context clean
│
└─ Just need research (not planning)?
   └─ Use Explore Subagent
      "Use an Explore subagent to [task]"
```

---

### Real-World Example: Both Used Together

```bash
# Session start
/context  # 5%

# Phase 1: Heavy architectural research (use Plan Subagent)
"Use a Plan subagent to research microservice patterns for payment processing"
[Subagent reads 40 files across 5 repos]
[Returns comprehensive architecture summary]
/context  # 8% (just summary)

# Phase 2: Design specific implementation (use Plan Mode)
[Shift+Tab twice]
"Based on that research, design our payment microservice implementation"
[Claude explores our specific codebase]
[Creates IMPLEMENTATION_PLAN.md with 8 phases]
[You review and approve]
/context  # 40% (plan + exploration)

# Phase 3: Implement
[Exits plan mode]
"Implement phase 1 using TDD"
[Implementation proceeds]
/context  # 60%

# Phase 4: Compact before continuing
/compact Preserve payment microservice architecture and implementation plan
/context  # 30%

# Continue implementing phases 2-8...
```

---

### Summary

**Two different features:**

1. **Plan Mode** = Main session planning (Shift+Tab twice)
   - Interactive plan creation
   - Approval step
   - Seamless implementation in same session
   - Use when context is healthy (<50%)

2. **Plan Subagent** = Separate agent planning ("Use a Plan subagent...")
   - Heavy research in separate context
   - Returns summary to main
   - Keeps main context clean
   - Use when context is high (>50%) or need heavy research

**Both are valuable** - choose based on context health and task complexity.

**See also:**
- **CONTEXT_MANAGEMENT_GUIDE.md** - When to worry about context
- **TOKEN_OPTIMIZATION_GUIDE.md** - Subagent invocation guide

---

## Custom Subagents

### When to Create One

**Only create custom subagents if:**
1. Built-in subagents don't fit your needs
2. You need specialized tool restrictions
3. You need domain-specific system prompts
4. You use it frequently (not a one-off)

**Most use cases are better served by Skills!**

### Example Use Cases

**Good custom subagent:**
```markdown
---
name: db-query-validator
description: Execute read-only database queries
tools: Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-readonly-query.sh"
---

You can execute SELECT queries but NOT INSERT, UPDATE, DELETE, or DROP.
```

**Bad custom subagent (use Skill instead):**
```markdown
---
name: code-reviewer
description: Review code for quality
---

Review code following these guidelines...
[This should be a Skill, not a subagent!]
```

---

## Commands

Essential Claude Code commands:

### Context Management
- `/context` - Check context usage
- `/clear` - Reset context between unrelated tasks
- `/compact` - Manually compact conversation
- `/compact <instructions>` - Compact and preserve specific things (freeform text)

### Session Management
- `/resume` - Resume previous session
- `/rewind` - Undo changes (Esc Esc)
- `/branch` - Fork current session

### Configuration
- `/init` - Create CLAUDE.md
- `/agents` - Manage subagents
- `/skills` - Browse skills
- `/permissions` - Configure permissions

### Quick Actions
- `/btw` - Quick question (answer not saved to context)
- `/plan` - Enter plan mode

---

## Real-World Workflows

### Workflow 1: Implement New Feature (TDD)

```
1. User: "Add email validation to the signup form using TDD"

2. Claude: [Automatically uses /tdd skill]
   Phase 1: RED - Writing failing test...
   
   def test_validate_email_accepts_valid_addresses():
       assert validate_email("user@example.com") == True
   
   Running test... ❌ FAIL (function doesn't exist)

3. Claude: Phase 2: GREEN - Minimal implementation...
   
   def validate_email(email):
       return "@" in email and "." in email
   
   Running test... ✅ PASS

4. Claude: Phase 3: REFACTOR - Improving with regex...
   
   import re
   EMAIL_REGEX = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
   
   def validate_email(email):
       return bool(EMAIL_REGEX.match(email))
   
   Running tests... ✅ All PASS

5. User: "Now use a subagent to review it for security"

6. Claude: [Spawns security-review subagent]
   [Subagent checks for regex vulnerabilities, edge cases]
   [Returns summary]
   
   Security review found 1 issue:
   - Missing input length check (ReDoS vulnerability)
   
   Fixed version:
   def validate_email(email):
       if len(email) > 320:  # RFC 5321 limit
           return False
       return bool(EMAIL_REGEX.match(email))
```

### Workflow 2: Fix Performance Bug

```
1. User: "The user search is slow with 10k users"

2. Claude: Let me profile this...
   [Uses /performance-check automatically]
   
   Running profiler...
   
   Found bottleneck: search_users() - 12.3 seconds (89% of runtime)
   Issue: O(n²) nested loop
   
   Current code:
   for user in users:
       for permission in permissions:
           if permission.user_id == user.id:
               user.permissions.append(permission)
   
   Optimization: Use dict for O(1) lookup
   
   Fixed code:
   perm_map = {p.user_id: p for p in permissions}
   for user in users:
       user.permissions = perm_map.get(user.id, [])
   
   New complexity: O(n)
   Expected speedup: 99% (12.3s → 0.15s)

3. Claude: Running tests to verify correctness... ✅ All pass
   
   Re-profiling...
   New time: 0.14 seconds (99.4% improvement)

4. User: /code-review

5. Claude: [Reviews performance fix]
   ✅ Tests pass
   ✅ Complexity improved O(n²) → O(n)
   ✅ No logic errors
   ✅ Handles edge case (missing permissions)
   
   Recommendation: APPROVE
```

### Workflow 3: Research & Plan Architecture

```
1. User: "I want to add OAuth login. Research how our current auth works first."

2. Claude: I'll use the Explore subagent to research...
   [Spawns Explore subagent]
   [Subagent reads 30 files in its own context]
   [Returns summary]
   
   Current auth system:
   - Email/password only
   - Sessions stored in Redis
   - JWT tokens (24h expiration)
   - Auth middleware in src/middleware/auth.py
   
   OAuth integration points:
   - Add OAuth provider config
   - Create callback handler
   - Modify session creation logic

3. User: "/plan-architecture for adding Google OAuth"

4. Claude: [Uses plan-architecture skill]
   
   Creating IMPLEMENTATION_PLAN.md...
   
   [Detailed plan with components, interfaces, test strategy]

5. User: [Reviews plan]
   "Looks good, implement it using TDD"

6. Claude: [Exits plan mode, uses /tdd skill]
   Starting implementation...
   
   Phase 1: RED - Writing test for OAuth callback...
```

### Workflow 4: Context Cleanup

```
1. [After 15 turns of debugging]
   User: "Actually, let's work on something else - add a logging system"

2. User: /context
   Output: 174k/200k tokens (87%)  ← THE OVERALL % (watch this)
                             ↑↑
   
   Breakdown (informational):
   - Messages: 117k tokens (59%)
   - Debug session history: 45%
   - File reads from debugging: 30%
   - Test outputs: 12%

3. User: /clear
   Context reset. Ready for new task.

4. User: "Add structured logging to the application"
   
5. Claude: [Fresh context, no debug history]
   I'll design a logging system...
```

**Note:** When you run `/context`, monitor the **overall percentage** (87% in example above), not the breakdown percentages.

---

## Common Mistakes to Avoid

### ❌ Mistake 1: Creating Agents Instead of Skills

**Wrong:**
```markdown
# agents/code-reviewer.md
---
name: code-reviewer
description: Reviews code
---
Review code for quality...
```

**Right:**
```markdown
# skills/code-review/SKILL.md
---
name: code-review
description: Reviews code for quality
---
Review code for quality...
```

**Why:** Skills load on-demand and stay in main context. Subagents are for isolation, not procedures.

### ❌ Mistake 2: Putting Everything in CLAUDE.md

**Wrong:**
```markdown
# CLAUDE.md (500 lines)
- Code style guidelines
- Every function explained
- Complete API documentation
- Deployment checklist
- Security checklist
- Performance optimization guide
...
```

**Right:**
```markdown
# CLAUDE.md (50 lines)
- Code style
- Build commands
- Testing commands

# Then separate Skills:
- skills/deploy/
- skills/security-audit/
- skills/performance-check/
```

**Why:** CLAUDE.md loaded every session. Long CLAUDE.md = Claude ignores parts of it.

### ❌ Mistake 3: Not Using /clear Between Tasks

**Wrong:**
```
[15 turns debugging auth bug]
User: "Okay, now let's add a search feature"
Claude: [Context 90% full, quality degrades]
```

**Right:**
```
[15 turns debugging auth bug]
User: /clear
User: "Now let's add a search feature"
Claude: [Fresh context, high quality]
```

**Why:** Unrelated context causes drift and hallucinations.

### ❌ Mistake 4: Not Using Subagents for Research

**Wrong:**
```
User: "Find all files that handle authentication"
Claude: [Reads 50 files, fills 70% of context]
        Found files: auth.py, login.py, session.py...
Your context: Now 70% full
```

**Right:**
```
User: "Use a subagent to find all files that handle authentication"
Claude: [Spawns Explore subagent]
Subagent: [Reads 50 files in own context, returns summary]
Your context: Only 2% used (just the summary)
```

**Why:** Research bloats context. Subagents keep main context clean.

### ❌ Mistake 5: Manual Invocation When Automatic Works

**Wrong:**
```
User: "/tdd implement email validation"
```

**Right:**
```
User: "Implement email validation using TDD"
[Claude automatically uses /tdd skill based on "TDD" trigger]
```

**Why:** Let Claude decide when to use skills. Only use manual `/skill` when automatic fails.

---

## Summary: What to Use When

| Situation | Use | Example |
|:----------|:----|:--------|
| **Permanent rules for all sessions** | CLAUDE.md | Code style, build commands |
| **Reusable multi-step procedure** | Skill | TDD workflow, deployment |
| **Research reading many files** | Subagent (Explore) | "Find all auth logic" |
| **Context is messy** | /clear | Between unrelated tasks |
| **Need to undo changes** | /rewind (Esc Esc) | Revert bad code |
| **Check context usage** | /context | See what's using space |
| **Manual compaction** | /compact | Preserve specific info |
| **Quick side question** | /btw | Doesn't enter context |

---

**Next:** Read `CONTEXT_MANAGEMENT_GUIDE.md` for detailed guidance on preventing context rot and maintaining quality in long sessions.
