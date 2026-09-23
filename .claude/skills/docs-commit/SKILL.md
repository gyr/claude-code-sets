---
name: docs-commit
description: Final commit of a development cycle — updates the docs the code changes left wrong or incomplete, reviews them, and hands over a staged commit message. Use after the last code commit in a plan, or when asked for the docs commit. In a plan, invoke in a fresh session: `/docs-commit <plan-file> <commit-id>`.
---

# Docs commit

Closes a development cycle. Covers only the docs the cycle's code changes left wrong or
incomplete (README, guides, ADRs, CHANGELOG). Do not audit unrelated docs. With a plan,
the docs to change are the ones its section for `<commit-id>` names. No arguments means
no plan: skip the "With a plan" section and never look for a plan file.

## Standing rules

- **Forward only.** After applying fixes, continue to the next step. Never re-enter an earlier one.
- **A skill re-run with no new output passed unchanged.** A reply like "already loaded … unchanged" means the skill ran and its output matched its previous run. Take that result; never redo the check by hand.
- **`/check-secrets` never self-fixes.** Report and wait; the secret may already be in history.
- **Nothing to update still needs approval.** If no doc is wrong or incomplete, say so and wait rather than skipping silently.
- **Rejected findings are reported.** Apply the findings you judge valid; for the rest, state the finding and why it was not applied.
- **Never run `git commit`.** Stage the change, hand over the message, wait.
- **The plan decides, not you.** With a plan, the docs to change and the commit message come from its section. If a named doc needs no change, or a doc it does not name is left wrong, stop and ask.
- **The plan file is read-only.** Never edit it, stage it, or commit it.

## With a plan

Before step 1:
- Run `git check-ignore -q <plan-file>`. If it is not ignored, stop and report. Do not edit `.gitignore`.
- Read the section for `<commit-id>`. Confirm in `git log` that this commit's message is not there yet and, unless it is the plan's first commit, that the previous commit's message is. If either check fails, stop and report.

After step 5:
- If commits remain, print the prompt for the next session (`/docs-commit <plan-file> <next-id>` if the next commit's message has type `docs`, otherwise `/dev-cycle <plan-file> <next-id>`) and tell the user to commit, run `/clear`, and paste it.
- If this was the plan's last commit, print no prompt. Ask whether to delete the plan file; never delete it without a yes.

## Steps

1. Apply the doc changes directly. No agent.
2. `/check-secrets`. The other gate skills have nothing to act on in markdown.
3. Verify inline: check every claim the changed text makes against the code it
   describes — signatures, examples, described behavior. `@code-reviewer` only
   when the commit adds a new document (ADR, guide, migration doc).
4. Apply valid findings. Behavior-preserving by definition — no tests involved.
5. `/get-diff`, stage, hand over the commit message.
