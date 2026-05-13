# Context Management Guide - Preventing Context Rot

**Official Anthropic Guidelines for Maintaining Quality in Long Sessions**

This guide explains what context rot is, why it happens, how to prevent it, and how to manage context effectively using Claude Code's built-in features.

## Table of Contents

1. [What is Context Rot?](#what-is-context-rot)
2. [Why It Happens](#why-it-happens)
3. [Auto-Compaction System](#auto-compaction-system)
4. [Manual Context Management](#manual-context-management)
5. [Monitoring Context Usage](#monitoring-context-usage)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

---

## What is Context Rot?

### Definition

**Context rot** is the degradation of AI model performance as the context window fills with old code, failed experiments, debug loops, and outdated instructions.

### Symptoms

You'll notice context rot when Claude starts:
- ❌ Forgetting earlier instructions
- ❌ Making mistakes it didn't make before
- ❌ Hallucinating (making up facts about your code)
- ❌ Repeating failed approaches
- ❌ Giving generic answers instead of specific solutions
- ❌ Not following CLAUDE.md rules it previously followed

### Example

**Turn 1-5 (Fresh Context):**
```
User: Fix the auth bug
Claude: [Reads code, identifies issue, fixes correctly]
        ✅ High quality, accurate
```

**Turn 15-20 (70% Context Full):**
```
User: Add logging to the payment flow
Claude: [Vague response, misses edge cases]
        ⚠️ Quality degrading
```

**Turn 25-30 (90% Context Full):**
```
User: Update the database schema
Claude: [Suggests changes that contradict earlier decisions]
        ❌ Context rot evident
```

---

## Why It Happens

### Technical Reasons

1. **Limited Context Window**
   - Claude 4 Opus: 200K tokens (~150K words)
   - Claude 4 Sonnet: 200K tokens
   - BUT: Effective attention degrades before limit

2. **n² Attention Complexity**
   - Transformer models create pairwise relationships between ALL tokens
   - 100K tokens = 10 billion pairwise relationships
   - Attention becomes diluted across all relationships

3. **Training Data Distribution**
   - Models see less training data with long contexts
   - Fewer "specialized parameters for context-wide dependencies"
   - Performance optimized for shorter contexts

### Practical Reasons

During a typical coding session, context fills with:
- **Conversation history:** All messages exchanged
- **File reads:** Every file Claude reads (full contents)
- **Command outputs:** Test results, git diffs, profiling data
- **Tool calls:** Every Read, Edit, Bash call with results
- **Failed attempts:** Code that didn't work, debugging output

### Example Context Accumulation

```
Turn 1: User message (50 tokens) + CLAUDE.md (500 tokens) = 550 tokens
Turn 2: Read 3 files (5000 tokens) + Response (300 tokens) = 5,850 total
Turn 3: Run tests (2000 tokens) + Response (200 tokens) = 8,050 total
Turn 4: Edit files (1000 tokens) + Response (300 tokens) = 9,350 total
Turn 5: Read error logs (3000 tokens) + Fix (500 tokens) = 12,850 total
...
Turn 15: Context at 45% (90K tokens)
Turn 25: Context at 85% (170K tokens) ⚠️ Quality degrading
Turn 30: Context at 95% (190K tokens) ❌ Context rot severe
```

---

## Auto-Compaction System

### How It Works

Claude Code has a **5-layer compaction pipeline** that runs automatically:

```
Budget Reduction → Snip → Microcompact → Context Collapse → Auto-Compact
    (Layer 1)      (Layer 2)  (Layer 3)      (Layer 4)       (Layer 5)
```

**Triggers:** Automatically at ~95% context capacity

**What it does:**
1. **Clears older tool outputs** first (test results, file reads from 10+ turns ago)
2. **Snips large outputs** to relevant excerpts
3. **Microcompacts** redundant information
4. **Collapses** similar context blocks
5. **Summarizes** conversation history if needed

**What it preserves:**
- ✅ Your requests and questions
- ✅ Recent code snippets
- ✅ Key decisions and architecture choices
- ✅ Active file states
- ✅ CLAUDE.md (reloads after compaction)

**What it may lose:**
- ❌ Detailed instructions from early conversation
- ❌ Failed debugging attempts
- ❌ Old tool outputs
- ❌ Context from abandoned approaches

### Controlling Auto-Compaction

**In CLAUDE.md:**
```markdown
## Compact Instructions

When auto-compaction triggers, preserve:
- List of all modified files with their paths
- Test commands that were run
- Architecture decisions made during the session
- Security considerations identified
- Performance optimization decisions
- Any failing tests and their error messages
```

**Result:** When compaction runs, Claude prioritizes preserving what you specified.

### When Auto-Compaction Fails

**Thrashing:** If a single file/output is so large that context refills immediately after compaction, Claude Code stops auto-compacting after a few attempts and shows an error:

```
Error: Auto-compaction stopped due to thrashing
Context fills immediately after each summary.
Recommendation: /clear and restart with smaller scope
```

**Fix:**
1. `/clear` - Reset context
2. Be more specific in next prompt
3. Use subagents for large file reads

---

## Manual Context Management

### /context - Check Usage

**Command:** `/context`

**Output:**
```
Context Usage
⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁   Sonnet 4.5
⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁   141.9k/200k tokens (71%)  ← MONITOR THIS NUMBER
⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁                                     ↑
⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁                              THE OVERALL %

Estimated usage by category
  System prompt: 6.1k tokens (3.1%)      ← Breakdown (ignore)
  System tools: 18.8k tokens (9.4%)      ← Breakdown (ignore)
  Skills: 618 tokens (0.3%)              ← Breakdown (ignore)
  Messages: 117.9k tokens (59.0%)        ← Breakdown (ignore)
  Free space: 23.6k (11.8%)
  Autocompact buffer: 33k tokens (16.5%)
```

**⚠️ IMPORTANT: Which percentage to monitor?**

Watch the **OVERALL percentage** at the top:
```
141.9k/200k tokens (71%)
                    ↑↑
            THIS NUMBER
```

**Ignore these percentages** (they're just breakdowns):
- System prompt: 3.1%
- System tools: 9.4%
- Messages: 59.0%
- etc.

These breakdown percentages show WHERE your context is going, but the OVERALL percentage (71% in example) is what you need to keep under 60%.

**When to check:**
- After 10-15 turns
- Before starting a new unrelated task
- When noticing quality degradation
- Before complex operations

### /clear - Reset Context

**Command:** `/clear`

**What it does:**
- Completely resets context window
- Starts fresh conversation
- Keeps session history (can /resume later)
- Reloads CLAUDE.md

**When to use:**
```
✅ Between completely unrelated tasks
✅ After debugging session before implementing features
✅ When context >80% and you're starting something new
✅ After quality degradation is noticeable
```

**Example:**
```
[After 20 turns debugging authentication]
User: /context
Output: 85% usage

User: /clear

User: "Now let's add a search feature"
Claude: [Fresh 5% context, high quality]
```

### /compact - Manual Compaction

**Basic Command:** `/compact`

**What it does:**
- Manually trigger compaction (same as auto-compact)
- Summarizes conversation while preserving key info
- More control than auto-compaction

**With Instructions:** `/compact <your instructions>`

Add freeform text after `/compact` to tell Claude what to preserve during compaction.

**Syntax:**
```bash
# Basic (no specific preservation)
/compact

# With preservation instructions (freeform text)
/compact Focus on the API changes
/compact Preserve all architectural decisions and test commands
/compact Keep the database migration details
```

**Important:** 
- The text after `/compact` is freeform - write it naturally
- No special keywords required ("focus", "preserve", "keep" all work the same)
- Just describe what you want preserved

**Examples:**
```bash
# These all work the same way:
/compact Remember the refactor decisions
/compact Keep the security considerations
/compact Don't lose the performance optimization notes
```

**When to use:**
- At ~60% context (BEFORE degradation)
- After completing a major subtask
- When you want to preserve some context but reset the rest

### /btw - Side Questions

**Command:** `/btw <question>`

**What it does:**
- Asks a quick question
- Answer shown in dismissible overlay
- **Answer NEVER enters context**

**When to use:**
```
✅ Quick factual questions
✅ Checking syntax
✅ Understanding existing code
✅ Questions that don't affect current work
```

**Example:**
```
[Working on payment flow implementation]
/btw What's the syntax for Python type hints?

[Overlay shows answer, you dismiss it]
[Context unchanged, continue payment flow work]
```

**DON'T use /btw for:**
```
❌ Questions that affect current task
❌ Decisions that inform next steps
❌ Important architectural discussions
```

---

## Monitoring Context Usage

### ⚠️ Which Percentage Should You Monitor?

When you run `/context`, you see MANY percentages. **Only ONE matters:**

```
141.9k/200k tokens (71%)  ← WATCH THIS
                    ↑↑
            THE OVERALL %
```

**Ignore these (they're just breakdowns):**
- System prompt: 3.1%
- System tools: 9.4%
- Messages: 59.0%
- Skills: 0.3%
- Free space: 11.8%
- Autocompact buffer: 16.5%

**The breakdown percentages** show WHERE your context is going.  
**The overall percentage (71%)** is what you keep under 60%.

**Quick Rule:**
```
/context shows "X/200k tokens (XX%)"
                              ↑↑
                    Keep this under 60%
```

### Context Status in Status Line

**Enable context monitoring:**

1. `/statusline`
2. Select components to show
3. Add "Context percentage"

**Result:**
```
┌─────────────────────────────────────┐
│ Sonnet 4.5 | 73% context | 12:34 PM │
└─────────────────────────────────────┘
```

**Color coding:**
- 🟢 Green (0-50%): Healthy
- 🟡 Yellow (50-75%): Monitor
- 🟠 Orange (75-90%): High usage, consider action
- 🔴 Red (90-100%): Context rot risk, take action

### Automatic Warnings

Claude Code warns you automatically:

**At 75%:**
```
ℹ️ Context usage: 75%
Consider /compact or /clear before next major task
```

**At 90%:**
```
⚠️ Context usage: 90%
Quality may degrade. Recommend /clear for unrelated tasks.
```

**At 95%:**
```
🔴 Context usage: 95%
Auto-compaction will trigger soon.
```

---

## Best Practices

### 1. Intervene Early (60% Rule)

**❌ Bad Practice:**
```
Wait until 90% context full
↓
Quality already degraded
↓
Compaction based on partial context
↓
Lower quality summary
```

**✅ Best Practice:**
```
Compact at 60% context
↓
Claude still has full, uncompressed access
↓
High-quality summary
↓
Maintain quality throughout session
```

**Rule:** When context hits 60%, either `/compact` or `/clear` before next task.

### 2. Use /clear Between Unrelated Tasks

**❌ Bad Practice:**
```
[Debug auth for 15 turns, context 70%]
User: "Add a logging system"
[Claude mixes auth context with logging]
```

**✅ Best Practice:**
```
[Debug auth for 15 turns, context 70%]
User: /clear
User: "Add a logging system"
[Fresh context, no auth debris]
```

**Rule:** If task B doesn't build on task A, `/clear` between them.

### 3. Put Persistent Rules in CLAUDE.md

**❌ Bad Practice:**
```
Turn 1: User: "Always use ES modules, not CommonJS"
Turn 20: [After compaction]
User: "Add a new import"
Claude: Uses CommonJS (instruction was lost)
```

**✅ Best Practice:**
```
# CLAUDE.md
- Use ES modules (import/export), not CommonJS (require)

Turn 1-50: Claude always uses ES modules (never lost)
```

**Rule:** Anything that should ALWAYS apply goes in CLAUDE.md, not conversation.

### 4. Use Subagents for High-Context Operations

**❌ Bad Practice:**
```
User: "Find all files that handle authentication"
Claude: [Reads 50 files, 60K tokens]
Context: 35% → 70% (35% used for single query)
```

**✅ Best Practice:**
```
User: "Use a subagent to find all files that handle authentication"
Subagent: [Reads 50 files in own context]
          [Returns 500-token summary]
Main context: 35% → 36% (only 1% used!)
```

**Rule:** If a task will read >10 files, use a subagent.

**How to invoke:** Use natural language like `"Use an Explore subagent to [task]"`. No `@` syntax needed.  
**Detailed guide:** See **TOKEN_OPTIMIZATION_GUIDE.md** section "How to Invoke Each Subagent Type" for complete examples and all three subagent types (Explore, Plan, general-purpose).

### 5. Regular Context Checks

**Create a habit:**
```
Every 10 turns: /context
If >60%: /compact
If >80%: /clear (if switching tasks)
```

### 6. Skills Over In-Conversation Instructions

**❌ Bad Practice:**
```
Turn 1: User: [Pastes 500-line TDD workflow]
Turn 2-30: TDD workflow stays in context (consuming 15%)
```

**✅ Best Practice:**
```
# skills/tdd/SKILL.md contains workflow

Turn 1: User: "Use TDD"
Claude: [Loads skill only when needed]
Skill unloaded after use: 0% persistent cost
```

**Rule:** Reusable procedures → Skills, not pasted instructions.

### 7. Avoid Debug Loops in Main Context

**❌ Bad Practice:**
```
Turn 1: Try fix A [fails, 5K tokens of output]
Turn 2: Try fix B [fails, 5K tokens of output]
Turn 3: Try fix C [fails, 5K tokens of output]
Context: 30% full of failed attempts
```

**✅ Best Practice:**
```
Option 1: Use subagent for experimental debugging
Option 2: After 2 failed attempts, /clear and try different approach
```

**Rule:** Failed attempts are noise. Don't accumulate them.

---

## Troubleshooting

### Problem: Claude Repeating Failed Approaches

**Symptom:**
```
Turn 5: Try solution A → fails
Turn 10: Try solution B → fails
Turn 15: Try solution A again (already failed!)
```

**Diagnosis:** Context full of contradictory attempts

**Solution:**
```bash
/clear

# Start fresh with better prompt:
"I've tried X and Y, both failed because Z. 
Try a different approach: [specific direction]"
```

### Problem: Claude Forgetting CLAUDE.md Rules

**Symptom:**
```
CLAUDE.md says: "Use pytest, not unittest"
Claude suggests: import unittest
```

**Diagnosis:** 
- CLAUDE.md too long (>200 lines)
- Or context too full (>90%)

**Solution:**
```bash
# Check CLAUDE.md length
wc -l CLAUDE.md

# If >200 lines, trim it
# Keep only essential rules

# Then /compact or /clear
/compact preserve CLAUDE.md rules
```

### Problem: Generic Responses

**Symptom:**
```
User: "Fix the bug in auth.py line 234"
Claude: "To fix bugs, you should debug the code..." [generic advice]
```

**Diagnosis:** Context rot severe (>90%)

**Solution:**
```bash
/clear

# Be very specific:
"Read auth.py lines 230-240. 
The bug is X causes Y. 
Fix it to do Z instead."
```

### Problem: Hallucinations

**Symptom:**
```
Claude: "I see you have a function called validate_token() in utils.py"
Reality: No such function exists
```

**Diagnosis:** Context mixing up information

**Solution:**
```bash
/clear

# Ground Claude with explicit reads:
"Read utils.py and tell me what functions exist"
[Claude reads actual file]
"Now implement validate_token() following patterns in that file"
```

### Problem: Auto-Compaction Thrashing

**Symptom:**
```
Error: Auto-compaction stopped due to thrashing
```

**Diagnosis:** Single file/output too large

**Solution:**
```bash
# Option 1: Clear and restart with focused scope
/clear
"Read only the first 100 lines of large_file.py"

# Option 2: Use subagent
"Use a subagent to analyze large_file.py and summarize its structure"

# Option 3: Split the task
"First understand the file structure"
[Separate session]
"Now modify specific function X"
```

---

## Context Management Strategies

### Strategy 1: Task Isolation

**Principle:** Each major task gets fresh context

```bash
# Task 1: Debug auth
[10 turns, context 65%]
/clear

# Task 2: Add logging
[8 turns, context 45%]
/clear

# Task 3: Optimize performance
[Start fresh]
```

**Result:** Consistent high quality across all tasks

### Strategy 2: Checkpointing

**Principle:** Save progress, clear context, resume

```bash
# Do some work
[15 turns, implement auth]

# Checkpoint
"Create a commit with current changes"
git commit -m "WIP: auth implementation"

# Clear context
/clear

# Resume with focused scope
"Continue auth implementation. 
Read the latest commit to see what's done.
Next step: add session management"
```

### Strategy 3: Subagent Research Pattern

**Principle:** Research in subagent, implement in main

```bash
# Research phase (subagent context)
"Use a subagent to research how we handle database connections"
[Subagent reads many files, returns summary]

# Implementation phase (main context clean)
"Based on that research, implement connection pooling"
[Implement with clean context]
```

**Result:** Research doesn't pollute implementation context

### Strategy 4: Compact at Milestones

**Principle:** Compact after completing subtasks

```bash
# Complete subtask 1
[Implement login, 40% context]
/compact preserve login implementation

# Complete subtask 2
[Implement session handling, 65% context]
/compact preserve login + sessions

# Complete subtask 3
[Implement logout, 80% context]
/compact preserve auth flow summary
```

**Result:** Gradual context cleanup while preserving key decisions

---

## Summary: Context Management Checklist

### Every Session

- [ ] Check `/context` after every 10 turns
- [ ] Use `/clear` between unrelated tasks
- [ ] Put persistent rules in CLAUDE.md (not conversation)
- [ ] Use Skills for reusable procedures
- [ ] Use Subagents for high-file-read tasks

### When Context Hits 60%

- [ ] Decide: Compact or Clear?
- [ ] If compacting: `/compact preserve X`
- [ ] If clearing: Document progress first (commit, notes)

### When Context Hits 80%

- [ ] **Strongly consider /clear** before next task
- [ ] If continuing: Use subagents exclusively for research
- [ ] Monitor quality closely

### When Context Hits 90%

- [ ] **Context rot imminent**
- [ ] `/clear` immediately if switching tasks
- [ ] If must continue: Expect degraded quality

### When Quality Degrades

- [ ] `/clear` immediately
- [ ] Restart with more specific prompt
- [ ] Include what you learned from failed attempts
- [ ] Reference code explicitly (file paths, line numbers)

---

## Official Resources

This guide is based on official Anthropic documentation:

- **[How Claude Code Works - Context Window](https://code.claude.com/docs/en/how-claude-code-works)**
- **[Best Practices for Claude Code - Manage Context](https://code.claude.com/docs/en/best-practices)**
- **[Effective Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)**
- **[What Is Context Rot in Claude Code?](https://www.mindstudio.ai/blog/what-is-context-rot-claude-code)**

---

**Next Steps:**
1. Read `USAGE_GUIDE.md` for when to use Skills vs Subagents
2. Check your current context: `/context`
3. Set up context monitoring in status line: `/statusline`
4. Practice: Try `/clear` between your next two unrelated tasks
