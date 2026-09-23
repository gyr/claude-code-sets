---
name: dev-cycle
description: Drives one code commit from failing test to handed-over commit message — TDD, gate skills, review agents, full gate, staged diff. Use when starting or continuing a feature, bug fix, or refactor. In a multi-commit plan, invoke once per commit in a fresh session: `/dev-cycle <plan-file> <commit-id>`.
---

# Development cycle

One pass per commit. In a multi-commit plan, one fresh session per commit, started with
`/dev-cycle <plan-file> <commit-id>`. No arguments means no plan: skip the "With a plan"
section and never look for a plan file.

## Standing rules

- **Branch first.** Confirm the work is on a `feature/` / `fix/` / `refactor/` branch before step 1. If it is on the default branch, stop and report.
- **Forward only.** After applying fixes, continue to the next step. Never re-enter an earlier one.
- **A gate is not passed until it is green.** Fix what the gate reported and re-run it — that is not backtracking. Fix only what it reported. Two attempts, then stop and report.
- **A skill re-run with no new output passed unchanged.** A reply like "already loaded … unchanged" means the skill ran and its output matched its previous run. Take that result; never redo the check by hand.
- **`/check-secrets` and `/check-deps-cve` never self-fix.** Report and wait; a secret may already be in history, and a CVE is the user's call.
- **Step 6 fixes are unreviewed.** Mechanical only — formatting, annotations, an added test. Anything that changes behavior stops the cycle, since steps 3–4 are behind you.
- **A skipped step needs approval.** If a step has no runner here or does not apply, say which and why, then wait.
- **Rejected findings are reported.** Apply the findings you judge valid; for the rest, state the finding and why it was not applied.
- **A finding you cannot apply within this pass stops the cycle.** Findings that change the commit's shape — split it, reorder it — are not yours to resolve. State the finding and ask.
- **Never run `git commit`.** Stage the change, hand over the message, wait.
- **The plan decides, not you.** With a plan, the commit's scope, files and message come from its section. Where the plan says which agents review the commit, that replaces steps 3–4; steps 2 and 6 always run. Do not re-plan or reorder; if the commit cannot be built as planned, stop and ask.
- **The plan file is read-only.** Never edit it, stage it, or commit it.

## With a plan

Before step 1:
- Run `git check-ignore -q <plan-file>`. If it is not ignored, stop and report. Do not edit `.gitignore`.
- Read the section for `<commit-id>`. Confirm in `git log` that this commit's message is not there yet and, unless it is the plan's first commit, that the previous commit's message is. If either check fails, stop and report.

After step 7:
- Print the prompt for the next session: `/docs-commit <plan-file> <next-id>` if the next commit's message has type `docs`, otherwise `/dev-cycle <plan-file> <next-id>`. Tell the user to commit, run `/clear`, and paste it.
- If this was the plan's last commit, print no prompt. Ask whether to delete the plan file; never delete it without a yes.

## Steps

1. `@tdd-coach` drives red → green → refactor. It writes the tests and the
   implementation, never docs; you own the code from step 5.
2. Fast gate, in order: `/run-formatter`, `/run-linter`, `/run-typecheck`, `/run-tests`, `/check-secrets`.
3. `@code-reviewer`.
4. `@security-auditor` — auth, input handling, or sensitive-data work only.
5. Apply valid findings yourself. Do not hand back to `@tdd-coach`. Run tests with
   `/run-tests`, never the test command through Bash.
   - Behavior changes: failing test first, then the fix.
   - Behavior-preserving changes: no new test.
   - Missing-test findings: add the test. If it fails, that is a bug — fix it here.
6. Full gate: everything from step 2, plus `/check-coverage`, plus `/check-deps-cve` if dependencies changed.
7. `/get-diff`, stage, hand over the commit message.

Without a plan, run `/docs-commit` afterwards if the change left any doc wrong or incomplete.
