# Memory Management Guide - Preventing Memory Rot

**Based on Official Anthropic Guidelines for Claude Code**

This guide explains how to use Claude Code's persistent memory system effectively while avoiding "memory rot" - the gradual degradation that happens when memory grows too large or becomes stale.

---

## Table of Contents

1. [Understanding Memory](#understanding-memory)
2. [The Memory Rot Problem](#the-memory-rot-problem)
3. [Memory vs Context](#memory-vs-context)
4. [What to Save (and Not Save)](#what-to-save-and-not-save)
5. [Memory Hygiene Best Practices](#memory-hygiene-best-practices)
6. [How to Maintain Memory](#how-to-maintain-memory)
7. [Memory Structure](#memory-structure)
8. [Real-World Examples](#real-world-examples)
9. [Troubleshooting Memory Issues](#troubleshooting-memory-issues)

---

## Understanding Memory

### What is Memory?

**Memory** is Claude Code's persistent knowledge system that survives across sessions.

**Location:** `/home/gyr/.claude/projects/<project-hash>/memory/`

**Purpose:**
- Store facts that are useful across multiple sessions
- Remember user preferences and working patterns
- Track long-term project context
- Avoid re-explaining the same things every session

**Key difference from context:**
- **Context:** Temporary (this session only), resets with `/clear` or `/new`
- **Memory:** Permanent (all sessions), survives restarts

### How Memory Works

```
┌──────────────────────────────────────────────┐
│ Session Start (Automatic)                    │
│                                              │
│  Memory files loaded into context:           │
│  ├─ MEMORY.md (index)                        │
│  ├─ user_preferences.md                      │
│  ├─ feedback_tdd.md                          │
│  └─ project_migration.md                     │
│                                              │
│  Cost: ~5k tokens (loaded at session start)  │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│ During Session                                │
│                                              │
│  Memory stays loaded in context              │
│  Claude can reference memory anytime         │
│  New memories can be created/updated         │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│ Session End                                   │
│                                              │
│  Memory persists to disk                     │
│  Available in next session                   │
│  Context cleared, memory remains             │
└──────────────────────────────────────────────┘
```

---

## The Memory Rot Problem

### What is Memory Rot?

**Memory rot** occurs when your persistent memory system becomes too large, stale, or cluttered, degrading Claude's performance in future sessions.

**Similar to context rot, but worse:**
- Context rot: Affects one session (fixable with `/clear`)
- Memory rot: Affects ALL future sessions (requires manual cleanup)

### How Memory Rot Happens

**Example: Unchecked Memory Growth**

```bash
# Month 1: Small memory (healthy)
├─ user_preferences.md (1k tokens)
├─ feedback_tdd.md (500 tokens)
└─ project_microservices.md (1k tokens)
Total: 2.5k tokens (healthy!)

# Month 3: Growing memory
├─ user_preferences.md (1k)
├─ feedback_tdd.md (500)
├─ project_microservices.md (2k)  ← growing
├─ project_payment_refactor.md (1.5k)  ← new
├─ project_inventory_migration.md (1.5k)  ← new
└─ reference_apis.md (1k)
Total: 7.5k tokens (still ok)

# Month 6: Memory bloat
├─ user_preferences.md (2k)  ← detailed life story
├─ feedback_tdd.md (500)
├─ project_microservices.md (3k)  ← outdated details
├─ project_payment_refactor.md (2k)  ← completed but not removed!
├─ project_inventory_migration.md (2k)  ← completed but not removed!
├─ project_auth_redesign.md (2k)  ← completed but not removed!
├─ project_api_v2.md (2k)  ← current work
├─ project_database_migration.md (2k)  ← current work
├─ reference_apis.md (2k)
├─ reference_tools.md (1.5k)
├─ debugging_notes.md (3k)  ← SHOULD NOT BE IN MEMORY!
├─ architecture_details.md (5k)  ← SHOULD BE IN DOCS, NOT MEMORY!
└─ meeting_notes.md (4k)  ← EPHEMERAL, SHOULDN'T BE HERE!
Total: 31k tokens (BLOATED! 😱)

# Result: Every session starts at 15% context instead of 5%!
```

### Symptoms of Memory Rot

**You have memory rot when:**

1. **Sessions start with high context**
   - New session context >10% immediately
   - Should start at ~5%

2. **Memory contains stale information**
   - References completed projects
   - Outdated preferences
   - Old temporary states

3. **Memory has duplicates**
   - Same information in multiple files
   - Contradictory memories

4. **Memory has details, not facts**
   - Long explanations instead of concise facts
   - Implementation details instead of decisions
   - Conversation transcripts instead of takeaways

### Official Guardrail: 200-Line Limit

**From Anthropic guidelines:**

> "MEMORY.md is always loaded into your conversation context — lines after 200 will be truncated, so keep the index concise."

**What this means:**
- MEMORY.md (the index) has a hard 200-line limit
- After 200 lines, entries are truncated (ignored)
- This forces you to keep memory concise

**If you hit 200 lines:**
- 🚨 You have too many memory files
- Time to prune/consolidate
- Remove stale memories

---

## Memory vs Context

### Side-by-Side Comparison

| Feature | Context | Memory |
|---------|---------|--------|
| **Lifetime** | Current session only | Permanent (all sessions) |
| **Size** | 200k tokens max | Small files (1-2k each recommended) |
| **Loaded when** | During this session | Every session start |
| **Content** | Full conversation details | Key facts only |
| **Cleared by** | `/clear`, `/new` | Manual deletion only |
| **Best for** | Implementation work | Persistent knowledge |
| **Rot type** | Context rot (gradual in session) | Memory rot (across sessions) |
| **Fix rot** | `/clear` or `/compact` | Manual file cleanup |

### The Golden Rule

**Context = Details**
- Full conversation
- Implementation specifics
- Current work-in-progress

**Memory = Facts**
- User preferences (stable)
- Project status (high-level)
- Feedback patterns (reusable)
- References (where things are)

---

## What to Save (and Not Save)

### Official Guidelines: What NOT to Save

From Anthropic's memory system documentation:

❌ **NEVER save to memory:**

1. **Code patterns, conventions, architecture**
   - Can be derived by reading current project state
   - Changes too frequently
   - Save in CLAUDE.md instead (if project-wide rules)

2. **Git history, recent changes, who-changed-what**
   - `git log` and `git blame` are authoritative
   - Becomes stale immediately

3. **Debugging solutions or fix recipes**
   - The fix is in the code
   - Commit message has context

4. **Anything already documented in CLAUDE.md**
   - CLAUDE.md is loaded every session anyway
   - Duplicating wastes memory

5. **Ephemeral task details**
   - In-progress work
   - Temporary state
   - Current conversation context

6. **Implementation details**
   - How code works (read the code!)
   - File structures (can be explored)
   - Technical specifics (in docs or code)

### Official Guidelines: What TO Save

✅ **DO save to memory:**

1. **User preferences (that won't change)**
   - Role, expertise level
   - Learning style
   - Working preferences
   
2. **Feedback on how to work with you**
   - "Don't do X"
   - "Always do Y"
   - Corrections to Claude's approach

3. **Long-term project context**
   - Multi-month initiatives
   - Why decisions were made
   - Deadlines that span weeks/months

4. **References to external systems**
   - Where documentation lives
   - How to access resources
   - Team conventions

### The Surprise/Non-Obvious Test

**Official guideline:**

> "If the user asks to save a PR list or activity summary, ask what was *surprising* or *non-obvious* about it — that is the part worth keeping."

**Examples:**

```bash
# ❌ BAD: Saving full activity log
You: "Save this to memory: [50-line activity log]"
Claude: [Saves entire log - 5k tokens!]
# Problem: Too much detail, will become stale

# ✅ GOOD: Extracting the insight
You: "Save this to memory: [50-line activity log]"
Claude: "What was surprising or non-obvious about this activity?"
You: "We discovered the payment service has hidden dependency on user service"
Claude: [Saves only the insight - 200 tokens]
# Result: Key fact preserved, details discarded
```

---

## Memory Hygiene Best Practices

### 1. Keep Memory Files Small

**Target:** 1-2k tokens per memory file

**Why:** 
- Faster to load
- Easier to maintain
- Forces you to be concise

**How:**
```markdown
# ❌ BAD: Detailed memory file (5k tokens)
---
name: user-background
type: user
---

User is a software developer with 15 years of experience.
Started programming in college with Java...
[20 paragraphs of biography]
Prefers explicit error handling...
[10 paragraphs about coding style]
Current project is migrating monolith to microservices...
[15 paragraphs about project history]

# ✅ GOOD: Concise memory file (1k tokens)
---
name: user-profile
type: user
---

User: Experienced developer (15 years), learning Claude Code.

**Expertise:** Python, Go, system architecture
**Learning:** Claude Code features (subagents, skills, context management)
**Style:** Prefers detailed explanations with examples
**Current project:** Microservice migration (3 months, 12 phases)
```

---

### 2. Use Specific Memory Files (Not Monoliths)

**Pattern:** Many small focused files > Few large files

**Why:**
- Easier to update/remove
- Can delete stale file without affecting others
- More maintainable

**Structure:**

```bash
# ❌ BAD: One giant file
memory/
└─ everything.md (30k tokens!)

# ✅ GOOD: Focused files
memory/
├─ MEMORY.md (index - under 200 lines)
├─ user_profile.md (1k)
├─ user_preferences.md (500 tokens)
├─ feedback_explicit_subagents.md (300 tokens)
├─ project_migration.md (1.5k)
└─ reference_team_docs.md (800 tokens)
```

---

### 3. Update or Remove Stale Memories

**Memories decay! Keep them current or delete them.**

**Pattern:** Monthly memory audit

```bash
# Every month, review memory files:

# ✅ KEEP: Still relevant
user_preferences.md  # Preferences don't change often
feedback_tdd.md      # Feedback still applies

# 🔄 UPDATE: Partially stale
project_migration.md  
# ← Update status: phase 1 done, phase 2 in progress

# ❌ DELETE: Completed/irrelevant
project_payment_refactor.md  # ← Completed 2 months ago, DELETE!
debugging_session_notes.md   # ← Ephemeral, should never have been saved
```

**How to delete:**
```bash
# Remove the memory file
rm /home/gyr/.claude/projects/.../memory/project_payment_refactor.md

# Update MEMORY.md index (remove the line)
# - [Payment Refactor](project_payment_refactor.md)
```

---

### 4. Avoid Duplicating Information

**One canonical source for each fact**

```bash
# ❌ BAD: Duplication
CLAUDE.md: "Use pytest for tests"
memory/user_preferences.md: "User prefers pytest"
memory/project_standards.md: "Testing with pytest"
# Problem: Same fact in 3 places!

# ✅ GOOD: Single source
CLAUDE.md: "Use pytest for tests"
# (Project-wide rule, belongs in CLAUDE.md)
# Memory files don't duplicate it
```

**Where to put different types of information:**

| Type | Where to Store | Why |
|------|---------------|-----|
| **Project rules** (code style, build commands) | CLAUDE.md | Loaded every session, project-specific |
| **User preferences** (working style) | memory/user_*.md | Personal, across all projects |
| **Feedback** (corrections to Claude) | memory/feedback_*.md | Behavioral guidance |
| **Project status** (current work) | memory/project_*.md | Spans multiple sessions |
| **Implementation details** | Code/docs | Authoritative source |
| **Decisions** (why not how) | Git commits or memory/adr_*.md | Context for future |

---

### 5. Link Related Memories

**Use `[[name]]` syntax to link memories**

```markdown
# memory/project_migration.md
---
name: project-migration
type: project
---

Microservice migration project.

Related: [[project-migration-architecture]] for technical details
Related: [[feedback-explicit-subagents]] for how to invoke subagents during work

Status: Phase 2 in progress
```

**Benefits:**
- Shows relationships
- Easy to find related context
- Can follow links when needed

---

### 6. Use Descriptive Memory Names

**Good names help maintenance**

```bash
# ❌ BAD: Generic names
memory/notes.md
memory/stuff.md
memory/project1.md

# ✅ GOOD: Descriptive names
memory/user_learning_style.md
memory/feedback_explicit_subagents.md
memory/project_microservice_migration.md
memory/reference_team_wiki_locations.md
```

**Naming convention:**
```
{type}_{topic}.md

Types: user, feedback, project, reference
Examples:
- user_profile.md
- feedback_tdd_workflow.md
- project_auth_redesign.md
- reference_api_docs.md
```

---

## How to Maintain Memory

### Monthly Memory Audit Checklist

**Run this every month (or every 50 sessions):**

```bash
# 1. Check total memory size
cd /home/gyr/.claude/projects/.../memory/
wc -w *.md
# Target: <10k words total (<20k tokens)

# 2. Review each file
# For each memory file, ask:

# ✅ Is this still accurate?
# ✅ Is this still needed?
# ✅ Can this be condensed?
# ❌ Is this stale/completed?
# ❌ Is this duplicated elsewhere?
# ❌ Is this too detailed (facts vs details)?

# 3. Delete completed project memories
rm memory/project_<completed>.md

# 4. Update stale information
# Edit files to update current status

# 5. Consolidate if needed
# If you have many small related files, consider merging

# 6. Check MEMORY.md line count
wc -l MEMORY.md
# Must be < 200 lines!
```

---

### How to Ask Claude to Help

**Quarterly cleanup:**

```bash
You: "Audit my memory system and suggest cleanup"

Claude: [Reads all memory files]
        [Identifies issues:]
        
        "Memory audit results:
        
        Total: 18 files, 25k tokens (should be <20k)
        
        ISSUES FOUND:
        
        1. Stale project memories (DELETE):
           - project_payment_refactor.md (completed 3 months ago)
           - project_old_api_migration.md (completed)
        
        2. Too detailed (CONDENSE):
           - user_profile.md (5k tokens, should be 1-2k)
           - project_current_migration.md (4k tokens, too much detail)
        
        3. Duplicates (CONSOLIDATE):
           - feedback_tdd.md and project_tdd_guidelines.md have overlap
        
        4. Should be in CLAUDE.md instead:
           - memory/code_style_rules.md (project-wide rules)
        
        Should I:
        - Delete stale project memories?
        - Condense user_profile.md to key facts?
        - Move code_style_rules to CLAUDE.md?
        "
```

---

### Automated Cleanup Pattern

**Set up periodic reminders:**

```bash
# Using Claude Code's cron feature
# Every 30 days, remind to audit memory

You: "Set up a monthly reminder to audit memory"

Claude: [Creates cron job]
# Every 30 days: "Time to audit memory system"
```

Or use calendar/manual reminders.

---

## Memory Structure

### File Structure

```bash
/home/gyr/.claude/projects/<project-hash>/memory/
├─ MEMORY.md                    # Index (MUST be < 200 lines!)
├─ user_profile.md              # Who you are
├─ user_preferences.md          # How you like to work
├─ feedback_explicit_invocation.md  # Corrections to Claude
├─ feedback_detailed_examples.md    # More feedback
├─ project_migration.md         # Current multi-month project
├─ reference_team_docs.md       # Where things are
└─ reference_external_apis.md   # External system pointers
```

### Memory File Format

**Every memory file must have frontmatter:**

```markdown
---
name: short-kebab-case-slug
description: One-line summary (used to decide relevance)
metadata:
  type: user | feedback | project | reference
---

# Memory Content

{{memory content — facts, not details}}

**Links to related memories:** [[other-memory-name]]
```

### MEMORY.md Index Format

**MEMORY.md is the index (loaded first):**

```markdown
# Project Memory

Quick index of persistent knowledge for this project.

## User Profile
- [User Profile](user_profile.md) — Experienced dev learning Claude Code
- [Preferences](user_preferences.md) — Prefers explicit examples, detailed explanations

## Feedback
- [Explicit Subagent Invocation](feedback_explicit_invocation.md) — Always specify subagent type
- [Detailed Examples](feedback_detailed_examples.md) — Provide comprehensive examples with reasoning

## Current Projects
- [Microservice Migration](project_migration.md) — 12-phase migration, currently phase 2

## References
- [Team Docs](reference_team_docs.md) — Wiki locations, ADR directory
- [External APIs](reference_external_apis.md) — Payment gateway, auth service

---

**Last updated:** 2026-05-12
**Total memories:** 8 files
**Estimated tokens:** ~8k
```

**Critical:** Keep under 200 lines!

---

## Real-World Examples

### Example 1: Healthy Memory System

```bash
# After 6 months of use, healthy memory:

memory/
├─ MEMORY.md (50 lines)
├─ user_profile.md (1k tokens)
├─ user_preferences.md (500 tokens)
├─ feedback_explicit_subagents.md (300 tokens)
├─ feedback_tdd_first.md (200 tokens)
├─ project_migration.md (1.5k tokens)  # Current work
├─ reference_team_wiki.md (600 tokens)
└─ reference_external_systems.md (800 tokens)

Total: 7 files, ~5k tokens
Session start context: ~8% (includes CLAUDE.md + memory)
Status: ✅ HEALTHY!
```

**Why healthy:**
- Under 10 files
- Each file focused and concise
- No stale/completed projects
- Total tokens reasonable
- Session starts with healthy context

---

### Example 2: Memory Rot (Before Cleanup)

```bash
# After 6 months WITHOUT maintenance:

memory/
├─ MEMORY.md (180 lines)  # ⚠️ Near 200-line limit!
├─ user_profile.md (5k tokens)  # 🔴 Too detailed!
├─ user_daily_journal.md (10k tokens)  # 🔴 SHOULD NOT EXIST!
├─ user_preferences.md (500 tokens)
├─ feedback_explicit_subagents.md (300 tokens)
├─ feedback_tdd_first.md (200 tokens)
├─ project_migration.md (4k tokens)  # 🔴 Too much detail!
├─ project_payment_refactor.md (3k tokens)  # 🔴 COMPLETED 3 months ago!
├─ project_inventory_extraction.md (3k tokens)  # 🔴 COMPLETED 2 months ago!
├─ project_auth_redesign.md (2k tokens)  # 🔴 COMPLETED 1 month ago!
├─ project_api_v2.md (2k tokens)  # Current
├─ debugging_notes_april.md (5k tokens)  # 🔴 EPHEMERAL!
├─ debugging_notes_may.md (4k tokens)  # 🔴 EPHEMERAL!
├─ architecture_detailed.md (8k tokens)  # 🔴 Should be in docs!
├─ meeting_notes_q1.md (6k tokens)  # 🔴 EPHEMERAL!
├─ reference_team_wiki.md (600 tokens)
└─ reference_external_systems.md (800 tokens)

Total: 17 files, ~55k tokens  # 🔴 WAY TOO MUCH!
Session start context: ~32%  # 🔴 MEMORY ROT!
Status: 🚨 NEEDS IMMEDIATE CLEANUP!
```

---

### Example 3: After Cleanup

```bash
# Same user, after cleanup:

memory/
├─ MEMORY.md (40 lines)  # ✅ Condensed
├─ user_profile.md (1k tokens)  # ✅ Condensed from 5k
├─ user_preferences.md (500 tokens)
├─ feedback_explicit_subagents.md (300 tokens)
├─ feedback_tdd_first.md (200 tokens)
├─ project_migration.md (1.5k tokens)  # ✅ Condensed, kept current
├─ project_api_v2.md (1.5k tokens)  # ✅ Condensed
├─ reference_team_wiki.md (600 tokens)
└─ reference_external_systems.md (800 tokens)

# DELETED (moved to appropriate places):
# - user_daily_journal.md → DELETED (ephemeral)
# - project_payment_refactor.md → DELETED (completed)
# - project_inventory_extraction.md → DELETED (completed)
# - project_auth_redesign.md → DELETED (completed)
# - debugging_notes_*.md → DELETED (ephemeral, not memory!)
# - meeting_notes_q1.md → DELETED (ephemeral)
# - architecture_detailed.md → MOVED to docs/ARCHITECTURE.md

Total: 9 files, ~6.5k tokens  # ✅ HEALTHY!
Session start context: ~10%  # ✅ GOOD!
Status: ✅ CLEANED UP!
```

**Cleanup actions taken:**
1. ✅ Deleted 5 completed project memories
2. ✅ Deleted 3 ephemeral/debugging files (never should have been memory!)
3. ✅ Moved architecture details to docs/
4. ✅ Condensed user_profile from 5k to 1k tokens
5. ✅ Condensed project memories to facts only
6. ✅ Updated MEMORY.md index

**Result:** Dropped from 55k to 6.5k tokens (88% reduction!)

---

## Troubleshooting Memory Issues

### Issue 1: Sessions Start with High Context

**Symptoms:**
- New session context immediately at 15-25%
- Should be ~5-10%

**Diagnosis:**
```bash
# Check memory size
cd /home/gyr/.claude/projects/.../memory/
du -sh .
wc -w *.md

# If >20k words (40k tokens):
# → You have memory bloat!
```

**Fix:**
```bash
# Ask Claude to audit
You: "Audit my memory system - sessions are starting at 20% context"

# Claude will identify issues and suggest cleanup
```

---

### Issue 2: MEMORY.md Over 200 Lines

**Symptoms:**
- MEMORY.md approaching or exceeding 200 lines
- Some memories not being loaded

**Diagnosis:**
```bash
wc -l memory/MEMORY.md
# If >180: Warning
# If >200: Some memories truncated!
```

**Fix:**
- Delete stale memory files
- Consolidate related memories
- Keep MEMORY.md index to title only (no descriptions)

---

### Issue 3: Contradictory Memories

**Symptoms:**
- Claude gives inconsistent responses
- Seems confused about preferences

**Diagnosis:**
- Multiple memory files with conflicting information

**Fix:**
```bash
# Ask Claude to check for conflicts
You: "Check my memory files for contradictory information"

# Claude will identify conflicts and suggest resolution
```

---

### Issue 4: Stale Information

**Symptoms:**
- Claude references completed projects
- Mentions old deadlines
- Uses outdated preferences

**Diagnosis:**
- Memory files not updated/removed

**Fix:**
```bash
# Ask Claude to identify stale memories
You: "Check which project memories are stale or completed"

# Delete or update identified files
```

---

## Summary

### The Core Principles

1. **Memory can rot, just like context**
   - Too much memory → sessions start with high context
   - Stale memory → incorrect assumptions
   - Duplicated memory → wasted tokens

2. **Keep memory small and current**
   - Target: <10 files, <20k tokens total
   - Each file: 1-2k tokens
   - MEMORY.md: <200 lines (hard limit)

3. **Save facts, not details**
   - User preferences: Yes
   - Project status: High-level only
   - Implementation details: No (read code instead)
   - Ephemeral states: No

4. **Maintain regularly**
   - Monthly audit recommended
   - Delete completed project memories
   - Update stale information
   - Condense overly detailed files

5. **One canonical source**
   - Don't duplicate CLAUDE.md in memory
   - Don't duplicate code details in memory
   - Don't duplicate docs in memory

### Quick Reference

**Memory Hygiene Checklist:**

- [ ] Memory files total <20k tokens
- [ ] Each file <2k tokens
- [ ] MEMORY.md <200 lines
- [ ] No completed project memories
- [ ] No ephemeral/debugging notes
- [ ] No code/architecture details (belongs in docs)
- [ ] No duplicates of CLAUDE.md content
- [ ] Monthly cleanup scheduled

**Warning Signs:**

- 🚨 Sessions start >15% context
- 🚨 MEMORY.md >180 lines
- 🚨 Total memory >30k tokens
- 🚨 Claude references completed projects
- 🚨 Contradictory responses

**Emergency Cleanup:**

```bash
# If memory is out of control:
1. Delete all completed project memories
2. Delete any debugging/meeting notes
3. Move architecture details to docs/
4. Condense user profile to key facts only
5. Ask Claude to audit and suggest further cleanup
```

---

## Additional Resources

**Related guides:**
- **CONTEXT_MANAGEMENT_GUIDE.md** - Prevent context rot (similar concepts)
- **USAGE_GUIDE.md** - When to use Skills vs Subagents vs Commands
- **TOKEN_OPTIMIZATION_GUIDE.md** - Reduce token usage
- **DOCUMENTATION_STRATEGY.md** - When to create docs vs memory

**Key insight:**

> Memory is for **facts that persist**, not **details that change**.
> If it can be read from code/docs/git, don't save it to memory.
> If it will be stale in a month, don't save it to memory.
> If it's not useful in future sessions, don't save it to memory.
