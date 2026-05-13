# Claude Code Professional Development Squad

**A production-ready setup following official Anthropic guidelines for professional AI-assisted development**

This project provides a complete, officially-compliant Claude Code configuration with Skills, proper context management, and TDD workflows. Perfect for developers moving beyond basic Claude Code chat to professional, structured AI-assisted development.

## 🎯 What This Provides

✅ **CLAUDE.md** - Persistent project context (TDD rules, code style, build commands)  
✅ **5 Professional Skills** - TDD, Code Review, Security Audit, Performance, Architecture  
✅ **Context Management** - Official strategies to prevent context rot  
✅ **Usage Guides** - When to use Skills vs Subagents vs /clear  
✅ **No Custom Agents** - Uses built-in Explore, Plan, general-purpose agents

## 🚀 Quick Start

### 1. Installation

This configuration is ready to use:

```bash
# The setup is already in place
# CLAUDE.md, skills/, and guides are configured

# Start Claude Code in this directory
claude
```

### 2. First Steps

```bash
# Check what's configured
/skills       # Browse available skills
/context      # Check context usage

# Try a skill
/tdd          # Launch TDD workflow
/code-review  # Review recent changes
```

### 3. Read the Guides

**Start here:**
1. **USAGE_GUIDE.md** - When to use Skills vs Subagents vs Commands
2. **CONTEXT_MANAGEMENT_GUIDE.md** - How to prevent context rot
3. **CLAUDE.md** - Project conventions and TDD rules

## 📚 Skills Available

### `/tdd` - Test-Driven Development

Enforces strict Red-Green-Refactor cycle:
- Write failing test → minimal code → refactor
- Prevents production code without tests
- Adversarial testing mindset

**Usage:**
```
Implement email validation using TDD
[Automatically uses /tdd skill]
```

### `/code-review` - Code Quality Audit

Comprehensive review checklist:
- Logic audit (off-by-one, race conditions)
- Readability & maintainability
- Security review
- Performance analysis
- Test quality

**Usage:**
```
/code-review
# Or automatically:
Review my auth changes
```

### `/security-audit` - Vulnerability Scan

OWASP Top 10 security checks:
- Injection vulnerabilities (SQL, XSS, command)
- Hardcoded secrets detection
- Auth/authorization flaws
- Crypto weaknesses

**Usage:**
```
/security-audit
# Or:
Check for security issues in the auth module
```

### `/performance-check` - Performance Analysis

Data-driven optimization:
- Algorithmic complexity analysis (Big-O)
- Profiling-based bottleneck identification
- Evidence-based optimization suggestions
- Before/after measurements

**Usage:**
```
The search is slow with 10k users
[Automatically uses performance-check]
```

### `/plan-architecture` - System Design

Architecture planning with SOLID principles:
- Contract-first interface design
- Component dependency mapping
- Test strategy definition
- Implementation plan creation

**Usage:**
```
/plan-architecture
# Then describe feature:
Design OAuth login integration
```

## 🎓 Learning Path

### For Beginners

1. **Read USAGE_GUIDE.md** - Understand when to use each feature
2. **Try one skill** - Start with `/tdd` for a simple feature
3. **Monitor context** - Use `/context` after every 10 turns
4. **Practice /clear** - Reset context between unrelated tasks

### For Intermediate Users

1. **Read CONTEXT_MANAGEMENT_GUIDE.md** - Deep dive into context rot prevention
2. **Use subagents** - Delegate research to keep main context clean
3. **Customize CLAUDE.md** - Add project-specific rules
4. **Create custom skills** - Build your own reusable workflows

### For Advanced Users

1. **Optimize workflow** - Combine skills, subagents, and commands (see TOKEN_OPTIMIZATION_GUIDE.md)
2. **Create custom skills** - Build reusable workflows for your team
3. **Set up hooks** - Automate checks and validations
4. **Configure permissions** - Use auto mode for uninterrupted flow

## 🔧 Configuration

### CLAUDE.md Structure

```markdown
# Claude Code Squad - TDD Development Environment

## Code Style & Standards
- Naming conventions
- Function size guidelines
- Error handling standards

## Test-Driven Development (TDD) Workflow
- Red-Green-Refactor cycle
- Testing commands

## Build & Development Commands
- Install, lint, format, test commands

## Architecture Principles
- SOLID principles
- Design patterns

## Security Standards
- No hardcoded secrets
- Input validation rules

## Git Workflow
- Branch naming
- Commit message format

## Compact Instructions
- What to preserve during auto-compaction
```

### Skills Structure

```
skills/
├── tdd/
│   └── SKILL.md
├── code-review/
│   └── SKILL.md
├── security-audit/
│   └── SKILL.md
├── performance-check/
│   └── SKILL.md
└── plan-architecture/
    └── SKILL.md
```

Each skill has:
- **YAML frontmatter** - name, description, when_to_use
- **Markdown content** - Step-by-step instructions
- **Automatic invocation** - Claude uses when relevant
- **Manual invocation** - `/skill-name`

## 📖 Documentation

### Core Guides

| Guide | Purpose | When to Read |
|:------|:--------|:-------------|
| **USAGE_GUIDE.md** | When to use Skills vs Subagents vs Commands | First (essential) |
| **CONTEXT_MANAGEMENT_GUIDE.md** | How to prevent context rot | Second (essential) |
| **TOKEN_OPTIMIZATION_GUIDE.md** | Reduce token usage, how to invoke subagents | Third (essential) |
| **MEMORY_MANAGEMENT_GUIDE.md** | Use persistent memory, prevent memory rot | Fourth (before saving to memory) |
| **DOCUMENTATION_STRATEGY.md** | When to create docs vs work from conversation | Fifth (multi-session projects) |
| **CLAUDE.md** | Project conventions and TDD rules | Reference |

### Skills Documentation

Each skill contains:
- Purpose and usage guidelines
- Step-by-step procedures
- Best practices
- Output format expectations

Read the SKILL.md files in `skills/` to understand what each does.

## 🏗️ Architecture

### How It Works Together

```
┌─────────────────────────────────────────────────────┐
│                   Every Session                     │
│  ┌─────────────┐                                    │
│  │ CLAUDE.md   │ ← Loaded automatically             │
│  └─────────────┘   (Persistent rules)               │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│                  When Needed                        │
│  ┌─────────────┐                                    │
│  │ Skills      │ ← Loaded on demand                 │
│  └─────────────┘   (TDD, review, security, etc.)    │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│              For Isolated Work                      │
│  ┌─────────────┐                                    │
│  │ Subagents   │ ← Separate context window          │
│  └─────────────┘   (Explore, Plan, general-purpose) │
└─────────────────────────────────────────────────────┘
```

### Context Flow

```
Session Start:
├─ Load CLAUDE.md (3KB)
├─ Load skill descriptions (3KB)
└─ Available context: 94% (188KB of 200KB)

When /tdd invoked:
├─ Load TDD skill content (15KB)
└─ Available context: 86% (173KB of 200KB)

After 15 turns (context 70%):
├─ Use /compact or /clear
└─ Maintain high quality

For research (many file reads):
├─ Spawn Explore subagent
├─ Research in separate context
└─ Main context gets only summary (0.5%)
```

## 🛠️ Common Workflows

### Workflow 1: Implement Feature with TDD

```bash
# 1. Describe feature
"Implement email validation using TDD"

# 2. Claude uses /tdd skill automatically
# - Writes failing test
# - Implements minimal code
# - Refactors while tests stay green

# 3. Review security
/security-audit

# 4. Commit
git add src/ tests/
git commit -m "feat(auth): add email validation"
```

### Workflow 2: Fix Performance Issue

```bash
# 1. Describe problem
"User search is slow with 10k users"

# 2. Claude uses /performance-check automatically
# - Profiles code
# - Identifies O(n²) bottleneck
# - Suggests O(n) fix
# - Measures improvement

# 3. Verify correctness
pytest tests/test_search.py

# 4. Review changes
/code-review
```

### Workflow 3: Plan & Implement Architecture

```bash
# 1. Plan architecture
/plan-architecture
"Design OAuth login integration"

# 2. Claude creates IMPLEMENTATION_PLAN.md
# - Component structure
# - Interface definitions
# - Test strategy
# - Implementation order

# 3. Review plan, then implement
"Looks good, implement phase 1 using TDD"

# 4. Claude uses /tdd for implementation
```

### Workflow 4: Research & Context Management

```bash
# 1. Research with subagent (keeps main context clean)
"Use a subagent to find all auth-related files"
[Subagent reads 50 files in its own context]
[Returns summary to main context]

# 2. Check context usage
/context
# Output: 35% (research summary only, not 50 file reads!)

# 3. Implement based on research
"Based on that research, add session timeout"

# 4. Between tasks, clear context
/clear
```

## 🔄 Context Management

### The 60% Rule

**Best practice:** Compact or clear at 60% context usage, NOT at 90%.

**Why:** At 60%, Claude has full access to all context. Summary is high quality. At 90%, Claude is already working with degraded context.

### Commands

```bash
/context                        # Check current usage
/clear                          # Reset between unrelated tasks
/compact                        # Manual compaction
/compact <freeform instructions># Tell Claude what to preserve
/btw <question>                 # Side question (doesn't enter context)
```

### Monitoring

```bash
# Set up context in status line
/statusline
# Select "Context percentage"

# Now you see:
┌─────────────────────────────────────┐
│ Sonnet 4.5 | 73% context | 12:34 PM │
└─────────────────────────────────────┘
```

**Color guide:**
- 🟢 0-50%: Healthy
- 🟡 50-75%: Monitor
- 🟠 75-90%: Consider action
- 🔴 90-100%: Context rot risk

## ❓ FAQ

### Q: Should I always use TDD?

**A:** Use `/tdd` for:
- New features
- Bug fixes
- Critical logic

Skip for:
- Config changes
- Documentation
- Simple one-liners

### Q: When do I use Skills vs Subagents?

**Skills:**
- Reusable procedures (TDD workflow, review checklist)
- Load on demand into main context

**Subagents:**
- Research reading many files
- Isolated experiments
- Separate context window

See **USAGE_GUIDE.md** for detailed decision tree.

### Q: What's the difference between Plan Mode and Plan Subagent?

**Plan Mode** (`Shift+Tab` twice):
- Main session enters planning mode
- Exploration in main context
- Interactive approval step
- Seamless plan→implement in same session
- Use when context <50%

**Plan Subagent** (`"Use a Plan subagent to..."`):
- Separate agent in own context
- Returns summary to main (~2k tokens)
- Keeps main context clean
- Use when context >50% or heavy research needed

See **USAGE_GUIDE.md** section "Plan Mode vs Plan Subagent" for detailed comparison with examples.

### Q: How do I prevent context rot?

1. Use `/context` every 10 turns
2. `/clear` between unrelated tasks
3. Put persistent rules in CLAUDE.md
4. Use subagents for high-file-read research
5. Compact at 60%, not 90%

See **CONTEXT_MANAGEMENT_GUIDE.md** for complete guide.

### Q: Can I create my own skills?

**Yes!** Create `.claude/skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: What it does and when to use
---

# Step-by-step instructions
1. Do this
2. Then this
```

### Q: What's wrong with my old "agents"?

They weren't actually agents:
- ❌ No proper frontmatter
- ❌ Wrong tool names
- ❌ Loaded always (not on-demand)
- ❌ Should have been Skills, not agents

This refactor fixes all that following official guidelines.

## 📊 What Changed from Old Setup

### Before (Your Old Approach)

```
❌ 8 "agents" (not actually agents)
❌ Always loaded (80KB context)
❌ Sequential pipeline (waterfall)
❌ Wrong invocation (@agent syntax)
❌ No context management
❌ Custom agents overlapping with built-in
```

### After (Official Approach)

```
✅ 5 Skills (load on demand)
✅ 3KB descriptions loaded, 15KB per skill when used
✅ Flexible workflows (not rigid pipeline)
✅ Automatic + manual invocation
✅ Built-in context management
✅ Uses official Explore, Plan, general-purpose agents
```

## 🎓 Learning Resources

### Official Anthropic Documentation

- [How Claude Code Works](https://code.claude.com/docs/en/how-claude-code-works)
- [Best Practices](https://code.claude.com/docs/en/best-practices)
- [Skills Guide](https://code.claude.com/docs/en/skills)
- [Subagents Guide](https://code.claude.com/docs/en/sub-agents)
- [Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)

### This Project's Guides

1. **USAGE_GUIDE.md** - When to use what
2. **CONTEXT_MANAGEMENT_GUIDE.md** - Prevent context rot
3. **CLAUDE.md** - Project conventions

## 🤝 Contributing

Improve this setup:

1. **Add skills** - Create new workflows in `skills/`
2. **Enhance CLAUDE.md** - Add project-specific rules
3. **Share learnings** - Document what works for your team
4. **Report issues** - If something doesn't follow official guidelines

## 📝 License

This configuration is provided as-is for educational purposes. Customize freely for your projects.

---

**Ready to get started?**

1. Read **USAGE_GUIDE.md**
2. Try `/tdd` with a simple feature
3. Monitor context with `/context`
4. Check **CONTEXT_MANAGEMENT_GUIDE.md** after first session

**Questions?** All documentation is in this repository. Start with the guides!
