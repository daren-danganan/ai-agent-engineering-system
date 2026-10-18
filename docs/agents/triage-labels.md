# Triage Labels

The skills speak in terms of five canonical triage roles. This file maps those roles to the actual label strings used in this repo's issue tracker.

| Label in mattpocock/skills | Label in our tracker | Meaning                                  |
| -------------------------- | -------------------- | ---------------------------------------- |
| `needs-triage`             | `needs-triage`       | Maintainer needs to evaluate this issue  |
| `needs-info`               | `needs-info`         | Waiting on reporter for more information |
| `ready-for-agent`          | `ready-for-agent`    | Fully specified, ready for an AFK agent  |
| `ready-for-human`          | `ready-for-human`    | Requires human implementation            |
| `wontfix`                  | `wontfix`            | Will not be actioned                     |

When a skill mentions a role (e.g. "apply the AFK-ready triage label"), use the corresponding label string from this table.

Edit the right-hand column to match whatever vocabulary you actually use.

## Feature status

A ticket closes with `done` (a wayfinding child ticket closes with `resolved`; both clear a `Blocked by:`, `wontfix` does not). A feature's `spec.md` carries the same `Status:` line and moves through these states:

| Status | Set by | Meaning |
|---|---|---|
| `ready-for-agent` | `/to-spec` | Spec written; tickets may or may not exist yet |
| `building` | `/implement`, on its first run | Tickets being built on `build/<slug>` |
| `shipped` | `/implement`, when you approve the merge | Merged into the base branch; feature map updated |

`/status` rolls these up with each feature's ticket counts.
