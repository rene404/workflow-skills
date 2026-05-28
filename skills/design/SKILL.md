---
name: design
description: Produce a minimal technical design before any planning or coding begins. Defines endpoint contracts, data model changes, auth/permissions, migration strategy, and test strategy. Use when the user describes a feature that needs architectural decisions first, says "design this", "how should we structure this?", or the change touches the data model, auth, or multiple system layers. Do NOT write code or a plan — output a design and hand off to /plan.
---

## Philosophy

The cheapest time to change a design is before any code exists.
A good design is the smallest one that satisfies the requirements — not the most complete one.

## Process

### 1. Understand the problem

- Restate the goal in one sentence.
- Identify what must be true for the design to be correct (acceptance criteria).
- Identify what is explicitly out of scope.
- If requirements are unclear, stop and use `/grill-me` first.

### 2. Identify the current state

- Locate the relevant existing code areas (modules, routes, models, services).
- Note what already exists and can be reused.
- Note what conflicts with the proposed change.

### 3. Propose the smallest design

Output a design with these sections:

```
### Endpoint contract(s)
- Method + path
- Auth: [public / authenticated / role required]
- Request model: [fields + types]
- Response model: [fields + types]
- Status codes: [success, error cases]

### Data model changes
- New tables / columns / indexes / constraints
- Changes to existing tables
- Constraints or invariants to preserve

### Auth / permissions
- Who can call this? What happens if they can't?
- 401 vs 403 distinction

### Migration strategy (if schema changes)
- Rollout plan: [expand → backfill → contract, or simpler if safe]
- Backward compatibility: [what existing callers break, if any]
- Destructive risks: [locks, data loss, irreversible ops]

### Key invariants
- [What must always be true after this change is deployed]
```

### 4. List tradeoffs

For each significant decision, state:
- What was chosen and why
- What was rejected and why

### 5. Test strategy

- Must-have tests (behaviours that must be covered)
- Edge cases worth noting
- What cannot be unit-tested and needs an integration test

## Rules

- Do not write implementation code.
- Do not produce a task plan — hand off to `/plan` with the design as input.
- If the design requires clarification before it can be handed off, say so explicitly.
- Prefer the simpler design. Complexity must be justified by a concrete requirement.

## Related

- `/grill-me` — clarify requirements before designing
- `/grill-with-docs` — stress-test the design against the domain model before planning
- `/plan` — next step: turn the approved design into an ordered task plan
- `/zoom-out` — if you need to understand the existing architecture before designing
