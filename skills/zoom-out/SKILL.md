---
name: zoom-out
description: Architecture health review — examine the codebase for coupling, complexity, tech debt, and structural drift. Produces an honest assessment with prioritised observations. Use when the user asks for a code health check, architecture review, "what's the tech debt?", "is the structure good?", or before a major refactor. Read-only — does not make changes.
---

## Philosophy

Zoom out sees the forest, not the trees. The goal is to identify structural
patterns — both strengths and liabilities — not to nitpick individual functions.

## Review dimensions

Examine each dimension and produce findings ranked by severity (High / Medium / Low).

### 1. Coupling

- Which modules depend on which? Is the dependency graph acyclic?
- Are there hidden couplings (shared mutable state, implicit ordering, global config)?
- Does changing one file unexpectedly require changing many others?

### 2. Complexity

- Where is the highest cyclomatic complexity? Are there functions doing too much?
- Are there deep call chains that are hard to follow?
- Is there conditional logic that should be data-driven or polymorphic?

### 3. Boundaries

- Are system boundaries explicit? (HTTP layer vs service vs DB vs external services)
- Is business logic leaking into routing or DB layers?
- Are dependencies injected or hardcoded?

### 4. Consistency

- Are naming conventions uniform across the codebase?
- Are similar problems solved the same way across modules?
- Are there competing patterns (two ways to do the same thing)?

### 5. Test coverage shape

- Are tests concentrated on implementation details rather than behaviour?
- Are there critical paths with no test coverage?
- Are tests brittle (break on refactor that preserves behaviour)?

### 6. Drift

- Does the current structure match what `CONTEXT.md` and `AGENTS.md` describe?
- Are there abandoned patterns, dead code, or modules that no longer fit?

## Output format

```
## Architecture Health Review

### Strengths
- [What is working well structurally]

### Findings

#### High
- [Finding]: [Why it matters] → [Suggested direction]

#### Medium
- [Finding]: [Why it matters] → [Suggested direction]

#### Low
- [Finding]: [Why it matters] → [Suggested direction]

### Recommended next steps
1. [Most important structural improvement]
2. ...
```

## Hard limits

- Do not make any code changes during this review.
- Do not propose a rewrite. Propose targeted, incremental improvements.
- If a finding requires immediate action, note it clearly and use `/plan` to structure the work.

## Related

- `/plan` — turn a finding into an actionable implementation plan
- `/grill-me` — clarify constraints before planning structural work
- `/review` — lower-level review for a specific change or PR
