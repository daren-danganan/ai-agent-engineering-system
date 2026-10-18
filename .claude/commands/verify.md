---
description: Prove a claim on the real artifact, or create/refresh the feature map (verifier)
argument-hint: [a ticket path, feature, or claim to prove] | map [create|maintain] [feature or spec path]
---
If the input starts with `map`, spawn the `verifier` subagent in **map** mode with the rest of the input. Otherwise spawn it in **verify** mode with the input as the claim.

Show me its report as is. For a FAIL or INCONCLUSIVE, add one line on the most likely next step (`/diagnose`, or fixing the map). For map gaps it reports, offer `/verify map maintain`.

Input: $ARGUMENTS
