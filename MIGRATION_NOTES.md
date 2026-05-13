# Migration from Old Setup to Official Anthropic Guidelines

**Date:** 2026-05-12  
**Migration Type:** Complete refactor to follow official Anthropic documentation

## Summary

Migrated from a custom "8-agent squad" that didn't follow official guidelines to a proper Claude Code setup with Skills, CLAUDE.md, and context management following official Anthropic best practices.

## What Changed

### Before (Old Setup)

```
claude_v2/
├── agents/                              # ❌ Wrong structure
│   ├── claude_agents_architect.md       # ❌ No frontmatter
│   ├── claude_agents_builder.md         # ❌ Should be skill
│   ├── claude_agents_documenter.md      # ❌ Should be skill
│   ├── claude_agents_optimizer.md       # ❌ Should be skill
│   ├── claude_agents_README.md
│   ├── claude_agents_researcher.md      # ❌ Use built-in Explore
│   ├── claude_agents_reviewer.md        # ❌ Should be skill
│   ├── claude_agents_security.md        # ❌ Should be skill
│   └── claude_agents_tester.md          # ❌ Should be skill
├── claude_code_squad_README.md          # ❌ Wrong approach
└── skills/                              # Existing skills (kept)
    ├── git-best-practices_SKILL.md
    ├── performance-optimization_SKILL.md
    └── ...
```

**Problems:**
- ❌ Agents missing required YAML frontmatter
- ❌ Wrong tool names (`cat`, `ls` vs `Read`, `Bash`)
- ❌ Should be Skills (on-demand) not Agents (isolated)
- ❌ 8-step waterfall pipeline (not how Claude Code works)
- ❌ No context management guidance
- ❌ Overlapped with built-in agents (Explore, Plan)

### After (New Setup)

```
claude_v2/
├── CLAUDE.md                            # ✅ Persistent project context
├── README.md                            # ✅ Professional documentation
├── USAGE_GUIDE.md                       # ✅ When to use what
├── CONTEXT_MANAGEMENT_GUIDE.md          # ✅ Prevent context rot
├── MIGRATION_NOTES.md                   # ✅ This file
├── skills/                              # ✅ Proper skills with frontmatter
│   ├── tdd/
│   │   └── SKILL.md                     # ✅ Red-Green-Refactor workflow
│   ├── code-review/
│   │   └── SKILL.md                     # ✅ Quality audit checklist
│   ├── security-audit/
│   │   └── SKILL.md                     # ✅ OWASP Top 10 checks
│   ├── performance-check/
│   │   └── SKILL.md                     # ✅ Profile & optimize
│   ├── plan-architecture/
│   │   └── SKILL.md                     # ✅ System design
│   └── (existing skills kept)
└── _archive_old_incorrect_setup/       # ✅ Old files preserved
    ├── agents/
    ├── claude_code_squad_README.md
    └── README_ARCHIVE.md
```

**Improvements:**
- ✅ Proper YAML frontmatter in all skills
- ✅ Correct tool names (Read, Write, Edit, Bash)
- ✅ Skills load on-demand (3KB vs 80KB in context)
- ✅ Flexible workflows (not rigid pipeline)
- ✅ Complete context management guidance
- ✅ Uses official built-in agents (Explore, Plan, general-purpose)

## File Mapping

| Old File | New Implementation | Reason |
|:---------|:-------------------|:-------|
| `claude_agents_tester.md` | `skills/tdd/SKILL.md` | TDD workflow is a skill, not an agent |
| `claude_agents_builder.md` | Part of `CLAUDE.md` + `/tdd` | Build rules in CLAUDE.md, TDD in skill |
| `claude_agents_reviewer.md` | `skills/code-review/SKILL.md` | Review checklist is a skill |
| `claude_agents_optimizer.md` | `skills/performance-check/SKILL.md` | Performance workflow is a skill |
| `claude_agents_security.md` | `skills/security-audit/SKILL.md` | Security checklist is a skill |
| `claude_agents_documenter.md` | Part of `CLAUDE.md` | Doc standards in CLAUDE.md |
| `claude_agents_architect.md` | `skills/plan-architecture/SKILL.md` | Architecture planning is a skill |
| `claude_agents_researcher.md` | **Use built-in `Explore` agent** | Built-in agent already does this |
| `claude_code_squad_README.md` | `README.md` | Complete rewrite with official approach |

## Key Concepts Changed

### 1. Agents → Skills (for most use cases)

**Old thinking:** "Create an agent for each role"  
**New understanding:** "Use skills for procedures, agents for isolation"

**Skills:**
- Load on-demand into main context
- Reusable procedures and checklists
- Cheaper (3KB description vs 15KB full content until used)

**Agents (subagents):**
- Separate context windows
- For research that reads many files
- For isolated experiments
- Use built-in: Explore, Plan, general-purpose

### 2. Sequential Pipeline → Flexible Workflows

**Old approach:** Every task through 8-step waterfall  
**New approach:** Claude decides best workflow per task

**Example - Old Way:**
```
1. @researcher research
2. @architect plan
3. @tester write tests
4. @builder write code
5. @reviewer review
6. @optimizer optimize
7. @security audit
8. @documenter document
```

**Example - New Way:**
```
User: "Implement email validation using TDD"
Claude: [Uses /tdd skill automatically]
        [Red → Green → Refactor in one flow]
        
User: "Review it for security"
Claude: [Uses /security-audit skill]
```

### 3. No Context Management → Official Strategies

**Old setup:** No guidance on context rot  
**New setup:** Complete CONTEXT_MANAGEMENT_GUIDE.md

Key strategies added:
- `/context` to monitor usage
- `/clear` between unrelated tasks
- `/compact` at 60% (not 90%)
- Subagents for high-file-read research
- CLAUDE.md for persistent rules
- Skills for on-demand procedures

## Technical Improvements

### Frontmatter Structure

**Old (missing):**
```markdown
# Architect Agent (@architect)

## Role
You are a Senior Software Architect...
```

**New (correct):**
```yaml
---
name: plan-architecture
description: Design system architecture, define interfaces...
when_to_use: Use before implementing significant features...
allowed-tools: Read, Bash, Grep
---

You are a Senior Software Architect...
```

### Tool Names

**Old (incorrect):**
```
- Use ls, cat, grep
- Use write_file, edit_file
```

**New (correct):**
```
- Use Bash (for ls, grep, etc.)
- Use Read (not cat)
- Use Write, Edit (not write_file, edit_file)
```

### Invocation

**Old (incorrect):**
```bash
@architect "How should I implement..."
```

**New (correct):**
```bash
# Automatic (Claude decides):
"How should I implement OAuth?"
[Claude uses /plan-architecture if needed]

# Manual:
/plan-architecture
```

## Usage Examples

### Example 1: Implement Feature with TDD

**Old way:**
```
1. @researcher "research auth patterns"
2. @architect "design auth system"
3. @tester "write auth tests"
4. @builder "implement auth"
5. @reviewer "review auth"
6. @security "audit auth"
```

**New way:**
```
"Implement OAuth login using TDD"

[Claude automatically:]
1. Uses /plan-architecture to design
2. Uses /tdd for Red-Green-Refactor
3. Uses /security-audit before commit

[You monitor with /context, /clear between tasks]
```

### Example 2: Debug Performance Issue

**Old way:**
```
1. @researcher "find slow code"
2. @optimizer "profile and fix"
3. @tester "verify fix"
```

**New way:**
```
"User search is slow with 10k users"

[Claude automatically:]
1. Uses /performance-check
   - Profiles
   - Identifies O(n²) bottleneck
   - Suggests O(n) fix
   - Measures improvement
2. Runs tests to verify
3. Uses /code-review for final check
```

### Example 3: Research Codebase

**Old way:**
```
@researcher "find all auth files"
[Loads researcher agent, reads files in main context]
[Main context fills with research]
```

**New way:**
```
"Use a subagent to find all auth files"
[Spawns built-in Explore agent]
[Research happens in separate context]
[Main context gets only summary - 0.5% usage]
```

## Breaking Changes

If you had scripts or workflows using the old setup:

### 1. Agent Invocation

**Old:** `@agent-name "prompt"`  
**New:** Let Claude decide, or use `/skill-name`

### 2. File Paths

**Old:** `.claude/agents/claude_agents_*.md`  
**New:** `.claude/skills/*/SKILL.md`

### 3. Workflow Expectations

**Old:** Rigid 8-step pipeline  
**New:** Flexible, task-appropriate workflows

## Migration Checklist

- [x] Created CLAUDE.md with persistent rules
- [x] Converted agents to proper skills
- [x] Created USAGE_GUIDE.md
- [x] Created CONTEXT_MANAGEMENT_GUIDE.md
- [x] Created professional README.md
- [x] Archived old incorrect setup
- [x] Documented migration in this file

## Next Steps

1. **Read the guides:**
   - `USAGE_GUIDE.md` - Understand when to use what
   - `CONTEXT_MANAGEMENT_GUIDE.md` - Learn context management

2. **Try the skills:**
   - `/tdd` for a simple feature
   - `/code-review` on recent changes
   - `/context` to monitor usage

3. **Customize:**
   - Add project-specific rules to `CLAUDE.md`
   - Create custom skills as needed
   - Adjust workflows to your team's needs

4. **Learn gradually:**
   - Start with basic skills
   - Add subagents when needed
   - Master context management over time

## Resources

### Official Anthropic Documentation

- [How Claude Code Works](https://code.claude.com/docs/en/how-claude-code-works)
- [Best Practices](https://code.claude.com/docs/en/best-practices)
- [Skills Guide](https://code.claude.com/docs/en/skills)
- [Subagents Guide](https://code.claude.com/docs/en/sub-agents)
- [Agent Teams](https://code.claude.com/docs/en/agent-teams)
- [Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)

### Project Documentation

- `README.md` - Overview and quick start
- `USAGE_GUIDE.md` - When to use Skills vs Subagents vs Commands
- `CONTEXT_MANAGEMENT_GUIDE.md` - How to prevent context rot
- `CLAUDE.md` - Project conventions and TDD rules

---

**Migration completed:** 2026-05-12  
**Old setup archived in:** `_archive_old_incorrect_setup/`  
**Status:** ✅ Ready for production use
