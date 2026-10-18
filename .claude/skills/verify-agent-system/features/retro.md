# Retrospective

`/retro [transcript, range or focus]` has the `retro` agent read a session transcript or a stretch of git history, group the mistakes into classes, and propose one fix per class at the strongest layer of the correction ladder, most severe first. The main conversation shows the findings and asks which to apply. Only approved findings are applied, one commit each, and each applied rule is added to the rule table in `docs/agents/principles.md`.

Run 2026-10-17, run `20261017-181424-12799` (retro-1, retro-2): `retro-spawn`, `retro-findings` and `retro-ask` pass. **`retro-apply` is blocked by the harness:** the first write of the approved fix went to `.claude/scripts/`, and Claude Code's permission system refuses writes under `.claude/` in `-p` mode even with `Write` allowed. Nothing was written or committed, and the agent asked how to proceed. Evidence: `~/.cache/verify-agent-system/20261017-181424-12799/evidence/`.

## Sub-features

- `retro-spawn` spawns `retro` with a transcript path or range.
- `retro-findings` the report holds `## Retro —`, numbered classes with a severity, Evidence, Layer, Change, "Why not a stronger layer" and "Proves itself by".
- `retro-ask` ends by asking which findings to apply; nothing is changed before that.
- `retro-apply` applies only approved findings, one commit each, and adds a row to the rule table in `docs/agents/principles.md`.

## How to get to it (user POV)

- Type `/retro` after a session, or `/retro <transcript path | git range | focus>`.

## Driving it with verify.sh

Preconditions:

- Baseline preconditions from the README hold.
- A history to review. Create one with a correction in it: `$V seed-tickets`, then `printf 'hello\n' > $S/hello.txt && git -C $S add hello.txt && git -C $S commit -qm "verify-hello #01: Add hello file" && printf 'hello from implementer\n' > $S/hello.txt && git -C $S commit -qam "fix: hello.txt content did not match the ticket"`.

- **Review the range.** Run `VERIFY_BUDGET_USD=5 $V drive retro-1 "/retro HEAD~3..HEAD"`. Exit is `0`. The result holds `## Retro —` and at least one class with `Layer:` and `Evidence:` naming one of the commits, then asks which to apply.
- **Check routing.** `grep '^Agent' $E/retro-1.tools.tsv` shows one `retro` row.
- **Check read-only until approval.** `$E/retro-1.state.txt` has an empty porcelain section and no new commit.
- **Apply one.** Blocked when the finding touches `.claude/` (see Gotchas). Run `VERIFY_BUDGET_USD=5 $V drive --continue retro-2 "apply finding 1 only"`. `git -C $S log --oneline -3` gains exactly one commit, and `git -C $S diff HEAD~1 -- docs/agents/principles.md` adds a rule-table row.

## Gotchas

- The default input is the newest transcript under `~/.claude/projects/` for the sandbox path, which is the drive's own session. Always pass a git range so the drive does not review itself.
- The retro may find nothing worth a class in a tiny history and say so. That is a pass for `retro-findings` only if it says why; note it.
- Writes under `.claude/` are refused in `-p` mode, and most retro fixes land there (scripts, agents, commands). Pick a finding whose change is outside `.claude/`, or count `retro-apply` as not driven. Do not switch the drive to a permission-bypassing mode to get past it.
- Costs were about 0.46 USD for retro-1 and 0.65 USD for retro-2.
- Applying a finding may need commands outside the drive allowlist (a lint or test run). Record the denial; do not widen the list to make it pass.
