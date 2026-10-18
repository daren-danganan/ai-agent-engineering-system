# Improve the architecture

`/improve-architecture [area]` has the `architect` survey the code (the named area, or the files that change most) for deepening opportunities, writes the candidates as a self-contained HTML report with one card per candidate and a strength badge, opens it, and asks which candidate to explore. For the one the user picks, it grills them in griller style without proposing interfaces up front. It edits no product code.

Proven 2026-10-17, run `20261017-181038-11672` (arch-1, arch-2): `arch-survey`, `arch-report`, `arch-ask` and `arch-readonly` pass. `arch-grill` is only partly proven: the pick opened the grill with a restatement, as `griller.md` says; the numbered round was not driven. Evidence: `~/.cache/verify-agent-system/20261017-181038-11672/evidence/`, including `arch-1.report.html`.

## Sub-features

- `arch-survey` spawns `architect` in survey mode.
- `arch-report` writes `${TMPDIR:-/tmp}/architecture-review-<timestamp>.html` with one card per candidate, each badged Strong, Worth exploring or Speculative, and a top recommendation; the reply gives the path.
- `arch-ask` ends by asking which candidate to explore and proposes no interface.
- `arch-grill` on a pick, asks numbered questions with recommended answers about that candidate.
- `arch-readonly` leaves the sandbox tree and log unchanged, apart from glossary or ADR files a grill may write.

## How to get to it (user POV)

- Type `/improve-architecture` or `/improve-architecture <area or pain point>`.
- Then reply with the candidate to explore.

## Driving it with verify.sh

Preconditions:

- Baseline preconditions from the README hold.

- **Survey.** Run `VERIFY_BUDGET_USD=5 $V drive arch-1 "/improve-architecture .claude/scripts"`. Exit is `0`. The result names an `architecture-review-*.html` path, lists candidates, and asks which to explore.
- **Check routing.** `grep '^Agent' $E/arch-1.tools.tsv` shows one `architect` row.
- **Check the report.** The result names `/tmp/architecture-review-<timestamp>.html`. Copy it to `$E/arch-1.report.html` and delete it from `/tmp`. `grep -o 'Strong\|Worth exploring\|Speculative' $E/arch-1.report.html | sort | uniq -c` counts at least one badge (the run had 2 Strong, 2 Worth exploring, 1 Speculative).
- **Check read-only.** `$E/arch-1.state.txt` has an empty porcelain section.
- **Grill a pick.** Run `$V drive --continue arch-2 "explore candidate 1"`. The result restates the goal for that candidate and asks for a correction, with no `Q1` yet. `tools.tsv` shows a `main` `Read` of the sandbox's `.claude/agents/griller.md`.
- **First round.** Run `$V drive --continue arch-3 "yes"`. The result holds at least one `**Q1**` with a `➡️` recommendation. Not yet run.

## Gotchas

- The report goes to `/tmp`, not `$TMPDIR`: `printenv TMPDIR` is denied, so the agent falls back. `Write` outside the sandbox was allowed. Cleanup does not remove the file; the copy-and-delete step above does.
- Costs were about 0.73 USD for arch-1 and 0.89 USD for arch-2.
- `open` is not on the drive allowlist, so the browser never opens during verification; the result reporting the denial is expected. Do not widen the allowlist to include `open`.
- The architect may find little in a small area; one candidate is a pass.
