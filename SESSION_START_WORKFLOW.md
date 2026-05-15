# Session Start Workflow - CLAUDE.md Compliance

Complete workflow for ensuring Claude reads and follows CLAUDE.md instructions at every session start in any project.

## Background

### How CLAUDE.md Files Work (Official Anthropic Behavior)

**CLAUDE.md files are automatically loaded into Claude's context at session start:**
- `~/.claude/CLAUDE.md` - Global user preferences for all projects
- `./CLAUDE.md` or `./.claude/CLAUDE.md` - Project-specific instructions

**Key points:**
- Files are injected in system-reminder at conversation start
- System tells Claude content "may or may not be relevant to tasks"
- Claude instructed to "not respond to this context unless highly relevant to task"
- Claude can **selectively ignore** CLAUDE.md contents if deemed irrelevant
- **No requirement for proactive acknowledgment** of CLAUDE.md instructions

### How Memory System Works

**Claude's memory system is reactive, not proactive:**
- **Reactive:** Responds when content seems relevant to current task
- **Proactive:** Would automatically execute instructions at session start
- Memory accessed "when memories seem relevant, or user references prior work"
- No automatic session-start triggers

### The Problem

Combining these two behaviors:
1. CLAUDE.md loaded but can be ignored if "not relevant"
2. Memory checked only when "seems relevant"
3. Result: **Mandatory workflow rules (TDD, security, etc.) can be violated** because Claude doesn't proactively confirm and apply them

### The Solution

This workflow makes CLAUDE.md enforcement **explicit and proactive:**
- Memory stores requirement: "check CLAUDE.md at session start"
- **You manually trigger** memory check with prompt
- Claude reads memory → parses CLAUDE.md → confirms constraints
- Work proceeds with compliance verified upfront

**Trade-off:** Manual trigger each session vs. automatic compliance enforcement

---

## One-Time Setup (Per Project)

### Step 1: Add Scope Section to CLAUDE.md

**Update CLAUDE.md with enforcement scope:**

Add this section at top of CLAUDE.md (after title, before Core Development Philosophy):

```markdown
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
```

---

### Step 2: Create Enforcement Memory

**Enter this prompt:**

```
Save feedback memory: CLAUDE.md is default behavior, not optional reference. Follow all standards defined there by default for features, refactors, and bug fixes. Why: User needs consistent quality without auditing every detail. How to apply: Read CLAUDE.md Scope section first, automatically apply TDD cycle, follow git workflow, follow architecture principles, use required skills. Don't wait for explicit "follow CLAUDE.md" prompt.
```

**Verify it was created:**

```
Read feedback_claude_md_enforcement.md from memory and confirm
```

---

### Step 3: Verify CLAUDE.md Files Exist

**Check global CLAUDE.md:**

```
Read ~/.claude/CLAUDE.md and confirm it exists with mandatory workflow instructions
```

**Check project CLAUDE.md:**

```
Read ./CLAUDE.md and confirm it exists with project-specific instructions
```

**If either doesn't exist:**
- Global: `Create ~/.claude/CLAUDE.md with personal development standards`
- Project: `Run /init to create project CLAUDE.md` or create manually

---

## Session Start Routine (Every Session)

**Every time you start a new Claude Code session:**

### Step 1: Trigger Memory Check

**Enter this prompt:**

```
Check memory for session-start requirements and confirm ready
```

**Alternative shorter prompts (any work):**

```
Check memory and confirm
```

```
Memory check - session start
```

```
Session start - load constraints
```

---

### Step 2: Wait for Confirmation

**Claude should respond with:**

```
Memory loaded. CLAUDE.md standards active by default.

Standards apply to: features, refactors, bug fixes, performance work, security changes.
Relaxed for: trivial typos, comment-only changes, docs.

Key constraints:
- TDD: Red-Green-Refactor mandatory for features/fixes
- Git: Follow git workflow from CLAUDE.md
- Security: No hardcoded secrets, input validation
- Architecture: SOLID principles, contract-first design

Ready.
```

---

### Step 3: Proceed with Your Task

Once Claude confirms constraints loaded, give your actual task:

```
[Your actual request - implement feature, fix bug, etc.]
```

---

## Handling Violations

### If Claude Skips Memory Check

If Claude responds to your task without checking memory first:

```
Stop. You didn't check memory for session-start requirements. Read feedback memory about CLAUDE.md mandatory workflow and confirm constraints loaded.
```

### If Claude Violates CLAUDE.md Rule During Work

```
Follow CLAUDE.md standards for this work - they're default behavior, not optional.
```

**Or more specific:**

```
For this feature/refactor/fix, follow all CLAUDE.md standards: follow git workflow, use TDD cycle, apply architecture principles, and required skills. CLAUDE.md defines default behavior, not optional reference.
```

**Example:**
```
You skipped TDD cycle. CLAUDE.md Scope section says TDD mandatory for features/fixes. Start with RED phase - write failing test first.
```

---

## Workflow Summary

### First Time (One-Time Setup)

1. **Add Scope section to CLAUDE.md:**
   - Add Scope and Application section at top of file
   - Defines when standards mandatory vs relaxed
   - Declares CLAUDE.md as default behavior

2. **Create enforcement memory:**
   ```
   Save feedback memory: CLAUDE.md is default behavior, not optional reference. Follow all standards for features/refactors/fixes. Read CLAUDE.md Scope section first, apply TDD/git workflow/architecture automatically.
   ```

3. **Verify creation:**
   ```
   Read feedback_claude_md_enforcement.md from memory and confirm
   ```

4. **Verify CLAUDE.md files exist:**
   ```
   Read ~/.claude/CLAUDE.md and ./CLAUDE.md and confirm they exist
   ```

### Every Session

1. **Start session, enter:**
   ```
   Check memory for session-start requirements and confirm ready
   ```

2. **Wait for Claude to confirm constraints loaded**

3. **Give your task:**
   ```
   [Your actual request]
   ```

---

## Why This Workflow Exists

**Official Behavior:**
- **CLAUDE.md:** Loaded automatically but can be ignored if "not relevant"
- **Memory:** Reactive access when seems relevant to task
- **Result:** No proactive enforcement of mandatory workflow rules

**Your Requirement:**
- CLAUDE.md contains **mandatory** rules (TDD, security, testing)
- Rules must be confirmed and applied **before** starting work
- Violations unacceptable (no tests written, security ignored, etc.)

**This Workflow:**
- Memory stores: "CLAUDE.md is mandatory, confirm at session start"
- You trigger: Manual prompt activates memory check
- Claude confirms: Lists constraints and acknowledges them
- Work proceeds: Full compliance verified upfront

**Benefits:**
1. **Explicit acknowledgment** - Claude states what rules apply
2. **Prevents violations** - Constraints loaded before work starts
3. **You control** - Manual trigger, no automatic behavior
4. **Audit trail** - Clear when constraints were/weren't loaded
5. **Flexible** - Can skip for quick one-off queries if needed

**Trade-off:** Manual prompt each session vs. automatic enforcement

---

## Memory File Template

If you want to manually create or edit enforcement memory:

**File location:** `~/.claude/projects/<project-path>/memory/feedback_claude_md_enforcement.md`

**Content:**
```markdown
---
name: claude-md-enforcement
description: CLAUDE.md is default behavior, not optional reference - follow standards without explicit prompt
metadata:
  type: feedback
---

CLAUDE.md is standing instruction, not reference material. Follow all standards defined there by default for features, refactors, and bug fixes.

**Why:** User needs consistent quality without auditing every detail. Cannot trust code follows architecture principles, TDD workflow, git workflow practices, or code standards unless enforced by default. Requiring explicit "follow CLAUDE.md" every session defeats purpose of having standards document.

**How to apply:**
- Read CLAUDE.md Scope section first - defines when standards mandatory vs relaxed
- For features/refactors/fixes: automatically apply TDD cycle, follow git workflow, follow architecture principles, use required skills
- Don't wait for user to say "follow CLAUDE.md" - it's already loaded as system instruction, treat as default behavior
- Only skip standards for trivial changes (typos, docs) or when user explicitly requests different approach
- When task scope unclear, default to following standards rather than skipping them
```

---

## Quick Reference

### Every New Session - Type This:

```
Check memory for session-start requirements and confirm ready
```

### Every New Project - Type This Once:

```
Save feedback memory: CLAUDE.md is default behavior, not optional reference. Follow all standards for features/refactors/fixes. Read CLAUDE.md Scope section first, apply TDD/git workflow/architecture automatically.
```

---

## Troubleshooting

**Q: Claude says no session-start requirements found**
- Memory file doesn't exist yet
- Run one-time setup Step 1

**Q: Claude confirms but still violates rules later**
- Remind during session: "This violates CLAUDE.md rule [X]. Check memory."
- May need to strengthen memory file language

**Q: Can I automate this with a hook?**
- Yes, but you lose control
- This workflow keeps you in charge of when to enforce

**Q: Do I have to do this every session?**
- Only when you want CLAUDE.md rules strictly enforced
- Skip for quick questions that don't need workflow compliance

**Q: Why not just make CLAUDE.md files stronger?**
- CLAUDE.md already loaded, problem is selective enforcement
- Memory + manual trigger = explicit confirmation protocol
- Shifts from "may be relevant" to "must be acknowledged"
