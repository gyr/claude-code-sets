# Token Optimization Guide - Claude Code Best Practices

**Based on Official Anthropic Guidelines**

This guide provides practical strategies for reducing token usage in Claude Code while maintaining high-quality AI assistance. Token optimization and context management are closely related—the strategies that prevent context rot also reduce token costs.

---

## Table of Contents

1. [Understanding Token Costs](#understanding-token-costs)
2. [The Quality-Cost Balance](#the-quality-cost-balance)
3. [Strategy 1: Clear Between Tasks](#strategy-1-clear-between-tasks)
4. [Strategy 2: Compact at 60%](#strategy-2-compact-at-60)
5. [Strategy 3: Subagents for Research](#strategy-3-subagents-for-research)
6. [Strategy 4: Skills On-Demand](#strategy-4-skills-on-demand)
7. [Strategy 5: CLAUDE.md for Persistence](#strategy-5-claudemd-for-persistence)
8. [Strategy 6: Prompt Caching](#strategy-6-prompt-caching)
9. [Measuring Token Usage](#measuring-token-usage)
10. [Real-World Workflows](#real-world-workflows)
11. [Quick Reference](#quick-reference)

---

## Understanding Token Costs

### What Are Tokens?

- **Tokens** ≈ ~4 characters of text (varies by language)
- Example: "Hello, world!" ≈ 3-4 tokens
- Code is typically more token-dense than prose

### Claude Code Token Budget

```
Context Window: 200,000 tokens
├─ System prompt: ~6k tokens (3%)
├─ System tools: ~19k tokens (9%)
├─ Memory files: Variable (CLAUDE.md, etc.)
├─ Skills: ~600 tokens (descriptions only)
├─ Messages: Your conversation
└─ Autocompact buffer: 33k tokens (16.5%)
```

### Cost Model

**Anthropic API Pricing (as of 2026):**
- Input tokens: Cheaper (reading context)
- Output tokens: More expensive (generating responses)
- Cached tokens: ~90% discount on input

**Impact:**
- Lower context usage = fewer input tokens
- Clean context = better caching
- Focused prompts = shorter outputs

---

## The Quality-Cost Balance

### Official Anthropic Perspective

> **Primary Goal:** Maintain quality and performance  
> **Secondary Benefit:** Cost reduction follows naturally

**Why quality matters more:**
1. A cheaper, lower-quality response isn't valuable
2. Hallucinations waste time (and more tokens to fix)
3. Context rot leads to verbose, confused responses

**The good news:** Strategies that improve quality also reduce costs.

---

## Strategy 1: Clear Between Tasks

### How It Works

The `/clear` command resets conversation context, keeping only system configuration.

### Token Impact

| Metric | Before `/clear` | After `/clear` | Reduction |
|--------|-----------------|----------------|-----------|
| Total tokens | 158k (79%) | 40.8k (20%) | **117k (74%)** |
| Messages | 134k | 14k | **120k (90%)** |

*Actual data from your session earlier today*

### When to Use

```bash
# ✅ GOOD: Clear between unrelated tasks
"Implement user authentication"
[15 turns, context at 65%]
/clear
"Now fix the search performance bug"
[Fresh start, high quality responses]

# ❌ BAD: Continuing without clearing
"Implement user authentication"
[15 turns, context at 65%]
"Now fix the search performance bug"
[Context at 80%, responses slower and less accurate]
```

### Best Practice

**Clear when:**
- Switching to unrelated task
- Context reaches 60-70%
- Starting a new feature/bug fix
- After completing a major milestone

**Don't clear when:**
- Task is ongoing and context is relevant
- Context is still low (<40%)
- You need conversation history for next step

### Example Workflow

```bash
# Session 1: Feature A
claude
"Implement email validation using TDD"
[10 turns]
/context  # 45%
git commit -m "feat: add email validation"
/clear    # Reset before next feature

# Session 2: Feature B (fresh context)
"Implement password reset flow"
[Start from 5%, not 45%]
```

**Token savings:** ~90k per `/clear` (assuming 60-70% context)

---

## Strategy 2: Compact at 60%

### How It Works

The `/compact` command summarizes conversation history while preserving key information.

### Token Impact

| Context Level | Action | Typical Reduction |
|---------------|--------|-------------------|
| 60% (120k) | `/compact` | 50-70k (42-58%) |
| 80% (160k) | `/compact` | 80-100k (50-63%) |
| 90% (180k) | `/compact` | 100-120k (56-67%) |

**Why compact at 60%, not 90%:**
- At 60%: Claude has full access to all context = high-quality summary
- At 90%: Claude already working with degraded context = worse summary

### When to Use

```bash
# Monitor context every 10 turns
/context

# At 60%:
/compact Preserve architecture decisions and test commands

# Continue working with fresh context
```

### Example: Compact with Instructions

```bash
# Working on complex refactor
[20 turns discussing architecture]
/context  # 62%

# Compact with specific preservation
/compact Preserve:
- Decision to use PostgreSQL instead of MongoDB
- Database schema for users table
- Test commands: pytest tests/test_db.py
- Security requirement: hash passwords with bcrypt

# Continue working
"Based on those decisions, implement the user model"
```

**Token savings:** 50-100k depending on context level

### Automatic Compaction

Claude Code auto-compacts at 95%, but **don't wait for this**:
- Auto-compact works with degraded context
- Manual compact at 60% produces better summaries
- Better summaries = less information loss

---

## Strategy 3: Subagents for Research

### The Problem

Reading many files bloats your main context:

```bash
# WITHOUT subagent (❌ bloats main context)
"Find all files that handle authentication"
[Claude reads 50 files in main context]
[Each file: 2-5k tokens]
[Total added to context: 100-250k tokens]
/context  # 95%+ (overloaded!)
```

### The Solution

Subagents do research in their own context window:

```bash
# WITH subagent (✅ keeps main context clean)
"Use a subagent to find all files that handle authentication"
[Subagent reads 50 files in ITS OWN context]
[Returns 1-2 page summary to main context]
[Total added to main context: 2-3k tokens]
/context  # 23% (clean!)
```

### Token Impact

| Research Task | Direct Approach | Subagent Approach | Savings |
|---------------|-----------------|-------------------|---------|
| Read 50 files | +150k tokens | +2k tokens | **148k (99%)** |
| Search codebase | +100k tokens | +1.5k tokens | **98.5k (98%)** |
| Analyze architecture | +80k tokens | +2.5k tokens | **77.5k (97%)** |

### When to Use Subagents

**Use subagent when:**
- Reading >10 files
- Searching codebase broadly
- Researching unfamiliar code
- Exploring architecture
- You need summary, not all details

**Don't use subagent when:**
- Reading 1-3 specific files
- You need full context for implementation
- Task requires writing code (use main context)

### Example: Research Then Implement

```bash
# Phase 1: Research (use subagent)
"Use a subagent to find how we currently handle API rate limiting"
# Subagent result:
# - Found 3 files: middleware/rate_limit.py, config/limits.yaml, tests/test_rate_limit.py
# - Current approach: Token bucket algorithm
# - Limits: 100 req/min per user
# - Storage: Redis

/context  # 18% (just 2k tokens from summary)

# Phase 2: Implement (in main context)
"Based on that research, add rate limiting to the new GraphQL API"
[Implementation proceeds with clean context]
```

**Token savings:** 95-99% on research phase

### The Explore Subagent (Primary Research Tool)

The **Explore** subagent is Claude Code's specialized research agent, optimized for fast, cost-effective codebase exploration.

#### Characteristics

| Feature | Explore | general-purpose | Direct (no subagent) |
|---------|---------|-----------------|----------------------|
| **Model** | Haiku (fast, cheap) | Sonnet (same as main) | Sonnet |
| **Mode** | Read-only | Full capabilities | Full capabilities |
| **Speed** | ⚡ Fastest | 🔵 Normal | 🔵 Normal |
| **Cost** | 💰 Cheapest | 💰💰 Standard | 💰💰 Standard |
| **Context** | Separate (doesn't bloat main) | Separate | **Main (bloats!)** |
| **Can write code** | ❌ No | ✅ Yes | ✅ Yes |
| **Can edit files** | ❌ No | ✅ Yes | ✅ Yes |
| **Best for** | Finding/reading files | Isolated experiments | Implementation |

**Key insight:** Explore is optimized for the research phase—it's faster and cheaper because it can't write code.

#### How to Invoke Subagents (Important!)

**No special syntax needed** - you use natural language to request subagent type.

❌ **NOT like this:**
```bash
@explore find all auth files        # No @ syntax exists
/explore search for migrations      # No /explore command
--explore map architecture          # No flags
```

✅ **YES, like this:**

**Method 1: Explicit request (recommended for learning)**

```bash
# Be explicit about which subagent type you want
"Use an Explore subagent to find all database migration files"
"Spawn an Explore subagent to search for authentication-related code"
"Launch an Explore subagent to locate all API endpoint definitions"

# For general-purpose subagent (when you need write access)
"Use a general-purpose subagent to experiment with refactoring auth"
"Spawn a general-purpose subagent to try implementing feature X"
"Launch a general-purpose subagent to test a different approach"
```

**Why explicit is better for learning:**
- You control exactly which subagent type is used
- You learn when to use Explore vs general-purpose
- No ambiguity about what will happen

---

**Method 2: Generic request (let Claude choose)**

```bash
# Just say "subagent" - Claude selects the right type
"Use a subagent to find all files that import the User model"
# ↑ Claude auto-selects Explore (read-only research task)

"Use a subagent to refactor the auth module"
# ↑ Claude auto-selects general-purpose (needs write access)

"Use a subagent to search for all HTTP calls"
# ↑ Claude auto-selects Explore (read-only search)
```

**How Claude chooses:**
- If task is **read-only** (find, search, map, locate) → Explore
- If task needs **write access** (implement, refactor, edit) → general-purpose
- If task is **planning** (design, plan, architecture) → Plan

**Best practice for learning:** Use **Method 1 (explicit)** until you understand when each type is appropriate, then switch to **Method 2 (generic)** for convenience.

---

**Comparison Table:**

| Your Request | Subagent Selected | Why |
|--------------|-------------------|-----|
| "Use an **Explore** subagent to find auth files" | Explore | Explicit request |
| "Use a **general-purpose** subagent to refactor" | general-purpose | Explicit request |
| "Use **a subagent** to find auth files" | Explore | Read-only task |
| "Use **a subagent** to refactor auth" | general-purpose | Needs write access |
| "Find all auth files" (no subagent mention) | None (main context) | No subagent requested |

#### Common Research Patterns

**Pattern 1: Find Files by Purpose**

```bash
# Task: Locate all files related to user authentication
"Use an Explore subagent to find all files related to user authentication"

# Explore subagent process:
# 1. Searches for keywords: auth, login, session, user, password
# 2. Reads matching files
# 3. Categorizes by purpose (middleware, models, tests, config)
# 4. Returns structured summary

# Summary returned to main context (~2k tokens):
# Authentication Files Found:
# 
# Core:
# - src/auth/middleware.py (JWT validation)
# - src/auth/models.py (User, Session models)
# - src/auth/handlers.py (login, logout, refresh)
# 
# Configuration:
# - config/auth.yaml (JWT secret, expiry settings)
# 
# Tests:
# - tests/auth/test_login.py (login flow)
# - tests/auth/test_session.py (session management)
# 
# Current approach: JWT with Redis session store

/context  # Main context: 12% (+2k tokens from summary)
```

**Without Explore subagent:**
```bash
# Same task, no subagent
"Find all files related to user authentication"

# Claude reads all files in MAIN context:
# - 15 files × 3k tokens avg = 45k tokens added to main context

/context  # Main context: 67% (45k tokens added!)
```

**Token savings:** 43k tokens (96% reduction)

---

**Pattern 2: Understand Code Architecture**

```bash
# Task: Understand how the payment processing system works
"Use an Explore subagent to map out the payment processing architecture"

# Explore subagent process:
# 1. Finds payment-related files
# 2. Reads and analyzes data flow
# 3. Identifies dependencies
# 4. Creates architecture summary

# Summary returned (~3k tokens):
# Payment Processing Architecture:
# 
# Entry Point:
# - api/payments/routes.py → PaymentController.process()
# 
# Processing Pipeline:
# 1. Validation: services/payment_validator.py
# 2. External API: integrations/stripe_client.py
# 3. Database: repositories/payment_repo.py
# 4. Notifications: services/email_notifier.py
# 
# Data Flow:
# Request → Validator → Stripe → DB → Email
# 
# Key Classes:
# - Payment (model)
# - StripeClient (API wrapper)
# - PaymentRepository (data access)
# 
# External Dependencies:
# - Stripe API v2
# - PostgreSQL (payments table)
# - SendGrid (email)

/context  # 15% (+3k from summary)
```

**Without Explore:** 50-80k tokens added by reading 20-30 files

**Token savings:** 47-77k tokens (94-96% reduction)

---

**Pattern 3: Search for Specific Code Patterns**

```bash
# Task: Find all places where we make HTTP requests
"Use an Explore subagent to find all HTTP request calls in the codebase"

# Explore searches for patterns:
# - requests.get/post/put/delete
# - httpx.Client
# - urllib.request
# - aiohttp calls

# Summary returned (~2k tokens):
# HTTP Requests Found (23 locations):
# 
# External APIs (12):
# - integrations/stripe_client.py: 5 calls (payment processing)
# - integrations/sendgrid.py: 3 calls (email)
# - services/geocoding.py: 4 calls (address validation)
# 
# Internal Services (8):
# - services/user_service.py: 3 calls (auth microservice)
# - services/inventory.py: 5 calls (inventory microservice)
# 
# Tests (3):
# - tests/integration/test_api.py (testing HTTP endpoints)
# 
# All using: requests library
# Concerns: No timeout set on 8 calls (potential hang risk)

/context  # 10% (+2k from summary)
```

**Token savings:** Grep + read 23 files would be ~70k tokens → saved 68k (97% reduction)

---

**Pattern 4: Trace Dependencies**

```bash
# Task: Find what code depends on the User model
"Use an Explore subagent to find all files that import or use the User model"

# Explore process:
# 1. grep for "from .models import User"
# 2. grep for "User(" instantiations
# 3. Read files to understand usage
# 4. Categorize by type of dependency

# Summary (~2k tokens):
# User Model Dependencies (18 files):
# 
# Direct Imports (12):
# - auth/handlers.py (login/logout)
# - admin/user_management.py (CRUD operations)
# - api/users/routes.py (REST API)
# - services/notification.py (user lookups)
# [8 more files listed...]
# 
# Usage Patterns:
# - Authentication: 5 files
# - Admin operations: 3 files
# - API endpoints: 4 files
# - Background jobs: 6 files
# 
# Impact Analysis:
# If User model changes, these areas affected:
# - Auth flow (high risk)
# - Admin panel (medium risk)
# - API responses (medium risk - may break clients)

/context  # 13% (+2k from summary)
```

**Without Explore:** Reading 18 files = ~54k tokens

**Token savings:** 52k tokens (96% reduction)

---

**Pattern 5: Security Audit Research**

```bash
# Task: Find all places handling passwords
"Use an Explore subagent to find all code that handles passwords or authentication credentials"

# Explore searches for:
# - "password" in variable names
# - Hashing functions (bcrypt, hashlib)
# - Environment variables for secrets
# - Database columns storing credentials

# Summary (~2.5k tokens):
# Password/Credential Handling (9 locations):
# 
# ✅ SECURE:
# - auth/handlers.py: bcrypt hashing (line 45)
# - auth/models.py: password field (hashed, not stored plain)
# - tests/auth/test_login.py: test fixtures (mock data)
# 
# ⚠️ REVIEW NEEDED:
# - scripts/reset_password.py: generates temp passwords
#   → Uses weak random (random.choice, not secrets module)
# 
# - config/database.yaml: DB password in file
#   → Should use environment variable
# 
# - logs/app.log: Found "password" in logs (line 1234)
#   → Potential password leak in logs
# 
# Recommendations:
# 1. Fix temp password generation (use secrets module)
# 2. Move DB password to .env
# 3. Audit logging to ensure no credential leaks

/context  # 14% (+2.5k from summary)
```

**Value:** Explores entire codebase for security issues without bloating context

**Token savings:** Security scan of 30+ files would be 90k+ tokens → saved 87.5k (97%)

---

#### Explore vs general-purpose Subagent

**Use Explore when:**
- ✅ Finding files (by name, content, purpose)
- ✅ Reading and summarizing code
- ✅ Mapping architecture
- ✅ Searching for patterns
- ✅ Understanding dependencies
- ✅ Security/quality audits (read-only)
- ✅ You want **speed** and **low cost**

**Use general-purpose when:**
- ✅ Subagent needs to write code
- ✅ Subagent needs to edit files
- ✅ Experimenting with implementation approaches
- ✅ Isolated refactoring experiment
- ✅ Task requires full Claude capabilities

**Example decision:**

```bash
# ✅ Use Explore
"Find all database query files"  # Read-only research
"Map the API route structure"     # Read-only analysis
"Search for TODO comments"        # Read-only search

# ✅ Use general-purpose
"Experiment with refactoring the auth module"  # Needs write access
"Try implementing feature X in a subagent"     # Needs write access
"Create a proof-of-concept in isolation"       # Needs write access
```

#### Token Cost Comparison

**Scenario:** Research 40 files (2k tokens each = 80k total)

| Approach | Input Tokens | Model | Cost Factor | Context Impact |
|----------|--------------|-------|-------------|----------------|
| **Direct (main context)** | 80k | Sonnet | 1.0× | Main context +80k |
| **general-purpose subagent** | 80k | Sonnet | 1.0× | Main context +2k (summary) |
| **Explore subagent** | 80k | Haiku | **~0.15×** | Main context +2k (summary) |

**Token savings vs direct:** 78k tokens (98%)
**Cost savings vs direct:** ~85% (Haiku is ~15% the cost of Sonnet)
**Cost savings vs general-purpose:** ~85% (same context savings, but cheaper model)

**Best practice:** Always use Explore for read-only research—it's faster, cheaper, and keeps main context clean.

#### Real-World Explore Workflow

```bash
# Starting new feature: Add OAuth2 login
claude
/context  # 5%

# Step 1: Research current auth system (Explore)
"Use an Explore subagent to research our current authentication implementation"
# [Explore reads 15 files in its own context]
# [Returns summary: "Currently using JWT with bcrypt..."]
/context  # 8% (+2k from summary)

# Step 2: Find similar patterns in codebase (Explore)
"Use an Explore subagent to find any existing OAuth or third-party auth code"
# [Explore searches codebase]
# [Returns: "No OAuth found, but social login stub in..."]
/context  # 11% (+2k from summary)

# Step 3: Plan architecture (in main context, informed by research)
/plan-architecture
"Design OAuth2 login integration based on the existing JWT system"
# [Creates IMPLEMENTATION_PLAN.md]
/context  # 28%

# Step 4: Implement (in main context with TDD)
"Implement phase 1 of OAuth2 using TDD"
# [10 turns of TDD implementation]
/context  # 55%

# Step 5: Code review
/code-review
/context  # 68%

# Step 6: Compact before continuing
/compact Preserve OAuth2 design decisions and implementation notes
/context  # 32%

# Total research: 30 files read (by Explore)
# Main context impact from research: 4k tokens (summaries only)
# Without Explore: Would have added 90k tokens → blown past 200k limit
# Result: Feature implementation ONLY POSSIBLE with Explore subagent
```

---

### Built-in Subagents Summary

Claude Code provides three built-in subagent types for code development:

| Subagent | Model | Access | Best For | Detailed Coverage |
|----------|-------|--------|----------|-------------------|
| **Explore** | Haiku | Read-only | Research, finding files, mapping architecture | ⬆️ Above |
| **Plan** | Sonnet | Read-only + Plan mode | Architecture planning, design docs | USAGE_GUIDE.md |
| **general-purpose** | Sonnet | Full (read + write) | Isolated experiments, parallel work | USAGE_GUIDE.md |

**Primary research tool:** Use **Explore** for 95% of research tasks—it's optimized for this.

**See also:** **USAGE_GUIDE.md** section "Built-in Subagents" for comprehensive guide on all three types

---

### How to Invoke Each Subagent Type (Complete Guide)

**IMPORTANT:** There is **NO special syntax** for subagents. No `@`, no `/`, no flags. Just natural language.

#### Method 1: Explicit Invocation (Recommended for Beginners)

Explicitly name the subagent type in your prompt:

##### Explore Subagent (Read-only, Haiku, Fast & Cheap)

```bash
# Pattern: "Use/Spawn/Launch an Explore subagent to [task]"

✅ CORRECT:
"Use an Explore subagent to find all authentication files"
"Spawn an Explore subagent to search for database queries"
"Launch an Explore subagent to map the payment processing architecture"
"Run an Explore subagent to locate all TODO comments"
"Create an Explore subagent to find files importing the User model"

❌ INCORRECT:
"@explore find auth files"           # No @ syntax
"/explore find auth files"           # No / command
"explore: find auth files"           # No : syntax
"--explore find auth files"          # No flags
```

**Trigger words for Explore:** find, search, locate, map, trace, audit (read-only tasks)

---

##### Plan Subagent (Architecture Planning, Sonnet)

```bash
# Pattern: "Use/Spawn/Launch a Plan subagent to [task]"

✅ CORRECT:
"Use a Plan subagent to design the OAuth2 integration architecture"
"Spawn a Plan subagent to create an implementation plan for the API redesign"
"Launch a Plan subagent to plan the database migration strategy"
"Run a Plan subagent to design the caching layer architecture"

❌ INCORRECT:
"@plan design OAuth2"                # No @ syntax
"/plan design OAuth2"                # No / command (note: /plan-architecture is a SKILL, not subagent)
"plan: design OAuth2"                # No : syntax
```

**Trigger words for Plan:** design, plan, architecture, strategy, approach

**IMPORTANT:** Don't confuse "Plan Subagent" with "Plan Mode"!
- **Plan Subagent** (this): Separate agent, planning in separate context, returns summary
- **Plan Mode** (`Shift+Tab` twice): Main session enters planning mode, exploration in main context

**When to use which:**
- Context <50% → Use Plan Mode (Shift+Tab twice) - seamless plan→implement
- Context >50% → Use Plan Subagent - keeps main context clean

**See:** USAGE_GUIDE.md section "Plan Mode vs Plan Subagent" for detailed comparison with examples.

**Also note:** There's a `/plan-architecture` **skill** (different from both above):
- **Skill** (`/plan-architecture`): Loads planning instructions into main context
- **Plan Subagent**: Planning in separate context, returns summary
- **Plan Mode**: Interactive planning in main session with approval step

---

##### general-purpose Subagent (Full Access, Sonnet)

```bash
# Pattern: "Use/Spawn/Launch a general-purpose subagent to [task]"

✅ CORRECT:
"Use a general-purpose subagent to experiment with refactoring the auth module"
"Spawn a general-purpose subagent to try implementing feature X with approach Y"
"Launch a general-purpose subagent to test a different database schema design"
"Run a general-purpose subagent to prototype the API endpoint"
"Create a general-purpose subagent to explore alternative implementations"

❌ INCORRECT:
"@general refactor auth"             # No @ syntax
"/general refactor auth"             # No / command
"general-purpose: refactor"          # No : syntax
```

**Trigger words for general-purpose:** experiment, try, test, prototype, refactor (when isolated), implement (when isolated)

---

#### Method 2: Generic Invocation (Let Claude Choose)

Use generic "subagent" and Claude selects the appropriate type:

```bash
# Generic pattern: "Use a subagent to [task]"

✅ Examples where Claude auto-selects:

"Use a subagent to find all authentication files"
→ Claude chooses: Explore (read-only research)

"Use a subagent to design the OAuth2 integration"
→ Claude chooses: Plan (architecture planning)

"Use a subagent to experiment with refactoring auth"
→ Claude chooses: general-purpose (needs write access)

"Use a subagent to search for database queries"
→ Claude chooses: Explore (read-only search)

"Use a subagent to prototype a new API design"
→ Claude chooses: general-purpose (needs implementation)
```

**How Claude chooses:**

| Task Type | Keywords | Subagent Selected | Reason |
|-----------|----------|-------------------|--------|
| **Research** | find, search, locate, map, trace, audit | Explore | Read-only, fast, cheap |
| **Planning** | design, plan, architecture, strategy | Plan | Planning mode |
| **Implementation** | experiment, refactor, implement, prototype, try | general-purpose | Needs write access |

---

#### Method 3: No Subagent (Direct in Main Context)

If you **don't mention "subagent"**, Claude works in your main context:

```bash
# NO "subagent" keyword = works in main context

❌ "Find all authentication files"
→ Claude reads files directly in MAIN context (bloats context!)

✅ "Use an Explore subagent to find all authentication files"
→ Claude spawns Explore subagent (keeps main context clean)
```

**Critical:** If you want a subagent, you MUST say "subagent" in your prompt.

---

#### Comparison: All Three Methods

**Scenario:** You want to find all files handling user authentication.

| Method | Your Prompt | What Happens | When to Use |
|--------|-------------|--------------|-------------|
| **Explicit (Explore)** | "Use an Explore subagent to find auth files" | Spawns Explore, you control the type | Learning, when you know which type |
| **Generic** | "Use a subagent to find auth files" | Claude chooses Explore (read-only) | Convenience, trust Claude |
| **No subagent** | "Find auth files" | Reads in main context (bloats!) | Never for >10 files |

---

#### Advanced: Custom Subagents (Not Built-in)

**Can you create custom subagent types?** No, not directly. You can only use the three built-in types:
1. Explore
2. Plan  
3. general-purpose

**However**, you can configure general-purpose subagents with restrictions via the Agent tool, but this is advanced usage and rarely needed.

**For 95% of use cases:** Stick with the three built-in types.

---

#### Complete Invocation Examples

**Use Case 1: Research codebase**
```bash
# Explicit (recommended)
"Use an Explore subagent to find all files that handle user authentication"

# Generic (Claude chooses Explore)
"Use a subagent to find all files that handle user authentication"

# Alternative phrasing (all work)
"Spawn an Explore subagent to locate authentication-related code"
"Launch an Explore subagent to search for auth files"
"Run an Explore subagent to map the auth architecture"
```

---

**Use Case 2: Plan architecture**
```bash
# Explicit (recommended)
"Use a Plan subagent to design the OAuth2 integration architecture"

# Generic (Claude chooses Plan)
"Use a subagent to design the OAuth2 integration architecture"

# Alternative phrasing
"Spawn a Plan subagent to create an implementation plan for OAuth2"
"Launch a Plan subagent to plan the authentication refactor"
```

---

**Use Case 3: Isolated experiment**
```bash
# Explicit (recommended)
"Use a general-purpose subagent to experiment with refactoring the auth module"

# Generic (Claude chooses general-purpose)
"Use a subagent to experiment with refactoring the auth module"

# Alternative phrasing
"Spawn a general-purpose subagent to try implementing feature X"
"Launch a general-purpose subagent to prototype the new API design"
"Run a general-purpose subagent to test a different approach"
```

---

**Use Case 4: Parallel work**
```bash
# Multiple subagents at once
"Use an Explore subagent to research current auth implementation, and use another Explore subagent to find all API endpoints"

# Claude will spawn two Explore subagents in parallel
# Both return summaries to main context
```

---

#### Common Mistakes

| ❌ Mistake | ✅ Correct | Why |
|-----------|----------|-----|
| `@explore find files` | `"Use an Explore subagent to find files"` | No @ syntax |
| `/explore find files` | `"Use an Explore subagent to find files"` | No /explore command |
| `"Find files"` (expecting subagent) | `"Use a subagent to find files"` | Must say "subagent" |
| `"Use subagent find files"` | `"Use a subagent to find files"` | Need "a" or "an" |
| `"Explore: find files"` | `"Use an Explore subagent to find files"` | No : syntax |

---

#### Quick Reference: Subagent Invocation

**Template:**
```
"Use [a/an] [type] subagent to [task]"

[type] = Explore | Plan | general-purpose | (blank for auto-select)
```

**Examples:**
```bash
"Use an Explore subagent to [research task]"
"Use a Plan subagent to [design task]"
"Use a general-purpose subagent to [implementation task]"
"Use a subagent to [task]"  # Auto-select
```

**Remember:** Natural language only. No special syntax.

---

## Strategy 4: Skills On-Demand

### How It Works

Skills load in two phases:
1. **Always loaded:** Short descriptions (~600 tokens total)
2. **Loaded on invocation:** Full content (~15k tokens per skill)

### Token Impact

```
Without skills:
├─ Instructions repeated in chat: ~10-20k tokens per session
└─ Inconsistent application: requires correction cycles

With skills:
├─ Descriptions always loaded: 600 tokens
├─ Full skill when needed: +15k tokens
└─ Consistent application: no correction needed
```

### Example: TDD Skill

**Without `/tdd` skill:**
```bash
"Implement email validation using TDD"
Claude: "I'll write the implementation"
You: "No, write the TEST first"
Claude: "Oh right, here's a test... [implements]"
You: "The test should FAIL first"
Claude: "Let me fix that..."
[10+ turns to get TDD right]
[~30k tokens wasted on corrections]
```

**With `/tdd` skill:**
```bash
"Implement email validation using TDD"
# Claude auto-invokes /tdd skill (+15k tokens)
# Follows RED-GREEN-REFACTOR perfectly first time
# No corrections needed
[Effective cost: 15k tokens]
[Savings: 15k tokens + time + frustration]
```

### Token Optimization Strategy

**Put in skills:**
- Workflows you repeat (TDD, code review, deployment)
- Complex procedures with many steps
- Quality standards that need consistency

**Keep in chat:**
- One-off requests
- Simple tasks
- Context-specific instructions

**Put in CLAUDE.md:**
- Rules that apply to ALL work in this project
- Never needs to be loaded on-demand

See **USAGE_GUIDE.md** for detailed guidance on when to use each.

---

## Strategy 5: CLAUDE.md for Persistence

### The Problem

Repeating instructions every session:

```bash
# Session 1
"Use pytest for tests, black for formatting, flake8 for linting"
[+2k tokens]

# Session 2 (new conversation)
"Use pytest for tests, black for formatting, flake8 for linting"
[+2k tokens again]

# Over 10 sessions: 20k tokens wasted
```

### The Solution

Put persistent rules in CLAUDE.md (loaded automatically every session):

```markdown
# CLAUDE.md
## Build & Development Commands

```bash
# Run tests
pytest

# Format code
black src/ tests/

# Run linter
flake8 src/ tests/
```
```

### Token Impact

| Approach | Per Session | 10 Sessions | 100 Sessions |
|----------|-------------|-------------|--------------|
| Repeat in chat | 2k tokens | 20k tokens | 200k tokens |
| In CLAUDE.md | 1.3k tokens | 1.3k tokens | 1.3k tokens |
| **Savings** | 0.7k | 18.7k | **198.7k** |

### What to Put in CLAUDE.md

**✅ Include:**
- Code style standards
- Build/test/deploy commands
- Architecture principles
- Security requirements
- Git workflow
- Tech stack choices

**❌ Don't include:**
- Task-specific instructions
- Temporary decisions
- Current work-in-progress
- Information that changes frequently

**See:** Your current `CLAUDE.md` is a great example, and **USAGE_GUIDE.md** section "CLAUDE.md" for detailed guidance.

---

## Strategy 6: Prompt Caching

### How Anthropic Prompt Caching Works

**Official behavior:**
- System prompts cached for **5 minutes**
- Subsequent requests use cached version
- **~90% discount** on cached input tokens
- Only new messages charged at full rate

### Token Impact Example

```
Request 1 (cache miss):
├─ System: 25k tokens @ full price
├─ Messages: 15k tokens @ full price
└─ Total: 40k tokens

Request 2 (within 5 min, cache hit):
├─ System: 25k tokens @ ~10% price (cached!)
├─ Messages: 15k tokens @ full price
└─ Effective cost: ~17.5k tokens (56% savings)
```

### Optimization Strategies

#### Strategy A: Keep Context Stable

**Problem:**
```bash
[Every turn adds new context]
[System prompt constantly changing]
[Cache keeps missing]
```

**Solution:**
```bash
# Use CLAUDE.md for stable rules (always same)
# Use /clear to reset to stable state
# Use /compact to create new stable checkpoint
```

#### Strategy B: Work in Focused Bursts

```bash
# ✅ GOOD: Focused 30-min session
[10 rapid turns within 5 minutes]
[Turns 2-10 use cached system prompt]
[Effective: 9 cache hits]

# ❌ BAD: Scattered work
[1 turn, wait 10 minutes, another turn]
[Each turn is cache miss]
[Effective: 0 cache hits]
```

#### Strategy C: Compact Creates New Cache Point

```bash
[Working for a while, context at 70%]
/compact
[New stable context created]
[Next 5 minutes of work uses this cached]
```

### Token Impact

| Session Pattern | Cache Hits | Token Savings |
|-----------------|------------|---------------|
| Focused 10-turn session | 8-9 hits | **~180k tokens** |
| Scattered work (6+ min gaps) | 0 hits | 0 savings |
| After `/compact` work burst | 5-8 hits | **~125k tokens** |

**Best practice:** Work in focused sessions, not scattered across hours.

---

## Measuring Token Usage

### Using `/context` Command

```bash
/context
```

**Output:**
```
40.8k/200k tokens (20%)  ← WATCH THIS NUMBER
                  ↑↑
```

**What to monitor:**
- **Overall percentage (20%)** - This is what matters
- Ignore breakdown percentages (they're just informational)

**Color guide:**
- 🟢 **0-50%:** Optimal (high quality, low cost)
- 🟡 **50-75%:** Good (monitor, consider compact)
- 🟠 **75-90%:** Warning (compact recommended)
- 🔴 **90-100%:** Critical (clear or compact immediately)

See **CONTEXT_MANAGEMENT_GUIDE.md** section "⚠️ Which Percentage Should You Monitor?" for details.

### Tracking Token Usage Over Time

```bash
# At key points in your session
/context  # Start: 5%
[Work on feature]
/context  # Middle: 45%
[Continue]
/context  # Before decision: 62%
/compact  # Optimize
/context  # After compact: 28%
```

### Setting Up Status Line Monitoring

```bash
/statusline
# Select "Context percentage"
```

**Benefit:** Always visible, no need to run `/context` manually.

---

## Real-World Workflows

### Workflow 1: Single Feature (Token-Optimized)

```bash
# Start
claude
/context  # 5% (1k tokens)

# Implement feature
"Implement email validation using TDD"
# /tdd skill auto-invoked (+15k tokens)
[5 turns, TDD cycle completed]
/context  # 25% (50k tokens)

# Review
/code-review  # (+12k tokens)
/context  # 35% (70k tokens)

# Commit and clear
git commit -m "feat: add email validation"
/clear  # Back to 5%

# Total tokens used: ~70k
# Without optimization: ~150k
# Savings: 80k tokens (53%)
```

### Workflow 2: Research + Implementation

```bash
# Start
claude
/context  # 5%

# Research phase (use subagent)
"Use a subagent to research how we handle database migrations"
# Subagent reads 30 files in its own context
# Returns 1-page summary
/context  # 8% (+2k from summary only)

# Plan phase
/plan-architecture
"Design a new migration system based on that research"
# Creates IMPLEMENTATION_PLAN.md
/context  # 18%

# Checkpoint before implementation
/compact Preserve migration architecture plan and research summary
/context  # 12%

# Implementation phase
"Implement phase 1 of the migration system using TDD"
[15 turns]
/context  # 58%

# Review
/code-review
/security-audit
/context  # 72%

# Compact before continuing
/compact Preserve migration implementation and review findings
/context  # 35%

# Total tokens (main context): ~140k
# If done without subagent/compaction: ~350k+
# Savings: 210k+ tokens (60%)
```

### Workflow 3: Multi-Day Project

```bash
# Day 1: Research and planning
[Research with subagents]
[Create architecture plan]
/context  # 65%
git commit -m "docs: add API redesign architecture plan"
/clear  # End of day

# Day 2: Implementation phase 1
[Read yesterday's plan from git]
[Implement using TDD]
/context  # 70%
git commit -m "feat: implement API core"
/compact Preserve API design decisions
/context  # 30%

# Day 2 continued: Implementation phase 2
[Continue implementation]
/context  # 68%
git commit -m "feat: add API authentication"
/clear  # End of day

# Day 3: Testing and review
[Read commits from yesterday]
[Write integration tests]
[Code review]
/context  # 55%
git commit -m "test: add API integration tests"
/clear

# Token usage per day: 120-150k (with optimization)
# Without optimization: Would hit 200k limit partway through Day 1
# Result: Project possible only WITH token optimization
```

### Workflow 4: Bug Investigation

```bash
# Start
claude
/context  # 5%

# Investigate (use subagent for broad search)
"Use a subagent to find all code related to the checkout cart bug"
/context  # 7% (just summary)

# Deep dive on specific files
"Read the 3 files the subagent identified"
/context  # 18%

# Fix with TDD
"Write a test that reproduces the bug, then fix it"
/context  # 35%

# Verify
/security-audit  # Check if fix introduces vulnerabilities
/performance-check  # Ensure fix doesn't hurt performance
/context  # 52%

# Commit
git commit -m "fix(checkout): handle empty cart edge case"

# Don't need /clear (context still healthy)
# Can continue to next task

# Total tokens: ~100k
# Without subagent: ~200k+
# Savings: 100k+ tokens (50%)
```

---

## Quick Reference

### Token Reduction Strategies (Ranked by Impact)

| Strategy | Token Savings | When to Use | Effort |
|----------|---------------|-------------|--------|
| **Subagents for research** | 95-99% on research | Reading >10 files | Low |
| **`/clear` between tasks** | 70-90% overall | Switching tasks | Very low |
| **`/compact` at 60%** | 50-70% | Context at 60%+ | Low |
| **CLAUDE.md for rules** | Cumulative over sessions | Project setup | Medium |
| **Skills on-demand** | 50% on procedures | Repeating workflows | Medium |
| **Prompt caching** | 90% on cached (auto) | Focused work bursts | None (automatic) |

### Commands for Token Monitoring

```bash
/context                    # Check current token usage
/clear                      # Reset to ~5% (most aggressive)
/compact                    # Reduce by 50-70%
/compact [instructions]     # Reduce with preservation
/statusline                 # Add context to status line
```

### Explore Subagent Quick Examples

**Use Explore for these common research tasks:**

```bash
# Find files by purpose
"Use an Explore subagent to find all files related to [topic]"
"Spawn an Explore subagent to locate all [type] files"

# Map architecture
"Use an Explore subagent to map out the [system] architecture"
"Launch an Explore subagent to understand the [feature] data flow"

# Search for patterns
"Use an Explore subagent to find all HTTP request calls"
"Spawn an Explore subagent to locate all database queries"
"Use an Explore subagent to find TODO comments"

# Trace dependencies
"Use an Explore subagent to find what depends on [module]"
"Launch an Explore subagent to trace [function] usage"

# Security/quality audits
"Use an Explore subagent to find all password handling code"
"Spawn an Explore subagent to locate hardcoded secrets"
```

**Why Explore saves tokens:**
- ✅ **Faster:** Uses Haiku model (~15% cost of Sonnet)
- ✅ **Cheaper:** Read-only = optimized for research
- ✅ **Cleaner:** Returns 2k summary vs 80k+ file reads
- ✅ **Savings:** 95-99% token reduction on research

**Rule of thumb:** If task is "find", "search", "map", or "locate" → use Explore subagent

### Decision Tree: What to Use When

```
Context at 5-40%?
└─ Continue working normally

Context at 40-60%?
├─ If switching tasks → /clear
└─ If continuing task → Keep working

Context at 60-75%?
├─ If related work continues → /compact [preserve X]
└─ If new task → /clear

Context at 75%+?
└─ /compact or /clear immediately

Need to read many files (>10)?
├─ Read-only research → Use Explore subagent
├─ Need to write/edit → Use general-purpose subagent
└─ Already know exact 1-3 files → Read directly

Need to search/find/map code?
└─ Use Explore subagent (always)

Repeating same instructions?
├─ Every session → Put in CLAUDE.md
└─ Multi-step procedure → Create skill

Planning architecture?
├─ Complex design → Use Plan subagent
└─ Simple feature → Use /plan-architecture skill
```

### Token Optimization Checklist

**Daily habits:**
- [ ] Run `/context` every 10 turns
- [ ] Use `/clear` between unrelated tasks
- [ ] Use `/compact` at 60%, not 90%
- [ ] Use subagents for reading >10 files

**Session setup:**
- [ ] Put project rules in CLAUDE.md
- [ ] Let skills auto-invoke (don't over-invoke manually)
- [ ] Work in focused bursts (for prompt caching)

**Before committing:**
- [ ] Check `/context` - compact if >60%
- [ ] Commit your work
- [ ] Run `/clear` if switching to new task

---

## Additional Resources

**Other guides in this project:**
- **CONTEXT_MANAGEMENT_GUIDE.md** - Detailed context rot prevention
- **USAGE_GUIDE.md** - When to use Skills vs Subagents vs Commands
- **LEARNING_PATH.md** - Structured learning progression
- **GLOBAL_VS_PROJECT_SETUP.md** - Configuration organization

**Official Anthropic Documentation:**
- [How Claude Code Works](https://code.claude.com/docs/en/how-claude-code-works)
- [Best Practices](https://code.claude.com/docs/en/best-practices)
- [Subagents Guide](https://code.claude.com/docs/en/sub-agents)
- [Prompt Caching](https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching)

---

## Summary

**Key Insight:** Token optimization and quality maintenance are the same thing.

**The strategies that reduce tokens:**
1. `/clear` between tasks (70-90% reduction)
2. `/compact` at 60% (50-70% reduction)
3. Subagents for research (95-99% on research)
4. Skills on-demand (50% on procedures)
5. CLAUDE.md for persistence (cumulative savings)
6. Prompt caching (90% on cached, automatic)

**The habit:**
- Monitor context with `/context`
- Clean at 60%, not 90%
- Use subagents for research
- Let the official tools do the work

**The result:**
- Higher quality responses
- Lower token costs
- Longer, more complex projects possible
- Better use of prompt caching

**You're already doing this right** - your context is at 20% after compaction, which is optimal! 🎯
