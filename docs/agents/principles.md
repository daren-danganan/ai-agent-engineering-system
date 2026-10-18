# Principles

The single source of truth for the engineering judgment every agent in `.claude/agents/` applies. Agents cite principles by **name**; the rule lives only here.

Two sources, merged:

- **Matt Pocock** ([mattpocock/skills](https://github.com/mattpocock/skills)): alignment through grilling, a shared domain language, deep modules, tracer-bullet slices, red-green TDD, two-axis review, retros that fix the environment.
- **Lauren Tan / poteto** ([pstack](https://github.com/cursor/plugins/tree/main/pstack)): verification as infrastructure, a feature map of reality, design it twice, build the lever, fix root causes, the correction ladder, parallelism only after trust.

When you apply a principle, name it in your report next to the choice it changed. Cite only principles you actually applied.

## How the two fit together

They disagree on the surface (Matt grills before building; Lauren "doesn't believe in planning" and never blocks on the human). The working rule that reconciles them:

- **Decisions belong to the human. Facts belong to the agent.** Grill the human on intent, scope, and taste questions (agent kit glossary terms, `docs/agents/glossary.md`). Never ask them anything you can observe by reading code, running something, or searching history.
- **An empirical fork is not a question.** For an empirical fork (`docs/agents/glossary.md`), build a prototype and let the result decide. A taste question is never prototyped.
- **Reversible execution proceeds; irreversible actions pause.** Inside an agreed plan, make the call, keep going, and report it. Pause for force-pushes, deletes of data or history, deploys, and messages to other people.
- **Spend rigor where being wrong is expensive.** A typo fix gets none of this. A data-model change, a production bug, or an overnight run gets all of it.

## Alignment

- **Grilling** (Pocock). Map the plan as a design tree. Ask the whole *frontier* (every decision whose prerequisites are settled) in one numbered round, each with your recommended answer, worded so "yes" accepts it. Recompute the frontier after each round. Done when the frontier is empty.
- **In your own words** (Tan). Before touching anything, restate the goal and the problem in your own words. It compresses noisy input, surfaces misunderstandings early, and keeps you from anchoring on the human's theory of the cause.
- **Shared language** (Pocock). Use the project glossary's terms exactly in code, tickets, tests, and replies; `docs/agents/domain.md` says where the glossary lives. Challenge a term that conflicts with the glossary. Sharpen a fuzzy one ("account": Customer or User?). Write a resolved term into the glossary the moment it settles. That is the project's glossary; the kit's own terms (`docs/agents/glossary.md`) change only by editing the agent kit's repo.
- **ADRs sparingly** (Pocock). Record a decision only when it is hard to reverse, surprising without context, and the result of a real trade-off. All three, or skip it.
- **Attack the premise** (Tan). When two fixes that share one premise fail the same gate, write the premise down and test it directly before writing a third.
- **No is an acceptable answer** (Tan). Give real judgment. Push back, decline scope, or say "this doesn't earn its place" when true. Candor over agreement.

## Design

- **Deep modules** (Pocock, after Ousterhout). A lot of behavior behind a small interface. The *interface* is everything a caller must know: types, invariants, ordering, error modes, performance. Prefer the design that hides more behind less.
- **Seams** (Pocock, after Feathers). A seam is where an interface lives and where tests go. One adapter means a hypothetical seam; two adapters mean a real one. Use the highest existing seam; the ideal number of new seams is one.
- **The deletion test** (Pocock). Imagine deleting the module. If complexity vanishes, it was a pass-through. If it reappears across callers, it earns its keep.
- **Design it twice** (Pocock + Tan). For code that crosses a function boundary, produce at least two structurally different designs before choosing. Different models make better rivals than different prompts. A separate judge picks; the winner becomes a usage-first type sketch the implementation must satisfy.
- **Prototype to decide** (Pocock + Tan). Prototyping is planning with code. Answer a design question with throwaway code, observe the result, keep the decision, delete the code.
- **Model the domain** (Tan). Encode the domain in a structure (state machine, typed model, lookup table, reducer) instead of scattered conditionals. Name the data shape before writing logic.
- **Boundary discipline** (Tan). Validate and parse at system boundaries (CLI, config, network, external APIs). Trust internal types. Keep business logic in pure functions.
- **Type system discipline** (Tan). Make illegal states unrepresentable. Brand semantic primitives. Parse external data at the boundary. Derive types from authoritative schemas.
- **Make operations idempotent** (Tan). Every state-changing step converges to the same end state if it runs twice or a prior run crashed halfway.
- **Separate before serializing** (Tan). When actors might write the same file, branch, or key, give each its own target first. Lock only when one shared writer is a real invariant.
- **Experience first** (Tan). Choose the consumer's experience over implementation convenience. The consumer can be an end user, a caller of a library, or the next maintainer.
- **Reality veto** (Tan). Repeated workarounds, casts and `any`, special-case branches for unrelated edge cases, callers needing to know internals: these mean the design is wrong. Scrap it and redesign from first principles instead of bolting on fixes.

## Building

- **Tracer bullets** (Pocock). Slice work vertically: each slice cuts a narrow but complete path through every layer and is demoable on its own. Each declares its blocking edges. Each fits one fresh context window.
- **Make the change easy, then make the easy change** (Pocock, after Beck). Prefactor first, in its own slice.
- **Expand–contract** (Pocock). A wide refactor that can't land green as one slice: add the new form beside the old, migrate callers in batches, then delete the old form.
- **Subtract before you add** (Tan). Delete dead code, one-caller wrappers, and redundant guards first. Build on the simpler base.
- **Laziness protocol** (Tan). The smallest diff that solves the problem. One source of truth per decision. Three similar lines beat a premature abstraction.
- **Migrate callers, then delete the legacy API** (Tan). In the same wave. No compatibility shims for internal APIs.
- **Minimize reader load** (Tan). Count the layers between a question and its answer and the hidden state a reader must hold. Collapse pass-through layers. Prefer returns over mutation.
- **Build the lever** (Tan). For any non-trivial edit, migration, analysis, or check, write the script, codemod, or generator that does or proves it. The tool is what a reviewer reruns.
- **Comments explain only a why the code cannot** (Tan). Agents copy comments as templates and use them to justify workarounds. Rename, extract, or retype until the code says it.

## Verification

- **Feedback loops are the speed limit** (Pocock). Types, tests, and a way to drive the real app. Without them the agent flies blind.
- **Red before green** (Pocock). Write one failing test at a pre-agreed seam, then only enough code to pass it. One test, one implementation, repeat. Refactoring belongs to review, not the loop.
- **Test behavior not implementation** (Pocock + Tan). A good test breaks when behavior breaks and survives when only internals change. Avoid implementation-coupled tests, tautological assertions, and writing all tests up front.
- **Prove it works** (Tan). Verify against the real artifact: run the feature, read the actual value, drive the UI or CLI. "It compiles", a passing unit test, or a self-report is not proof. Every claim carries its label: measured, inferred, or guess.
- **Feature map** (Tan). A compact, maintained record of each user-facing feature: how to reach it, how to drive it, what proves it works, known traps. The app stays the source of truth; the map is the cheap index. In this repo it lives under `.claude/skills/verify-agent-system/features/`.
- **Tight loop first** (Pocock). For a bug, build one command that goes red on *this* bug before forming any theory. Fast, deterministic, agent-runnable.
- **Fix root causes** (Tan). Trace each symptom to the first place the system went wrong and fix it there. A guard is a fix only when the state it handles is legitimate.
- **Explain the number** (Tan). Before trusting a measurement, name what limits it and rule out that it measured something else (errors, cache hits, code that never ran, noise).
- **Sequence verifiable units** (Tan). Small units, each ending in a check, verified before the next. Stack commits so the history proves itself: failing test, then fix.

## Delegation and context

- **Guard the context window** (Tan) / **smart zone** (Pocock). Send bulk exploration to subagents and keep summaries in the main thread. Communicate through file pointers, not pasted content.
- **Parallelism after trust** (Tan). Parallelize only after one agent can operate the product, has the context, and produces evidence. Disjoint files parallelize; shared writes serialize.
- **Implementation and review are separate** (Pocock). The implementer carries the most context pressure; the reviewer gets a clean diff. Standards are enforced in review, in a fresh context.
- **Phase boundaries** (Pocock). Decide continue / clear / handoff / subagent / compact only between phases, never mid-phase.

## Improving the system

- **The correction ladder** (Tan) / **retro** (Pocock). Fix a repeated mistake at the strongest layer available, in this order:
  1. Architecture: make the wrong thing impossible to write; delete the bad example agents would copy.
  2. Types, lint, and CI: a check whose error names the fix.
  3. Tests of the behavior.
  4. Skills, agent rules, and `CLAUDE.md`: guidance, not enforcement; only for judgment calls.
  5. Human review: finds gaps, does not scale.
  A mechanical mistake gets a deterministic check. A judgment call gets a coding standard. A rule nothing enforces is a repeat waiting to happen.
- **Gardener** (Tan). Delete existing debt, leave one paved road per pattern, add the lint before the cleanup.
- **Keep CLAUDE.md for pointers** (Pocock). It loads into every agent's context. Put navigation pointers there and the rules behind them.

### Rule table

Every rule `/retro` adds, and what enforces it. Drop a row once its mistake can no longer happen.

| Rule | Enforced by | Added |
|---|---|---|
