# Spec — Builder agent with stack skills and assumptions register

- **ID:** S-003 · **Status:** Approved · **Complexity:** Complex
- **Date:** 2026-10-04 · **Owner:** Daren · **Planned by:** planner
- **Related:** F-001 · F-002 · F-003 · D-003 · D-005 · D-006 · D-007 (proposed) · M4 (proposed)

## 1. Goal
- **What:** A `builder` agent that implements an Approved spec's build order slice by slice, using stack-specific skills, and reports every assumption it makes to doc-keeper for later review.
- **For whom:** The main Claude Code agent (orchestrator) and Daren.
- **Problem / why now:** After a spec is Approved, CLAUDE.md step 3 just says "build". No agent owns building, stack conventions aren't captured anywhere, and unconfirmed choices made while building get lost.
- **Success metric:** Every slice passes its `Verify with` check and the regression checks of the features it touches before the next slice starts, and every unconfirmed choice ends up as an `A-###` entry in `docs/ASSUMPTIONS.md`.

## 2. What exists
| Existing item | Where | Reuse / extend / leave alone |
|---|---|---|
| Approved spec build order (slice, areas/files, Verify with) | `docs/specs/_TEMPLATE.md` §8 | Extend: add a Skill column and auto/manual tags on checks; this table is builder's input |
| `ASSUMPTION:` convention | planner, architect, specs §9 | Reuse for builder's draft assumptions |
| F-001 doc-keeper | `.claude/agents/doc-keeper.md` | Extend: owns `docs/ASSUMPTIONS.md`; may make status-only spec edits |
| F-002 planner | `.claude/agents/planner.md` | Extend: Phase 8 fills the Skill column and tags checks auto/manual; Output points to `/build-feature` |
| F-003 architect | `.claude/agents/architect.md` | Extend: new "build consult" input mode with a short answer format; builder becomes a new caller |
| G-001…G-004 | `docs/GUIDELINES.md` | Leave alone; skills never override them |
| CLAUDE.md feature routing | `CLAUDE.md` | Change step 3 to hand off to builder |

## 3. Changes
**Add**
- `.claude/agents/builder.md`: builder subagent. Tools: `Read, Write, Edit, Glob, Grep, Bash, Skill, Agent(architect)`.
- `.claude/commands/build-feature.md`: `/build-feature <spec> [--from N]`. Holds the orchestration loop the main agent runs.
- `.claude/skills/README.md`: skills registry (`skill | stacks / file globs | status reviewed/unreviewed | owner`) plus the skill template as a fenced block. There is no `_template/` folder, because every folder under `.claude/skills/` loads as a skill.
- `.claude/skills/agent-markdown/SKILL.md`: conventions for this repo's own stack (agent prompts, commands, docs).
- `docs/ASSUMPTIONS.md`: assumptions register, written via doc-keeper.
- `docs/procedures/build-a-feature.md` (P-003), written via doc-keeper.
- D-007, written via doc-keeper.

**Change**
- `CLAUDE.md` step 3: an Approved spec hands off to `/build-feature`. Impact: all agents (core workflow). Regression check: say "fix the typo in README", which should not route to planner or builder; an approved spec should start the build loop.
- `.claude/agents/doc-keeper.md` (F-001): owns `ASSUMPTIONS.md` and shows the Open count in STATUS "Needs attention". It may edit only a spec's Status field and README row, and only for Approved→In progress, →Ready for review, and →Built (on reviewer/Daren sign-off). Regression check: P-001 / F-001 `Verify with`.
- `.claude/agents/planner.md` (F-002): Phase 8 fills the Skill column, prefers auto checks, and tags each check auto/manual; Output points to `/build-feature`. Regression check: F-002 `Verify with` + S-001/S-002 checks.
- `.claude/agents/architect.md` (F-003): adds a "Build consult" input mode with a short answer format. Regression check: F-003 `/tech-review` checks.
- `docs/specs/_TEMPLATE.md`: adds statuses `In progress` and `Ready for review`, a Skill column in §8, and auto/manual tags on Verify with. Impact: planner, builder, doc-keeper. Regression check: S-001/S-002 still valid without a Skill column (builder falls back to the registry).
- `docs/specs/README.md`: new status values. Impact: doc-keeper. Regression check: existing rows unchanged.

**Remove**
- None.

## 4. Scope
- **In scope (MVP):**
  - builder agent
  - `/build-feature` with `--from N` resume
  - git prerequisite: a branch per spec and a commit per slice
  - skills registry with inline template
  - `agent-markdown` skill
  - drafting unreviewed skills for unknown stacks
  - assumptions register (doc-keeper)
  - architect build-consult mode
  - spec template, planner Phase 8 and CLAUDE.md step 3 updates
  - D-007 and P-003
- **Later:**
  - more stack skills (Python, TypeScript/Node)
  - `/review-assumptions` command
  - parallel builds of independent slices
  - scripted auto checks for F-001 to F-003
  - skill lint check
- **Out of scope:** the reviewer/tester agent. It gets a separate spec; until it exists, the main agent asks Daren to review manually.

## 5. Technical design
- **Complexity:** Complex. Rules triggered: C1 (spec template statuses/columns; shared assumptions register), C4 (F-001, F-002, F-003), C5 (CLAUDE.md workflow; amends D-003/G-002). Affected components (9): CLAUDE.md, planner, doc-keeper, architect, spec template + README, builder, `/build-feature`, skills registry, `ASSUMPTIONS.md`. Confirmed by Daren, 2026-10-04.
- **Data source:**
  - The main agent gives builder a brief per slice: spec path, slice number and row, the skills named in the Skill column, files changed so far, and Open assumptions from earlier slices.
  - Builder reads `.claude/skills/<x>/SKILL.md` for the named skills.
  - If the Skill column is empty (S-001/S-002 style), builder matches against the registry.
  - If no skill matches, builder drafts `.claude/skills/<stack>/SKILL.md` from the template, adds a registry row marked `unreviewed` with a warning line, and logs an assumption.
- **Storage:**
  - `docs/ASSUMPTIONS.md` is owned by doc-keeper. It is append-only, except that status is edited in place. Entry format: `A-### · Source: S-###/slice N · Decided by: builder | architect · Assumption · Alternatives · Impact if wrong · Status: Open | Confirmed | Rejected · Resolution`.
  - Build progress lives in STATUS "In progress" (S-### slice n/N) and in a doc-keeper session note.
  - Git commits act as per-slice checkpoints.
- **Failure handling:**
  - `/build-feature` refuses to start or resume (`--from N`) unless `git status` is clean, and asks Daren to commit or stash first.
  - Builder returns `Status: DONE | BLOCKED | FAILED`, plus separate counts `Assumptions: <n>` and `Manual checks pending: <n>`.
  - When a check fails, builder gets 2 fix attempts. A manual check that Daren reports as failed counts the same way: the main agent re-spawns builder with the failure details, and that uses up one of the attempts. After the attempts are used up, builder returns `FAILED`, and the main agent rolls back only the slice's own files (`git restore <files changed>`, plus removing files the slice added), stops, and logs it as Blocked via doc-keeper. Resume with `--from N`; there is no automatic re-spawn.
  - Merging: `build/<slug>` is merged with `--no-ff`, after asking Daren, only once the spec is `Built`. Until then the branch stays open for fixes.
  - Missing information, a needed file outside scope, or a conflict with a G-### rule returns `BLOCKED`, and Daren is asked.
  - When a skill conflicts with a G-### rule, the G-### rule wins; the conflict is flagged in "Needs attention".
- **Security & privacy:**
  - Builder edits only the paths in the slice's "Areas / files", plus, if needed, a draft skill folder and that skill's row in `.claude/skills/README.md`. Any docs edits a slice needs go in the report's `Doc-keeper brief:` line, and the main agent relays them.
  - Builder never touches `docs/`, `.claude/settings*.json`, secrets, `.env`, or `CLAUDE.md` unless the slice lists it.
  - No permission bypass. No secrets in skills or assumptions. No installs or network commands unless the slice and skill call for them.
  - Builder can spawn only architect (`Agent(architect)`).
- **Performance & cost:**
  - One fresh builder subagent per slice, run one after another.
  - Only the skills named for the slice are read; skills stay under 500 lines.
  - Expect 0 or 1 architect consults per slice.
  - doc-keeper runs once per slice (to relay assumptions) and once at the end.
- **Testing strategy:**
  - Each slice runs its own Verify with check, plus the Verify with of every F-### whose Location it touched (G-003).
  - Checks are tagged auto or manual. Builder runs the auto checks; the main agent asks Daren to run the manual checks before the next slice starts.
  - Feature-level tests: a dry-run build of a toy hello-world spec, run on the throwaway branch `build/toy-dry-run` (never merged, test A-### entries marked `Rejected — test fixture`); an unknown stack that forces a drafted skill; a forced failure that triggers rollback and `FAILED`; an architect consult; and RC-1 to RC-3.
- **Observability:**
  - A builder report per slice (format below).
  - STATUS shows the current slice, Blocked items, and the Open assumptions count.
  - The session note records each slice's result, commit hash, and assumptions.
  - At the end, a review brief lists what was built, the checks that passed, pending manual checks, and Open A-### entries.
  - Builder report format:
    ```
    ## Builder — S-### slice N/M — <title>
    - Status: DONE | BLOCKED | FAILED
    - Assumptions: <n> · Manual checks pending: <n>
    - Skills used: <name (reviewed|unreviewed)>
    - Files changed: <path — add|edit>
    - Verify with: <check> — auto PASS|FAIL | manual: <steps for Daren>
    - Regression: F-### <check> — PASS|FAIL|manual
    - Assumptions (draft): <assumption · alternatives · impact if wrong · decided by>
    - Architect consults: <question → answer>
    - Doc-keeper brief: <docs edits needed; new/changed F-###>
    - Blocker / failure: <what, attempts made, suggested fix>
    - Ready for next slice: yes (only if DONE and no manual checks pending, or Daren passed them) | no
    ```
- **Suggested features:**
  - Must-have: `--from N` resume.
  - Later: `/review-assumptions`, scripted auto checks for F-001 to F-003, skill lint, reviewer/tester agent (separate spec).
  - Dropped: none.
- **Architect final review:** 2026-10-04 — gaps resolved: Q1–Q7 (clean-tree check and scoped rollback; merge only after Built; manual-check failure path; dry-run on a throwaway branch; F-004 registry entry; Doc-keeper brief field and registry-row scope; simplified status values)

## 5a. System redesign
- **Current → target:**
  - Now: after approval, the main agent builds ad hoc from the build order.
  - Target: the main agent runs `/build-feature`:
    1. Check git, create branch `build/<slug>`, and have doc-keeper set the spec to In progress.
    2. For each slice: spawn builder (which may consult architect), then run auto checks and have Daren run manual checks.
    3. Commit the slice.
    4. Relay assumptions to doc-keeper.
    5. Move to the next slice.
    6. After the last slice, set the spec to Ready for review and hand Daren the review brief (later, the reviewer agent).
    7. On sign-off, doc-keeper sets the spec to Built.
- **Affected components & interfaces:**
  - CLAUDE.md: step 3 hands off to builder.
  - planner: Phase 8 adds the Skill column and auto/manual tags; Output points to `/build-feature`.
  - spec template: new statuses and Skill column.
  - doc-keeper: owns `ASSUMPTIONS.md`; status-only spec edits.
  - architect: new build-consult input mode; the rest of its contract is unchanged.
  - new: builder, `/build-feature`, skills registry, `agent-markdown` skill, P-003.
- **Migration & compatibility:**
  - S-001 and S-002 stay as they are; specs without a Skill column remain valid.
  - The repo needs `git init` plus a baseline commit (slice 2).
  - CLAUDE.md switches last, so auto-handoff only turns on once everything else is verified.
- **Rollback:** Each slice is a git commit, so reverting it restores the old behavior. CLAUDE.md is unchanged until slice 7.
- **Decision to record:** D-007 — Builder implements approved specs slice by slice with stack skills; assumptions register.
  - Builder runs as a sequential subagent per slice, never asks the user, and logs assumptions.
  - Skills live in `.claude/skills/` and never override G-### rules.
  - doc-keeper owns `ASSUMPTIONS.md` and may make the status-only spec transitions In progress, Ready for review and Built. This amends D-003 and G-002.
- **Spike (slice 1):** 30-minute time-box, throwaway. Prove that a subagent:
  - (a) can spawn `architect` through `Agent(architect)`;
  - (b) can read and invoke a project skill when `Skill` is in its `tools:` list;
  - (c) can create `.claude/skills/<x>/SKILL.md` without a blocking permission prompt;
  - (d) doesn't pick up `.claude/skills/README.md` as a skill.

  Fallback if (c) fails: builder returns drafted skills in its report and the main agent writes them. Fallback if (a) fails: builder returns the question and the main agent consults architect.

## 5b. Constraints & tools
- **Stack / tools / agents:** Claude Code agents, commands and skills (Markdown); git; doc-keeper; architect.
- **Deadline:** None.
- **Non-functional:**
  - Least privilege: per-slice file scope, and builder can spawn only architect.
  - Cost: one subagent per slice, only the skills it needs.
- **Must not change:**
  - D-003 beyond the narrow status-only exception.
  - planner remains the only interviewer.
  - architect remains read-only.
  - The "skip planning" path in CLAUDE.md.

## 6. Acceptance criteria
- [ ] AC-1 — Given an Approved spec, when it is approved or `/build-feature <spec>` runs, then the main agent checks for git (asking once for `git init` plus a baseline commit if it is missing), refuses to start if the working tree isn't clean, creates `build/<slug>`, and doc-keeper sets the spec to `In progress`.
- [ ] AC-2 — Given a slice, when builder runs, then a fresh builder reads the skills in the slice's Skill column, edits only the slice's listed files, and returns the standard report.
- [ ] AC-3 — Given a slice report, when checks are tagged, then builder has run all auto checks, manual checks are given to Daren, and the next slice starts only after this slice's checks and the touched features' regression checks pass.
- [ ] AC-4 — Given a passing slice, when it completes, then it is committed as `S-###: slice N — <title>`.
- [ ] AC-5 — Given a failing auto check, or a manual check Daren reports as failed, when 2 fix attempts fail, then builder returns `FAILED`, the main agent rolls back only the slice's own files and stops, STATUS shows Blocked, and `/build-feature <spec> --from N` resumes.
- [ ] AC-6 — Given builder makes an unconfirmed choice, when the slice ends, then doc-keeper appends an `A-###` entry (source, decided by, alternatives, impact, status Open) to `docs/ASSUMPTIONS.md`, and STATUS "Needs attention" shows the Open count.
- [ ] AC-7 — Given a slice stack with no matching skill, when builder runs, then it drafts `.claude/skills/<stack>/SKILL.md` marked unreviewed, adds a registry row, and logs an assumption.
- [ ] AC-8 — Given a technical question the spec doesn't answer, when builder needs a decision, then it consults architect (the only agent it can spawn) in build-consult mode and logs the answer as an assumption with `Decided by: architect`.
- [ ] AC-9 — Given a needed file outside the slice's scope or a conflict with a G-### rule, when builder hits it, then it returns `BLOCKED` and the main agent asks Daren.
- [ ] AC-10 — Given the last slice passes, when the build ends, then the spec is `Ready for review` and Daren gets a review brief (what was built, checks run, pending manual checks, Open A-###); on sign-off, doc-keeper sets `Built`, editing only the Status field and the README row, and the main agent asks Daren, then merges `build/<slug>` with `--no-ff`.
- [ ] AC-11 — Given planner reaches Phase 8, when it writes the build order, then each slice has a Skill and each Verify with is tagged auto or manual.
- [ ] AC-12 — Given the skills folder, when it is inspected, then `.claude/skills/README.md` holds the registry and inline template, there is no `_template/` folder, and `agent-markdown/SKILL.md` exists with valid frontmatter.
- [ ] AC-13 — Given the build is done, when doc-keeper records it, then `FEATURES.md` has F-004 Builder agent with a Verify with (auto: registry + `agent-markdown` frontmatter; manual: toy dry-run), and F-001 to F-003 are noted as changed by S-003.
- [ ] RC-1 (regression) — F-001 `Verify with` (P-001) still passes.
- [ ] RC-2 (regression) — F-002 `Verify with` and its S-001/S-002 checks still pass.
- [ ] RC-3 (regression) — F-003 `/tech-review` checks still pass.

## 7. Approach
| Option | Reuses | Tools | Effort | Risks / trade-offs |
|---|---|---|---|---|
| A. Fastest | doc-keeper, architect, spec template | agents, commands, skills | M | 3 big slices, no spike; nesting and skill-write risks found late |
| B. Balanced | same | same + git | M | 7 thin slices, spike first, CLAUDE.md last; a few more steps |
| C. Most robust | same | + scripted checks, skill lint, worktrees | L | pulls Later items into scope |

**Recommended:** B. It proves the riskiest pieces (builder → architect nesting, a subagent writing skill files) first, and today's behavior stays the same until the final slice. · **Chosen:** B

## 8. Build order
| # | Slice | Areas / files | Depends on | Verify with | Size |
|---|---|---|---|---|---|
| 1 | Spike: nesting, Skill tool, skill-file write, README not a skill (30 min, throwaway) | scratch agent/skill, deleted after | — | manual: Daren runs the spike prompt in Claude Code; record (a)–(d) results | S |
| 2 | Git baseline + skills registry with inline template | `git init` (Daren), `.claude/skills/README.md` | 1 | auto: `git log` shows a baseline commit; README has registry + template; no `_template/` folder | S |
| 3 | `agent-markdown` skill | `.claude/skills/agent-markdown/SKILL.md`, README row | 2 | auto: frontmatter has name + description; <500 lines; registry row present | S |
| 4 | Assumptions register + doc-keeper ownership + status-only spec edits + D-007 | `.claude/agents/doc-keeper.md`; via doc-keeper: `docs/ASSUMPTIONS.md`, D-007, G-002 amendment | 2 | auto: files and sections exist; manual: RC-1 | M |
| 5 | builder agent + `/build-feature` (`--from N`) + architect build-consult mode | `.claude/agents/builder.md`, `.claude/commands/build-feature.md`, `.claude/agents/architect.md` | 1, 3, 4 | manual: dry-run a toy hello-world spec on throwaway branch `build/toy-dry-run` (AC-1 to AC-10) incl. forced failure and unknown stack; RC-3 | L |
| 6 | Spec template (statuses, Skill column, auto/manual) + planner Phase 8 / Output | `docs/specs/_TEMPLATE.md`, `.claude/agents/planner.md` | 5 | auto: template has new statuses and column; manual: RC-2, AC-11 | M |
| 7 | CLAUDE.md step 3 handoff + P-003 | `CLAUDE.md`; via doc-keeper: `docs/procedures/build-a-feature.md` | 5, 6 | manual: approve a toy spec and confirm the build starts; typo request doesn't route; RC-1 to RC-3 | S |

## 9. Risks, assumptions & open questions
- **Risks:**
  - A subagent writing in `.claude/` may hit permission prompts (spike (c)).
  - Builder → architect nesting depends on the subagent spawn-depth default of 3 (spike (a)). The future reviewer must be spawned by the main agent, not builder, to stay within depth.
  - Manual checks slow builds until scripted checks exist (Later).
  - Builder may rely on an unreviewed skill it drafted; this is surfaced in the review brief.
- **Assumptions:**
  - ASSUMPTION: `Agent(architect)` in `tools:` limits builder to spawning only architect (per Claude Code sub-agents docs; spike verifies).
  - ASSUMPTION: Builder needs no WebSearch/WebFetch in the MVP.
  - ASSUMPTION: doc-keeper runs once per slice; acceptable cost.
- **Open questions:**
  - ~~M4 name/definition in PLAN.md~~ — resolved 2026-10-04: M4 = "Builder agent + stack skills + assumptions register".
  - Building the slices that change builder's own files (slices 5–7) is done by the main agent directly, since builder doesn't exist yet. (ASSUMPTION)
