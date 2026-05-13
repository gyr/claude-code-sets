# Learning Path - From Chat to Professional Claude Code

**Structured learning plan for mastering Claude Code's official features**

This guide provides a day-by-day, week-by-week progression from basic Claude Code chat to professional AI-assisted development using Skills, Subagents, and context management.

---

## 📅 Day 1: Foundations (1-2 hours)

### Morning: Understand the Landscape

**Read (45 minutes):**
1. `USAGE_GUIDE.md` - Focus on:
   - Quick Decision Tree (page 1)
   - CLAUDE.md section
   - Skills section
   - Skip subagents for now

2. `README.md` - Quick Start section

**Goal:** Understand WHAT each feature is (don't worry about WHEN to use yet)

### Afternoon: First Hands-On (30 minutes)

**Try this in order:**

```bash
# 1. Start Claude Code
cd /home/gyr/.gyr.d/gyr-data/work/tmp/claude_v2
claude

# 2. Check what's available
/skills
# You should see: tdd, code-review, security-audit, performance-check, plan-architecture

# 3. Check context usage
/context
# Should be low (5-10%) at start

# 4. Read CLAUDE.md rules
"What are the TDD rules for this project?"
# Claude will reference CLAUDE.md automatically
```

**Expected outcome:** You understand Claude has access to project rules (CLAUDE.md) and procedures (Skills)

### Evening: First Skill Usage (30 minutes)

**Try the TDD skill:**

```bash
# Create a simple function using TDD
"Implement a function called `add_numbers(a, b)` that adds two numbers, using TDD"

# Observe how Claude:
# 1. Writes failing test first (RED)
# 2. Implements minimal code (GREEN)
# 3. Refactors (REFACTOR)
```

**Expected outcome:** See TDD workflow in action

### Day 1 Checklist

- [ ] Read USAGE_GUIDE.md (at least CLAUDE.md and Skills sections)
- [ ] Read README.md Quick Start
- [ ] Used `/skills` command
- [ ] Used `/context` command
- [ ] Tried `/tdd` skill with simple function
- [ ] Observed Red-Green-Refactor cycle

**Time investment:** 1-2 hours  
**Skill level after:** Beginner (can use basic features)

---

## 📅 Day 2: Context Management (1-2 hours)

### Morning: The Context Problem (45 minutes)

**Read:**
1. `CONTEXT_MANAGEMENT_GUIDE.md` - Focus on:
   - "What is Context Rot?" section
   - "Why It Happens" section
   - Skip the deep technical parts for now

**Goal:** Understand WHY context management matters

### Afternoon: Practice Context Monitoring (45 minutes)

**Exercise 1: Watch Context Fill**

```bash
# 1. Start fresh session
claude

# 2. Check initial context
/context
# Note the percentage (probably 5-10%)

# 3. Do several tasks WITHOUT clearing
"Read all files in src/"
/context
# Note increase (maybe 20-30%)

"Implement a new feature X"
/context
# Note increase (maybe 40-50%)

"Review the code"
/context
# Note increase (maybe 60-70%)

# 4. Notice quality degradation?
# If context >70%, answers may be less precise
```

**Exercise 2: Practice /clear**

```bash
# 5. Clear context
/clear

# 6. Check context again
/context
# Should be back to 5-10%

# 7. Continue with fresh context
"Now implement feature Y"
# Notice higher quality responses?
```

**Expected outcome:** You can monitor context and use /clear

### Evening: The 60% Rule (30 minutes)

**Practice:**

```bash
# Work until context hits 60%
# Then BEFORE continuing:

/compact Preserve architecture decisions and test commands

# Or if switching to unrelated task:
/clear

# Then continue working
```

**Note:** The text after `/compact` is freeform - just describe what to preserve in natural language.

**Expected outcome:** Habit of checking /context every 10 turns

### Day 2 Checklist

- [ ] Read "What is Context Rot?" in CONTEXT_MANAGEMENT_GUIDE.md
- [ ] Watched context percentage increase during work
- [ ] Used `/clear` between unrelated tasks
- [ ] Practiced `/compact` with preservation
- [ ] Understand the 60% rule (compact/clear BEFORE 90%)

**Time investment:** 1-2 hours  
**Skill level after:** Can manage basic context

---

## 📅 Day 3: More Skills (1-2 hours)

### Morning: Code Review Skill (45 minutes)

**Make some changes, then review:**

```bash
# 1. Implement a feature
"Add input validation to the login function"

# 2. Review it
/code-review

# Observe output:
# - Critical issues
# - Warnings
# - Suggestions
```

**Expected outcome:** Understand code review checklist

### Afternoon: Security Audit (45 minutes)

```bash
# 1. Implement something with user input
"Add a search endpoint that takes user query parameter"

# 2. Audit it
/security-audit

# Observe:
# - SQL injection checks
# - XSS checks
# - Input validation checks
```

**Expected outcome:** Understand security checklist

### Evening: Performance Check (30 minutes)

```bash
# 1. Implement something with a loop
"Write a function that searches through a list of 1000 users"

# 2. Check performance
/performance-check

# Observe:
# - Big-O analysis
# - Optimization suggestions
# - Profiling recommendations
```

**Expected outcome:** Understand performance analysis

### Day 3 Checklist

- [ ] Used `/code-review` skill
- [ ] Used `/security-audit` skill
- [ ] Used `/performance-check` skill
- [ ] Understand what each skill checks for
- [ ] Can invoke manually or let Claude decide

**Time investment:** 1-2 hours  
**Skill level after:** Can use all basic skills

---

## 📅 Week 1: Integrate Into Workflow (5-7 hours)

### Day 4-5: Real Feature Development (3 hours)

**Pick a real feature to implement:**

```bash
# Day 4: Plan and Test
/plan-architecture
"Design a user registration system with email validation"

# Review plan, then:
"Implement the email validation part using TDD"
# Uses /tdd automatically

# Day 5: Complete and Review
"Implement the password hashing"
# Uses /tdd

"Review the entire registration system"
# Uses /code-review

"Audit for security issues"
# Uses /security-audit
```

**Practice:**
- Monitor context with `/context` every ~10 turns
- Use `/clear` between major phases
- Use `/compact` if context hits 60%

**Expected outcome:** Complete feature using multiple skills

### Day 6-7: Subagents Introduction (2-4 hours)

**Read:**
- `USAGE_GUIDE.md` - Built-in Subagents section
- `CONTEXT_MANAGEMENT_GUIDE.md` - Subagents for research section
- `TOKEN_OPTIMIZATION_GUIDE.md` - Section "How to Invoke Each Subagent Type" (comprehensive invocation guide)

**Key learning:** Use natural language like `"Use an Explore subagent to [task]"`. No `@` syntax, no `/` commands.

**Try built-in Explore subagent:**

```bash
# Exercise: Research without bloating context
"Use a subagent to find all files that handle user authentication"

# Check context after
/context
# Should show minimal increase (just summary, not all file reads)
```

**Compare with direct approach:**

```bash
/clear  # Start fresh

# DON'T use subagent
"Find all files that handle user authentication"

/context
# Much higher increase (all file reads in context)
```

**Expected outcome:** Understand when to use subagents

### Week 1 Checklist

- [ ] Implemented complete feature using TDD
- [ ] Used code-review on real code
- [ ] Used security-audit on real code
- [ ] Used performance-check on real code
- [ ] Practiced context management throughout
- [ ] Tried built-in Explore subagent
- [ ] Compared context usage with/without subagent

**Time investment:** 5-7 hours  
**Skill level after:** Competent with basic workflow

---

## 📅 Week 2: Advanced Patterns (5-7 hours)

### Day 8-9: Advanced Context Management (3 hours)

**Read:**
- Complete `CONTEXT_MANAGEMENT_GUIDE.md`
- Focus on "Troubleshooting" and "Context Management Strategies"

**Practice Context Strategies:**

```bash
# Strategy 1: Task Isolation
[Work on Feature A - 10 turns, 65% context]
/clear
[Work on Feature B - fresh start]

# Strategy 2: Checkpointing
[Implement auth - 15 turns]
git commit -m "WIP: auth implementation"
/clear
"Continue auth. Read latest commit to see progress. Add session management."

# Strategy 3: Subagent Research Pattern
"Use a subagent to research database connection patterns"
[Summary returned]
"Based on that research, implement connection pooling"
[Clean context for implementation]
```

**Expected outcome:** Master context management strategies

### Day 10-11: Customization (2-3 hours)

**Customize CLAUDE.md for your project:**

```markdown
# Add to CLAUDE.md:

## Database
- Use PostgreSQL, not MySQL
- Connection pool size: 10
- Run migrations: npm run db:migrate

## API Standards
- RESTful naming: /api/v1/resources
- Use camelCase for JSON
- Always include pagination

## Testing
- Unit tests: jest
- Integration tests: supertest
- E2E tests: cypress
- Run: npm test -- --watch
```

**Create a custom skill:**

```bash
# Example: Create deployment skill
mkdir -p ~/.claude/skills/deploy
```

```markdown
# ~/.claude/skills/deploy/SKILL.md
---
name: deploy
description: Deploy to production with safety checks
disable-model-invocation: true
allowed-tools: Bash(git push *), Bash(npm run deploy)
---

# Production Deployment

1. Run full test suite
2. Check for uncommitted changes
3. Build for production
4. Deploy
5. Verify deployment
6. Monitor for 5 minutes
```

**Expected outcome:** Can customize for your project

### Day 12-14: Mastery Practice (2 hours)

**Complete workflow challenge:**

```bash
# Challenge: Implement complete feature with all best practices

# 1. Research phase (use subagent)
"Use a subagent to research how we handle API authentication"

# 2. Plan phase
/plan-architecture
"Design rate limiting for API endpoints"

# 3. Implement phase (TDD)
"Implement rate limiting using TDD"

# 4. Review phase
/code-review
/security-audit
/performance-check

# 5. Context management
# - Check /context after each phase
# - /compact at 60%
# - /clear between major phases

# 6. Commit
git add .
git commit -m "feat(api): add rate limiting to endpoints"
```

**Expected outcome:** Fluent with complete workflow

### Week 2 Checklist

- [ ] Read complete CONTEXT_MANAGEMENT_GUIDE.md
- [ ] Practiced all 3 context management strategies
- [ ] Customized CLAUDE.md for your project
- [ ] Created at least one custom skill
- [ ] Completed full feature with all best practices
- [ ] Context management is now habitual

**Time investment:** 5-7 hours  
**Skill level after:** Advanced user

---

## 📅 Month 1+: Professional Mastery

### Week 3-4: Advanced Features

**Learn advanced patterns:**

1. **Plan Mode:**
   ```bash
   # Shift+Tab twice to enter plan mode
   # Claude explores without making changes
   # Review plan, exit plan mode
   # Then implement
   ```
   
   **Note:** Plan Mode is different from Plan Subagent!
   - **Plan Mode** (Shift+Tab): Main session planning, use when context <50%
   - **Plan Subagent** ("Use a Plan subagent..."): Separate context, use when context >50%
   - See USAGE_GUIDE.md "Plan Mode vs Plan Subagent" for full comparison

2. **Hooks (if needed):**
   ```bash
   /hooks
   # Automate linting after edits
   # Block writes to certain directories
   ```

3. **MCP Servers (if needed):**
   ```bash
   claude mcp add
   # Connect to external services
   # Notion, Figma, databases, etc.
   ```

4. **Multiple Sessions:**
   ```bash
   # Use worktrees for parallel work
   # Use /resume to continue sessions
   # Use /branch to fork sessions
   ```

### Ongoing: Teach Others

**Best way to solidify knowledge:**
- Show teammates your workflow
- Document team-specific patterns
- Create project-specific skills
- Share context management tips

---

## 🎯 Skill Milestones

### Beginner (After Day 3)
- ✅ Can use basic skills (/tdd, /code-review)
- ✅ Understand CLAUDE.md
- ✅ Can check context with /context
- ✅ Know when to /clear

### Intermediate (After Week 1)
- ✅ Use all 5 skills effectively
- ✅ Use subagents for research
- ✅ Practice 60% rule
- ✅ Monitor context habitually
- ✅ Complete features using multiple skills

### Advanced (After Week 2)
- ✅ Master context management strategies
- ✅ Customize CLAUDE.md
- ✅ Create custom skills
- ✅ Use plan mode
- ✅ Understand when to use each feature

### Expert (Month 1+)
- ✅ Use hooks for automation
- ✅ Connect MCP servers
- ✅ Manage multiple sessions
- ✅ Teach others
- ✅ Create team workflows

---

## 🔄 Daily Habits (After Month 1)

Once mastered, your daily workflow should include:

**Every Session:**
```bash
1. Check /context after every 10 turns
2. /clear between unrelated tasks
3. Let Claude use skills automatically (don't over-invoke)
4. Use subagents for research (reading >10 files)
```

**Every Feature:**
```bash
1. Plan first (use /plan-architecture if complex)
2. Implement with /tdd
3. Review with /code-review
4. Audit with /security-audit (if handling user input)
5. Check performance with /performance-check (if processing data)
```

**Every Week:**
```bash
1. Review CLAUDE.md (still accurate?)
2. Review skills (any to add/remove?)
3. Check context management habits (using 60% rule?)
```

---

## 📚 Reference Quick Links

**Daily Reference:**
- `/skills` - List available skills
- `/context` - Check context usage
- `/clear` - Reset context
- `/compact` - Manual compaction

**Guides:**
- `USAGE_GUIDE.md` - When to use what
- `CONTEXT_MANAGEMENT_GUIDE.md` - How to prevent context rot
- `CLAUDE.md` - Project conventions

**Official Docs:**
- [Best Practices](https://code.claude.com/docs/en/best-practices)
- [How Claude Code Works](https://code.claude.com/docs/en/how-claude-code-works)
- [Skills](https://code.claude.com/docs/en/skills)
- [Subagents](https://code.claude.com/docs/en/sub-agents)

---

## 🎓 Final Tips

**Don't rush:**
- Take 2 weeks to fully absorb this
- It's better to master one skill at a time
- Context management takes practice

**Learn by doing:**
- Reading is 20%, practice is 80%
- Try features on real work, not toy examples
- Make mistakes, learn from them

**Ask for help:**
- Claude can teach you: "How do I use plan mode?"
- Built-in commands guide you: `/help`, `/doctor`
- Guides are always available

**Stay curious:**
- Experiment with workflows
- Find what works for your style
- Share what you learn

---

**You're on your way from chat user to professional AI-assisted developer!** 🚀
