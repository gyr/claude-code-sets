---
name: dev-cycle
description: Drives one code commit from failing test to handed-over commit message — TDD, gate skills, review agents, full gate, staged diff. Use when starting or continuing a feature, bug fix, or refactor. Governs every code commit in a multi-commit plan.
---

# Development cycle

One pass per commit. In a multi-commit plan these rules govern each commit in turn;
they do not need re-invoking.

## Standing rules

- **Forward only.** After applying fixes, continue to the next step. Never re-enter an earlier one.
- **A gate is not passed until it is green.** Fix what the gate reported and re-run it — that is not backtracking. Fix only what it reported. Two attempts, then stop and report.
- **`/check-secrets` and `/check-deps-cve` never self-fix.** Report and wait; a secret may already be in history, and a CVE is the user's call.
- **Step 6 fixes are unreviewed.** Mechanical only — formatting, annotations, an added test. Anything that changes behavior stops the cycle, since steps 3–4 are behind you.
- **A skipped step needs approval.** If a step has no runner here or does not apply, say which and why, then wait.
- **Rejected findings are reported.** Apply the findings you judge valid; for the rest, state the finding and why it was not applied.
- **Never run `git commit`.** Stage the change, hand over the message, wait.

## Steps

1. `@tdd-coach` drives red → green → refactor.
2. Fast gate, in order: `/run-formatter`, `/run-linter`, `/run-typecheck`, `/run-tests`, `/check-secrets`.
3. `@code-reviewer`.
4. `@security-auditor` — auth, input handling, or sensitive-data work only.
5. Apply valid findings yourself. Do not hand back to `@tdd-coach`.
   - Behavior changes: failing test first, then the fix.
   - Behavior-preserving changes: no new test.
   - Missing-test findings: add the test. If it fails, that is a bug — fix it here.
6. Full gate: everything from step 2, plus `/check-coverage`, plus `/check-deps-cve` if dependencies changed.
7. `/get-diff`, stage, hand over the commit message.

Once the plan's code commits are done, run `/docs-commit` if the cycle left any doc wrong or incomplete.
