# Verify a claim, or map the features

`/verify <claim>` hands a claim (a ticket path, a fix, or a plain statement) to the `verifier`, which drives the real artifact and returns `PASS`, `FAIL` or `INCONCLUSIVE` with evidence, side effects checked and false-pass checks. `/verify map create|maintain` has the `verifier` create or refresh a project's verification skill and feature map. The main conversation shows the report as is and adds a next step for a failure or a map gap.

Proven 2026-10-17, run `20261017-180108-1126` (verify-1, verify-2): every sub-feature except `map-create` passes. `map-create` is not yet run. Evidence: `~/.cache/verify-agent-system/20261017-180108-1126/evidence/`.

## Sub-features

- `verify-route` spawns `verifier` in verify mode for a claim, in map mode for input starting with `map`.
- `verify-report` the report holds `## Verifier —`, a `Verdict:` line, `Journey:`, `Evidence:`, `Side effects checked:`, `False-pass checks:` and `Map gaps:`.
- `verify-pass` a true claim on the real artifact gets `PASS` with a command and its observed result.
- `verify-fail` a false claim gets `FAIL` or `INCONCLUSIVE`, and the reply adds one next-step line (`/diagnose` or fixing the map).
- `verify-no-skill` in a project without a verification skill, map gaps say to run `/verify map create`.
- `verify-readonly` verify mode leaves product files and the log unchanged.
- `map-create` writes `.claude/skills/verify-<app>/SKILL.md` and `features/`.

## How to get to it (user POV)

- Type `/verify <ticket path, feature or claim>`.
- Type `/verify map create` or `/verify map maintain [feature or spec path]`.
- Reached indirectly from `/implement` (per ticket and at the end) and `/diagnose` (after `FIXED`).

## Driving it with verify.sh

Preconditions:

- Baseline preconditions from the README hold.
- `$V seed-tickets` has run.
- Build the fixture by hand so there is something to prove: `printf 'hello from implementer\n' > $S/hello.txt && git -C $S add hello.txt && git -C $S commit -qm "verify-hello #01: Add hello file"`.

- **Prove a ticket.** Run `$V drive verify-1 "/verify .scratch/verify-hello/issues/01-add-hello-file.md"`. Exit is `0`. The result holds `Verdict: PASS` and the ticket's `grep -cx 'hello from implementer' hello.txt` check printing `1`. About 0.23 USD.
- **Check routing.** `grep '^Agent' $E/verify-1.tools.tsv` shows one `verifier` row.
- **Check map gap.** The `Map gaps:` line says there is no verification skill and names `/verify map create`, because launch leaves this skill out of the sandbox.
- **Check read-only.** `$E/verify-1.state.txt` has an empty porcelain section and no new commit.
- **Catch a false claim.** Run `printf 'hello\n' > $S/hello.txt && git -C $S commit -qam "break hello"`, then `$V drive verify-2 "/verify .scratch/verify-hello/issues/01-add-hello-file.md"`. The result holds `Verdict: FAIL` and a next-step line.
- **Map create.** On a fresh launch, run `VERIFY_BUDGET_USD=8 $V drive map-1 "/verify map create"`. `ls $S/.claude/skills/verify-*/SKILL.md $S/.claude/skills/verify-*/features/README.md` lists both files.

## Gotchas

- Before 2026-10-17 the fixture's check was `grep -qx … exits 0`. Inside a drive the Bash tool reports grep's exit 1 as success, so a verifier saw a negative control "pass". The fixture now uses `grep -c`, which prints `1` or `0`.
- The FAIL reply's next step may say `/diagnose` even when the cause is a plain content mismatch; either next-step line passes `verify-fail`.
- The verifier may write evidence files; in verify mode they belong in a run directory, never in product paths. Treat a product file in porcelain as a FAIL of `verify-readonly`.
- `map create` writes under `.claude/skills/`, and Claude Code refuses writes under `.claude/` in `-p` mode. Expect it to be blocked in a drive.
- `map create` in the sandbox writes a second harness for this same repo. It is expensive and slow; run it only when the map mode changed.
- The verifier refuses to grade its own work. Do not drive `/verify` in the same `--continue` conversation that built the change.
