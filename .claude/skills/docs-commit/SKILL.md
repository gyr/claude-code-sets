---
name: docs-commit
description: Final commit of a development cycle — updates the docs the code changes left wrong or incomplete, reviews them, and hands over a staged commit message. Use after the last code commit in a plan, or when asked for the docs commit.
---

# Docs commit

Closes a development cycle. Covers only the docs the cycle's code changes left wrong or
incomplete (README, guides, ADRs, CHANGELOG). Do not audit unrelated docs.

## Standing rules

- **Forward only.** After applying fixes, continue to the next step. Never re-enter an earlier one.
- **`/check-secrets` never self-fixes.** Report and wait; the secret may already be in history.
- **Nothing to update still needs approval.** If no doc is wrong or incomplete, say so and wait rather than skipping silently.
- **Rejected findings are reported.** Apply the findings you judge valid; for the rest, state the finding and why it was not applied.
- **Never run `git commit`.** Stage the change, hand over the message, wait.

## Steps

1. Apply the doc changes directly. No agent.
2. `/check-secrets`. The other gate skills have nothing to act on in markdown.
3. Verify inline: check every claim the changed text makes against the code it
   describes — signatures, examples, described behavior. `@code-reviewer` only
   when the commit adds a new document (ADR, guide, migration doc).
4. Apply valid findings. Behavior-preserving by definition — no tests involved.
5. `/get-diff`, stage, hand over the commit message.
