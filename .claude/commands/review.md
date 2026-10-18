---
description: Two-axis review of a diff (Standards and Spec in separate contexts), judged into act-on / consider / noted / dismissed
argument-hint: [fixed point - commit, branch, tag; defaults to the merge-base with main] [--adversarial]
---
Review the changes since the fixed point. Edit no files.

Input: $ARGUMENTS

1. **Pin the fixed point.** Resolve it with `git rev-parse`. Default to `git merge-base HEAD main` (or the repo's default branch). Capture `git diff <fixed>...HEAD` and `git log <fixed>..HEAD --oneline`. Stop on a bad ref or an empty diff.
2. **State the intent** in one paragraph from the commit messages, the ticket references, and the code. If you can't tell what the change is for, ask me.
3. **Find the spec**: a `.scratch/` path named in commits, the path I passed, or the `.scratch/<slug>/` matching the branch name. None → the spec axis reports "no spec available".
4. **Find the standards**: every file in the repo that documents how code is written (`CODING_STANDARDS.md`, `CONTRIBUTING.md`, `CLAUDE.md`, `docs/agents/principles.md`, the glossary, ADRs).
5. **Spawn reviewers in one message, in parallel**, read-only:
   - `reviewer`, axis `standards`, with the diff command, commit list, and standards files.
   - `reviewer`, axis `spec`, with the diff command, commit list, and spec and ticket paths.
   - With `--adversarial`: a second `reviewer` on the standards axis with `model: "sonnet"` (or `opus` if the session runs on Sonnet), for a second opinion from a different model.
6. **Judge.** You are the lead reviewer, a pragmatic senior engineer, not an aggregator. Merge duplicates and note which reviewers raised each. A finding raised independently by two models is the strongest signal. Put each finding in one bucket, with a one-line reason:
   - **Act on** — affects correctness, security, or maintainability; would block a real PR.
   - **Consider** — legitimate, but the cost may outweigh fixing it now.
   - **Noted** — valid, not actionable at this stage.
   - **Dismissed** — wrong, nitpicky, or missing context.
7. **Reply** with: Intent, then `## Standards` and `## Spec` (the reviewers' findings, lightly cleaned, never re-ranked across axes), then the four buckets, then one line per axis with the count and the worst finding. Do not apply fixes unless I ask.
