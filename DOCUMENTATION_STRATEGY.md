# Documentation Strategy - When to Create Support Documents

**Based on Official Anthropic Guidelines for Claude Code**

This guide explains when to create documentation, design documents, planning files, and other artifacts during software development with Claude Code.

---

## Table of Contents

1. [Official Anthropic Principle](#official-anthropic-principle)
2. [Default: Work from Conversation Context](#default-work-from-conversation-context)
3. [The Multi-Session Exception](#the-multi-session-exception)
4. [When to Create Documentation](#when-to-create-documentation)
5. [Types of Documents](#types-of-documents)
6. [Multi-Session Workflow Patterns](#multi-session-workflow-patterns)
7. [Real-World Examples](#real-world-examples)
8. [Anti-Patterns to Avoid](#anti-patterns-to-avoid)
9. [Decision Tree](#decision-tree)

---

## Official Anthropic Principle

**From official guidelines:**

> **"Don't create planning, decision, or analysis documents unless the user asks for them — work from conversation context, not intermediate files."**

### Why This Principle?

**Reasons from Anthropic:**

1. **Conversation is the documentation** - Your conversation with Claude already contains all the context
2. **Reduces clutter** - Unnecessary files pollute the repository
3. **Prevents staleness** - Documents go out of date as code evolves
4. **Faster iteration** - Less overhead, more coding
5. **Better context usage** - Reading/writing docs uses tokens that could be used for code

### What This Means in Practice

```bash
# ❌ DON'T (Over-documentation)
You: "Design the OAuth2 integration"
Claude: [Creates DESIGN.md, ARCHITECTURE.md, TODO.md, NOTES.md]
        [Then implements based on those files]
# Problem: Too much overhead, files will go stale

# ✅ DO (Conversation-first)
You: "Design the OAuth2 integration"
Claude: [Discusses design in conversation]
        "I'll use JWT tokens with Redis session store..."
        [Implements directly]
# Result: Fast, no file clutter, conversation has all context
```

---

## Default: Work from Conversation Context

### The Conversation-First Approach

**Claude Code is designed to work from conversation, not files:**

```bash
# Planning phase (in conversation)
You: "I need to add OAuth2 login"

Claude: "I'll design this with three components:
        1. OAuthController - handles OAuth flow
        2. TokenService - manages JWT tokens  
        3. SessionStore - Redis-backed session storage
        
        The flow will be:
        User → OAuth provider → Callback → JWT → Redis session
        
        Should I proceed with TDD implementation?"

You: "Yes, start with the OAuthController"

# Implementation phase (direct to code)
Claude: [Writes test]
        [Writes code]
        [Refactors]
# ← No intermediate docs created!
```

**Result:**
- ✅ Design documented in conversation history
- ✅ Git commits have implementation details
- ✅ Code is self-documenting with good naming
- ✅ No files to maintain or go stale

### When This Works Best

**Single-session projects:**
- Feature can be completed in one conversation
- Context stays under 60% (120k tokens)
- No need to resume work later
- Bug fixes, small features, refactoring

**Example:**
```bash
# Start: Context 5%
"Add email validation to signup form using TDD"
[20 turns of TDD implementation]
# End: Context 45%

# ✅ Completed in single session
# ✅ No docs needed
# ✅ Design in conversation
# ✅ Behavior in tests
# ✅ Decision in commit message
```

---

## The Multi-Session Exception

### The Critical Question

**Can you complete this in one session?**

- **Yes (single session)** → Work from conversation, no docs
- **No (multi-session)** → Create planning docs as checkpoints

### Why Multi-Session Projects Need Docs

**The problem with conversation-only:**

```bash
# Session 1: Planning complex microservice migration
[3 hours of planning discussion]
[Claude reads 50 files, analyzes architecture]
[Designs 12-phase migration plan]
/context  # 75% (conversation full of planning context)

# End of day, you /clear or close session
/clear

# Next day - Session 2: Try to continue
You: "Continue with the microservice migration"
Claude: "What migration? I don't have context."
# ← All planning lost! 😱
```

**The solution: Planning documents as checkpoints:**

```bash
# Session 1: Planning with documentation
You: "Plan the microservice migration - this is a 3-month project.
      Create detailed planning docs."

[3 hours of planning discussion]
Claude: [Creates docs/MIGRATION_PLAN.md with 12 phases]
        [Creates docs/ARCHITECTURE.md with diagrams]
git commit -m "docs: add microservice migration plan"
/clear

# Session 2: Resume from checkpoint
You: "Read docs/MIGRATION_PLAN.md and implement phase 1"
Claude: [Reads plan - 10k tokens]
        [Has full context from document]
        [Implements phase 1]
# ✅ Work continues seamlessly!
```

### When Documents Become Checkpoints

**Think of docs like save points in a video game:**
- Don't save every 5 seconds → Don't doc every small task
- DO save before boss battles → DO doc complex multi-session work
- Saves let you resume from checkpoint → Docs let you resume work

---

## When to Create Documentation

### Decision Matrix

| Scenario | Create Docs? | Why |
|----------|-------------|-----|
| Single-session feature | ❌ No | Work from conversation |
| Multi-session project | ✅ Yes | Need checkpoint to resume |
| User explicitly requests | ✅ Yes | User knows their needs |
| Plan Mode (Shift+Tab twice) | ✅ Auto | Plan Mode creates IMPLEMENTATION_PLAN.md |
| Team collaboration | ✅ Yes | Multiple people need context |
| Compliance/audit | ✅ Yes | Legal requirement |
| Simple bug fix | ❌ No | Fix directly, document in commit |
| Complex architecture | 🤔 Maybe | If multi-session, yes. If single session, no. |

### Explicit User Request (Always Create)

```bash
# ✅ User explicitly requests doc
You: "Create an architecture design document for the OAuth2 integration"
Claude: [Creates ARCHITECTURE.md with design]

# ✅ User explicitly requests planning doc
You: "Write an implementation plan in a markdown file"
Claude: [Creates IMPLEMENTATION_PLAN.md]

# ✅ User explicitly requests ADR
You: "Document the decision to use JWT in an ADR"
Claude: [Creates docs/adr/0001-use-jwt-for-auth.md]
```

**Why always create:** User knows their workflow and needs better than Claude does.

### Plan Mode (Automatic Creation)

```bash
# Shift+Tab twice to enter plan mode
You: "Design OAuth2 integration"
Claude: [Explores codebase]
        [Creates IMPLEMENTATION_PLAN.md automatically]
        [Asks for approval]
# ← This is the ONLY automatic doc creation!
```

**Why the exception:**
- Plan Mode explicitly designed for review-before-implementation
- User needs concrete artifact to review and approve
- Creates accountability
- Perfect for multi-session work

### Multi-Session Projects (Critical Case)

**Indicators you need documentation:**

✅ **Time span:**
- Project takes multiple days/weeks
- Can't complete in one sitting
- Need to resume work after break

✅ **Complexity:**
- Multiple phases/stages
- Many components to coordinate
- Complex dependencies

✅ **Team coordination:**
- Multiple people working on it
- Handoffs between team members
- Needs shared reference

✅ **Context size:**
- Planning alone uses >40% context
- Can't fit planning + implementation in one session

**Example:**
```bash
# Multi-session project
You: "We're building a microservice architecture - this is a 3-month project.
      Create detailed planning docs."

Claude: [Creates comprehensive planning docs]
        [These serve as checkpoints for 3 months of work]
```

### Team Collaboration

```bash
# Team needs architecture overview
You: "Create an architecture overview document for the new developers"
Claude: [Creates docs/ARCHITECTURE.md]

# Team needs API documentation
You: "Generate API documentation from the code for the frontend team"
Claude: [Creates docs/API.md or uses tool to generate]
```

### Regulatory/Compliance Requirements

```bash
# Compliance requirement
You: "Create an ADR for the encryption algorithm choice - 
      compliance needs audit trail"
Claude: [Creates docs/adr/0005-aes-256-encryption.md]

# Security audit requirement
You: "Document the security model in a file for the audit team"
Claude: [Creates SECURITY.md]
```

---

## Types of Documents

### 1. Implementation Plans (IMPLEMENTATION_PLAN.md)

**When to create:**
- ✅ Using Plan Mode (Shift+Tab twice) - created automatically
- ✅ User explicitly requests a plan file
- ✅ Multi-session project needs checkpoint
- ✅ Complex feature with many phases

**When NOT to create:**
- ❌ Simple features (can plan in conversation)
- ❌ Single-session work
- ❌ Bug fixes (fix directly)

**Structure:**
```markdown
# Implementation Plan: Microservice Migration

## Overview
Migrate monolithic application to microservices architecture over 12 weeks.

## Phases

### Phase 1: Extract Payment Service (Week 1-2)
**Goal:** Create standalone payment microservice

**Steps:**
1. Create new payment-service repository
2. Extract payment models and logic
3. Create REST API interface
4. Set up database (PostgreSQL)
5. Implement tests
6. Deploy to staging

**Success criteria:**
- Payment processing works through API
- All tests passing
- Zero downtime migration

### Phase 2: Extract Inventory Service (Week 3-4)
...

### Phase 3-12: [Continue...]

## Dependencies
- Phase 2 depends on Phase 1 (payment API needed)
- Phase 5 depends on Phase 2 & 3 (orchestration)

## Timeline
- Total: 12 weeks
- Phase 1: Week 1-2
- Phase 2: Week 3-4
- ...

## Rollback Plan
If Phase N fails:
1. Revert code to previous tag
2. Restore database from backup
3. Switch traffic back to monolith
```

**Usage pattern:**
```bash
# Session 1: Create plan
[Plan Mode or explicit request]
Claude: [Creates IMPLEMENTATION_PLAN.md]
/clear

# Session 2-N: Implement each phase
You: "Read IMPLEMENTATION_PLAN.md and implement phase 1"
Claude: [Reads plan, implements phase 1]

You: "Read IMPLEMENTATION_PLAN.md and implement phase 2"
Claude: [Reads plan, implements phase 2]
...
```

---

### 2. Architecture Docs (ARCHITECTURE.md)

**When to create:**
- ✅ User explicitly requests
- ✅ Team onboarding needs
- ✅ Complex system that benefits from diagram/overview
- ✅ External stakeholders need documentation
- ✅ Multi-session project needs reference

**When NOT to create:**
- ❌ Code is self-documenting
- ❌ Simple systems
- ❌ Documentation would just duplicate code
- ❌ Single-session simple feature

**Structure:**
```markdown
# System Architecture: E-Commerce Platform

## Overview
Microservices-based e-commerce platform with event-driven architecture.

## System Diagram

```
┌─────────┐      ┌──────────┐      ┌───────────┐
│  React  │─────▶│   API    │─────▶│  Payment  │
│   SPA   │      │ Gateway  │      │  Service  │
└─────────┘      └────┬─────┘      └─────┬─────┘
                      │                   │
                      ▼                   ▼
                 ┌─────────┐         ┌────────┐
                 │  Auth   │         │ Event  │
                 │ Service │         │  Bus   │
                 └─────────┘         └────────┘
```

## Components

### API Gateway
- **Technology:** Node.js + Express
- **Responsibility:** Route requests, authentication, rate limiting
- **Depends on:** Auth Service
- **Entry point:** `src/gateway/server.ts`

### Payment Service
- **Technology:** Python + FastAPI
- **Responsibility:** Process payments via Stripe
- **Database:** PostgreSQL
- **Entry point:** `services/payment/main.py`

### Auth Service
- **Technology:** Go
- **Responsibility:** JWT generation, user authentication
- **Database:** Redis (sessions)
- **Entry point:** `services/auth/cmd/server.go`

## Data Flow

### Checkout Flow
1. User submits order (React SPA)
2. API Gateway validates JWT
3. Gateway calls Payment Service
4. Payment Service charges Stripe
5. Event published to Event Bus
6. Inventory Service listens and updates stock

## Technology Stack
- **Frontend:** React, TypeScript
- **Backend:** Node.js, Python, Go
- **Databases:** PostgreSQL, Redis
- **Message Bus:** RabbitMQ
- **Deployment:** Docker, Kubernetes

## Key Design Decisions
- **Why microservices?** Independent scaling, team autonomy
- **Why event bus?** Decouple services, async processing
- **Why multiple languages?** Use best tool for each service
```

**Usage pattern:**
```bash
# Created once for team/project reference
# Read multiple times across many sessions
# Updated when architecture changes
```

---

### 3. Architecture Decision Records (ADRs)

**When to create:**
- ✅ Significant architectural decision
- ✅ User explicitly requests
- ✅ Team needs decision history
- ✅ Compliance/audit requirements
- ✅ Controversial decision that needs justification

**When NOT to create:**
- ❌ Small implementation details
- ❌ Obvious technology choices
- ❌ Decisions already self-evident in code

**Structure (using ADR template):**
```markdown
# ADR 0001: Use PostgreSQL for Data Storage

## Status
Accepted

## Context
We need a database for user data, orders, and product catalog. Requirements:
- ACID compliance for financial transactions
- Complex queries for reporting
- Relationships between entities (users, orders, products)
- Expected scale: 1M users, 10K orders/day

Options considered:
1. PostgreSQL (relational)
2. MongoDB (document)
3. MySQL (relational)

## Decision
Use PostgreSQL 14+ for primary data storage.

## Rationale
**Why PostgreSQL:**
- ✅ ACID guarantees for financial data
- ✅ Rich query language (complex reports)
- ✅ JSON support (flexibility when needed)
- ✅ Team expertise (3/5 devs know it well)
- ✅ Battle-tested at this scale

**Why not MongoDB:**
- ❌ No ACID across collections
- ❌ Complex queries harder
- ❌ Team less familiar

**Why not MySQL:**
- ✅ Would work, but PostgreSQL JSON support better
- ✅ PostgreSQL more advanced features

## Consequences

### Positive
- Strong data consistency
- Complex queries easy to write
- Good tooling and community

### Negative
- Schema migrations required (vs schemaless)
- Horizontal scaling more complex than NoSQL
- Need to learn PostgreSQL-specific features

### Mitigation
- Use Alembic for schema migrations
- Start with single instance, can add read replicas later
- Document PostgreSQL patterns in team wiki

## Compliance Note
Financial data ACID compliance required by SOC 2 audit.
```

**Usage pattern:**
```bash
# Create when making significant decision
You: "Document the PostgreSQL decision in an ADR"
Claude: [Creates docs/adr/0001-postgresql.md]

# Reference later when new developers ask "why PostgreSQL?"
# Never modified (it's historical record)
```

---

### 4. API Documentation (API.md)

**When to create:**
- ✅ Public/external API
- ✅ User explicitly requests
- ✅ Team needs API reference
- ✅ Can be auto-generated from code
- ✅ Frontend team needs backend contract

**When NOT to create:**
- ❌ Internal functions (use docstrings instead)
- ❌ Self-explanatory APIs
- ❌ Rapidly changing APIs (will go stale)
- ❌ Small internal projects

**Auto-generation preferred:**
```bash
# ✅ GOOD: Auto-generate from code
You: "Generate OpenAPI spec from the FastAPI code"
Claude: [Generates openapi.json automatically from code]
# ← Always up to date with code!

# ✅ GOOD: Auto-generate docs
You: "Use Swagger to generate API documentation"
Claude: [Sets up Swagger UI with live docs]
# ← Can't go stale, generated from code!
```

**Manual creation (if needed):**
```markdown
# API Documentation

## Authentication
All endpoints require JWT token in Authorization header:
```
Authorization: Bearer <token>
```

## Endpoints

### POST /api/auth/login
Login user and receive JWT token.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "secure_password"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "expires_in": 3600,
  "user": {
    "id": "123",
    "email": "user@example.com"
  }
}
```

**Errors:**
- 400: Invalid credentials
- 429: Rate limit exceeded

### GET /api/users/{id}
Get user by ID.

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200 OK):**
```json
{
  "id": "123",
  "email": "user@example.com",
  "created_at": "2026-05-12T10:00:00Z"
}
```

**Errors:**
- 401: Unauthorized
- 404: User not found

## Rate Limits
- 100 requests/minute per IP
- 1000 requests/hour per user
```

---

### 5. README.md (Always Update)

**Always update README if it exists:**

```bash
# Project has README.md
You: "Add OAuth2 feature"
Claude: [Implements feature]
        [Updates README.md with OAuth2 setup instructions]
# ← README is essential project documentation!
```

**What goes in README:**
- ✅ Setup instructions
- ✅ How to run the project
- ✅ Environment variables
- ✅ Testing commands
- ✅ Deployment steps
- ✅ Basic architecture overview (brief)
- ❌ NOT detailed architecture (separate doc)
- ❌ NOT implementation notes (use conversation/commits)
- ❌ NOT API documentation (separate doc)

---

### 6. Code Comments (Minimal by Default)

**Official guidance:**

> "Default to writing NO comments. Only add one when the WHY is non-obvious: a hidden constraint, a subtle invariant, a workaround for a specific bug."

**When to write comments:**
- ✅ Non-obvious WHY (hidden constraint, workaround)
- ✅ Subtle invariant that would surprise readers
- ✅ Workaround for specific bug/limitation

**When NOT to write comments:**
- ❌ WHAT the code does (code should be self-documenting)
- ❌ Referencing current task ("added for feature X")
- ❌ Calling out who uses it ("used by X", "called from Y")
- ❌ Implementation details (refactor code instead)

**Examples:**

```python
# ❌ BAD: States the obvious
# Calculate the total price
total = sum(item.price for item in cart)

# ❌ BAD: References task/ticket
# Added for the checkout flow (issue #234)
total = sum(item.price for item in cart)

# ✅ GOOD: Explains non-obvious WHY
# Sum in this order to match payment processor's rounding behavior
# (different order gives $0.01 difference due to floating point)
total = sum(item.price for item in cart)

# ✅ GOOD: Documents workaround
# Timeout must be 30s exactly - payment gateway returns 500 if different
client = PaymentClient(timeout=30)
```

---

## Multi-Session Workflow Patterns

### Pattern 1: Plan Once, Implement in Phases

**Best for:** Complex project with clear phases

```bash
# ============================================
# SESSION 1: Planning (creates checkpoint)
# ============================================
/context  # 5%

You: "We're migrating to microservices over 3 months.
      Create detailed implementation plan."

# Heavy planning
Claude: [Reads 50 files to understand current architecture]
        [Analyzes dependencies]
        [Designs 12-phase migration]
        [Creates docs/MIGRATION_PLAN.md]
        [Creates docs/ARCHITECTURE.md]

/context  # 70% (heavy planning used lots of context)

git commit -m "docs: add microservice migration plan"

# Save work and clear
/clear  # or end session

# ============================================
# SESSION 2: Phase 1 Implementation
# ============================================
/context  # 5% (fresh start!)

You: "Read docs/MIGRATION_PLAN.md and implement phase 1"

Claude: [Reads MIGRATION_PLAN.md - ~10k tokens]
        [Has full context of plan]
        [Implements phase 1: Extract payment service]
        [Uses TDD]

/context  # 45% (plan reading + implementation)

git commit -m "feat: extract payment service (phase 1/12)"
/clear

# ============================================
# SESSION 3: Phase 2 Implementation
# ============================================
/context  # 5% (fresh again!)

You: "Read docs/MIGRATION_PLAN.md and implement phase 2"

Claude: [Reads plan again - ~10k tokens]
        [Implements phase 2: Extract inventory service]

git commit -m "feat: extract inventory service (phase 2/12)"
/clear

# ============================================
# ... Sessions 4-13: Phases 3-12
# ============================================

# Each session:
# 1. Starts fresh (5% context)
# 2. Reads plan document (~10k tokens)
# 3. Implements one phase
# 4. Commits
# 5. Clears for next phase
```

**Why this works:**
- ✅ Plan document is "save point" - can resume anytime
- ✅ Each implementation session starts fresh
- ✅ Plan reading only uses ~10k tokens (5% of context)
- ✅ Leaves 95% of context for implementation
- ✅ Can work on phases over weeks/months

---

### Pattern 2: Research → Document → Implement

**Best for:** Unfamiliar domain requiring heavy research

```bash
# ============================================
# SESSION 1: Research (use subagent!)
# ============================================
/context  # 5%

You: "Use an Explore subagent to research how we currently handle payments"

# Subagent does heavy research in separate context
Explore Subagent: [Reads 40 files in its own context]
                  [Analyzes payment flow]
                  [Returns comprehensive summary]

Claude: [Receives 2-3k token summary]

/context  # 8% (just summary, not 40 file reads!)

# ============================================
# SESSION 2: Planning & Documentation
# ============================================

You: "Based on that research, create a detailed plan to migrate
      to Stripe - this is a 6-week project"

Claude: [Uses research summary from previous session]
        [Designs migration approach]
        [Creates docs/STRIPE_MIGRATION_PLAN.md]
        [Creates docs/PAYMENT_ARCHITECTURE.md]

git commit -m "docs: add Stripe migration plan"
/context  # 35%
/clear

# ============================================
# SESSION 3-N: Implementation
# ============================================

You: "Read docs/STRIPE_MIGRATION_PLAN.md and implement phase 1"
[Implement each phase in separate sessions]
```

**Why this works:**
- ✅ Explore subagent keeps research out of main context
- ✅ Planning session uses research summary
- ✅ Implementation sessions read plan document
- ✅ Each phase can be different session

---

### Pattern 3: Git Commits as Checkpoints

**Best for:** When you don't want separate planning docs

```bash
# ============================================
# SESSION 1: Implement Phase 1
# ============================================

You: "Start implementing the microservice migration - 
      begin with extracting the payment service"

Claude: [Implements payment service extraction]

git commit -m "feat(microservices): extract payment service (phase 1/12)

Extracted payment processing into standalone service.

Architecture:
- REST API for payment operations
- PostgreSQL database for payment data
- Stripe integration for processing

Next steps:
- Phase 2: Extract inventory service
- Phase 3: Extract user service
...
- Phase 12: Decommission monolith

Migration plan:
Each service can be deployed independently.
Old monolith calls new services via API during transition.
Final cutover once all 12 services extracted.
"

/context  # 55%
/clear

# ============================================
# SESSION 2: Continue from Git History
# ============================================
/context  # 5%

You: "Read the recent git commits and continue the microservice migration
      with phase 2"

Claude: [Reads recent commits]
        [Sees phase 1 done, phase 2 next]
        [Implements inventory service extraction]

git commit -m "feat(microservices): extract inventory service (phase 2/12)
...
"
```

**Why this works:**
- ✅ Git commit messages serve as planning docs
- ✅ No separate PLAN.md to maintain
- ✅ History shows what's done vs what's next
- ✅ Can resume from commit history

**Limitation:**
- ⚠️ Works for smaller projects (12 phases ok, 100 steps harder)
- ⚠️ Reading many commits uses context
- ⚠️ Better for sequential work than complex dependencies

---

### Pattern 4: Hybrid (Plan + Commits)

**Best for:** Large project with both planning and implementation checkpoints

```bash
# SESSION 1: High-level planning
You: "Create high-level migration plan (12 phases)"
Claude: [Creates docs/MIGRATION_PLAN.md with high-level phases]

# SESSION 2-13: Each phase
You: "Read MIGRATION_PLAN.md, implement phase N"
[Implement with TDD]
git commit -m "feat: phase N - [detailed implementation notes]"
# ← Commit has implementation details
# ← Plan has high-level overview

# Later sessions can read either:
# - Plan doc for "what's the big picture?"
# - Git commits for "what did we actually implement?"
```

---

## Real-World Examples

### Example 1: Simple Feature (No Docs)

```bash
# Task: Add email validation to signup
You: "Add email validation to the signup form using TDD"

# Conversation-based design
Claude: "I'll validate emails using regex pattern and DNS check.
         Writing test first..."

# Implementation
[Writes test]
[Implements validation]
[Refactors]

# Commit
git commit -m "feat(auth): add email validation to signup

Uses regex + DNS check for email validation
Prevents signups with invalid/disposable emails

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# ✅ No docs created!
# ✅ Design in conversation
# ✅ Behavior in tests
# ✅ Decision in commit message
```

---

### Example 2: Multi-Session Project (With Planning Doc)

```bash
# ============================================
# SESSION 1: Planning (Day 1)
# ============================================

You: "We're migrating our monolith to microservices over 3 months.
      Create a detailed implementation plan."

[Enter Plan Mode with Shift+Tab twice]

Claude: [Explores current architecture]
        [Reads 50 files]
        [Analyzes dependencies]
        [Creates MICROSERVICE_MIGRATION_PLAN.md with 12 phases]

/context  # 75%

git commit -m "docs: add microservice migration plan"
/clear

# ============================================
# SESSION 2: Phase 1 (Week 1)
# ============================================

You: "Read MICROSERVICE_MIGRATION_PLAN.md and implement phase 1"

Claude: [Reads plan - 10k tokens]
        [Implements payment service extraction]

git commit -m "feat: extract payment service (phase 1/12)"
/clear

# ============================================
# SESSION 3: Phase 2 (Week 2)
# ============================================

You: "Read MICROSERVICE_MIGRATION_PLAN.md and implement phase 2"

Claude: [Reads plan]
        [Implements inventory service extraction]

# ... Continue over 12 weeks

# ✅ Plan document serves as checkpoint
# ✅ Each implementation session starts fresh
# ✅ Can work over months without context issues
```

---

### Example 3: Team Collaboration (Architecture Doc)

```bash
# Task: New developers joining team
You: "Create an architecture overview for new developers"

# User explicitly requested for team needs
Claude: [Creates docs/ARCHITECTURE.md with:
         - System overview
         - Component diagram (ASCII art)
         - Data flow
         - Key technologies
         - Links to code entry points]

git commit -m "docs: add architecture overview for onboarding"

# ✅ Docs created (team onboarding need)
# ✅ User explicitly requested
# ✅ Serves long-term reference purpose
# ✅ Multiple people benefit
```

---

### Example 4: Compliance/Audit (ADRs)

```bash
# Task: Security audit requires documentation
You: "Document the encryption decisions for the security audit - 
      they need ADRs for all crypto choices"

# Compliance requirement
Claude: [Creates docs/adr/0010-aes-256-gcm-encryption.md]
        [Creates docs/adr/0011-argon2-password-hashing.md]
        [Creates docs/SECURITY.md summarizing approach]

# ✅ Docs created (compliance requirement)
# ✅ Audit trail needed
# ✅ User explicitly requested
```

---

## Anti-Patterns to Avoid

### Anti-Pattern 1: Premature Documentation

```bash
# ❌ BAD
You: "I'm thinking about maybe adding OAuth2 someday"
Claude: [Creates OAUTH2_DESIGN.md with full design]
# Problem: Document created for something not even committed to!

# ✅ GOOD
You: "I'm thinking about maybe adding OAuth2 someday"
Claude: "OAuth2 would involve... [discusses in conversation]"
# Solution: Discussion, no files until you commit to implementing
```

---

### Anti-Pattern 2: Documentation Duplication

```bash
# ❌ BAD
Claude: [Creates ARCHITECTURE.md]
        [Creates DESIGN.md]
        [Creates OVERVIEW.md]
        [Creates IMPLEMENTATION.md]
# Problem: Same information in 4 different files!

# ✅ GOOD
Claude: [Discusses architecture in conversation]
        [Implements code]
        [Maybe creates single ARCHITECTURE.md if user requests]
# Solution: Information in ONE canonical place
```

---

### Anti-Pattern 3: "Planning Theater"

```bash
# ❌ BAD
Claude: [Creates TODO.md with 50 tasks]
        [Creates PLAN.md with timeline]
        [Creates DESIGN.md with approach]
        [Creates NOTES.md with thoughts]
        [Still hasn't written any code!]
# Problem: Lots of planning, zero implementation!

# ✅ GOOD
Claude: [Discusses approach in 3 messages]
        [Starts implementing with TDD immediately]
# Solution: Minimal planning, maximum implementation
```

---

### Anti-Pattern 4: Stale Documentation

```bash
# ❌ BAD
Week 1: [Creates ARCHITECTURE.md describing Redis session store]
Week 3: [Switches to PostgreSQL sessions - doesn't update doc]
Week 5: [New developer reads ARCHITECTURE.md, gets confused]
# Problem: Document is wrong, worse than no document!

# ✅ GOOD (Option A)
Week 1: [Discusses Redis approach in conversation, implements]
Week 3: [Discusses PostgreSQL switch in conversation, refactors]
Week 5: [New developer reads current code, sees PostgreSQL]
# Solution: Code is always current, no stale docs

# ✅ GOOD (Option B)
Week 1: [Creates ARCHITECTURE.md with Redis]
Week 3: [Updates ARCHITECTURE.md to PostgreSQL when switching]
# Solution: If docs exist, keep them current or delete them
```

---

### Anti-Pattern 5: Over-Commenting Code

```python
# ❌ BAD
def calculate_total(cart):
    """
    Calculate the total price of items in the cart.
    
    This function is part of the checkout flow and was added
    to support the new payment processing feature (issue #234).
    It is called by the CheckoutService class when processing
    orders. The function takes a cart parameter which is a list
    of items.
    
    Args:
        cart: The shopping cart items
        
    Returns:
        The total price as a Decimal
    """
    # Initialize the total to zero
    total = Decimal('0')
    
    # Loop through each item in the cart
    for item in cart:
        # Add the item's price to the total
        total += item.price
    
    # Return the calculated total
    return total

# ✅ GOOD
def calculate_total(cart):
    """Calculate total price of cart items."""
    # Sum in this order to match payment processor's rounding
    return sum(item.price for item in cart)
```

---

## Decision Tree

### Should I Create a Document?

```
Need to document something?
│
├─ Is it code behavior?
│  └─ ✅ Write a test (tests are documentation)
│
├─ Is it a decision/rationale?
│  └─ ✅ Put in git commit message
│
├─ Is it project rules (build commands, code style)?
│  └─ ✅ Put in CLAUDE.md
│
├─ Did user explicitly ask for a document?
│  └─ ✅ YES → Create the document
│  └─ ❌ NO → Continue below
│
├─ Is this a multi-session project? (takes days/weeks)
│  ├─ ✅ YES → Create planning document
│  │          (serves as checkpoint to resume work)
│  └─ ❌ NO → Continue below
│
├─ Using Plan Mode? (Shift+Tab twice)
│  └─ ✅ YES → IMPLEMENTATION_PLAN.md created automatically
│
├─ Is it required for compliance/audit?
│  └─ ✅ YES → Create document (ADR, SECURITY.md, etc.)
│
├─ Is it for team onboarding/collaboration?
│  └─ 🤔 MAYBE → Ask user: "Should I create an architecture overview?"
│
└─ DEFAULT: ❌ Work from conversation, don't create docs
```

---

## Summary

### The Core Principle

**"Don't create planning, decision, or analysis documents unless the user asks for them — work from conversation context, not intermediate files."**

### The Multi-Session Exception

**For projects that span multiple days/weeks:**
- ✅ Create planning documents as "save points"
- ✅ Each new session reads the plan and continues
- ✅ Plan document prevents losing context between sessions

### When to Create Docs

| Situation | Create Docs? |
|-----------|-------------|
| **Single-session work** | ❌ No - work from conversation |
| **Multi-session project** | ✅ Yes - need checkpoint to resume |
| **User explicitly requests** | ✅ Yes - user knows their needs |
| **Plan Mode** | ✅ Auto - creates IMPLEMENTATION_PLAN.md |
| **Team collaboration** | ✅ Yes - multiple people need context |
| **Compliance/audit** | ✅ Yes - legal requirement |
| **Simple feature/bug fix** | ❌ No - implement directly |

### The Default Workflow

**For most tasks (single-session):**
```
1. Discuss design in conversation
2. Implement with TDD
3. Document decisions in commit messages
4. Document behavior in tests
5. Update README if needed
6. Done! (No extra files created)
```

**For large projects (multi-session):**
```
1. SESSION 1: Create planning docs (checkpoint)
2. SESSION 2+: Read plan, implement phase N
3. Each session starts fresh, reads plan
4. Plan serves as "save point" for months of work
```

### Remember

- **Conversation is documentation** (for single-session work)
- **Planning docs are checkpoints** (for multi-session work)
- **Code is documentation** (with good naming and structure)
- **Tests are documentation** (describe behavior)
- **Commits are documentation** (explain decisions)
- **Files are for multi-session** (when conversation won't persist)

---

## Additional Resources

**Related guides:**
- **USAGE_GUIDE.md** - When to use Skills vs Subagents vs Commands
- **CONTEXT_MANAGEMENT_GUIDE.md** - How to prevent context rot
- **TOKEN_OPTIMIZATION_GUIDE.md** - Reduce token usage, multi-session patterns
- **CLAUDE.md** - Project rules (not documentation)

**Official Anthropic Documentation:**
- [Best Practices](https://code.claude.com/docs/en/best-practices)
- [How Claude Code Works](https://code.claude.com/docs/en/how-claude-code-works)
