---
description: Survey the codebase for deepening opportunities, then grill through the one you pick
argument-hint: [optional area, module or pain point]
---
1. Spawn the `architect` subagent in **survey** mode with the area below (or none, so it finds the hot spots in git history).
2. Write its candidates as a self-contained HTML report to `${TMPDIR:-/tmp}/architecture-review-<timestamp>.html`: one card per candidate (modules, problem, deepening, benefit in terms of locality and leverage and tests, a before/after diagram drawn with simple HTML boxes or Mermaid from a CDN, and a Strong / Worth exploring / Speculative badge), then the top recommendation. Open it (`open` on macOS, `xdg-open` on Linux) and give me the path.
3. Ask which candidate to explore. Propose no interfaces yet.
4. For the one I pick, read `.claude/agents/griller.md` and grill me on it in **grill** mode: constraints, dependencies, the shape of the deepened module, what sits behind the seam, which tests survive. Update the glossary as terms settle. If I reject the candidate for a reason a future survey would need, offer an ADR so it isn't re-suggested.

Area: $ARGUMENTS
