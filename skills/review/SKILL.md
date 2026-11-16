---
name: review
description: Structured code review covering correctness, test coverage, security, and project conventions. Produces a prioritised findings list with clear accept/request-changes verdict. Use when the user asks for a code review, says "review this", "review the diff", or "is this ready to merge?". Read-only — does not make changes. Do NOT use for a deep security audit — use /security-review instead.
---

## Philosophy

A review is not a style debate. It is a structured search for problems that
would affect correctness, maintainability, or safety in production.

## Dimensions

Examine in this order. Work through all five dimensions even when a High finding
turns up early — the verdict needs the complete picture, and a second High in a
later dimension changes what the author has to fix.

### 1. Correctness

- Does the code do what the task/PR description says it does?
- Are there off-by-one errors, wrong types, incorrect conditions?
- Are error cases handled? What happens on unexpected input?
- Are multi-step state changes atomic where a partial failure would leave inconsistent data (transactions, or the equivalent for your storage)?

### 2. Tests

- Is the changed behaviour covered by tests?
- Do the tests test behaviour (observable output) or implementation (internals)?
- Would the tests catch a regression if this code were reverted?
- For bug fixes: is there a regression test?

### 3. Security

- Is any user input used in a query, shell command, or file path without parameterisation or sanitisation?
- Are secrets, tokens, or credentials logged or returned in responses?
- Are auth checks applied consistently on new entry points?

### 4. Conventions

- Does the code follow the patterns documented in the project — whichever of `CONTEXT.md`, `AGENTS.md`, or language/framework instruction files exist?
- Are the project's layer boundaries respected (e.g., entry points thin, core logic not depending on I/O or framework details)?
- Are external contracts (API payloads, file formats, CLI output) kept separate from internal data structures where the project requires it?
- Is the naming consistent with existing code?

### 5. Migrations (if applicable)

- Can the migration be rolled back (a reverse step, or a documented reason why not)?
- Is the rollback safe (no data loss for a simple rollback)?
- Was the migration tested apply → roll back → apply?

## Output format

```
## Code Review

### Verdict: [APPROVE / REQUEST CHANGES]

### High (must fix before merge)
- [File:line] [Finding] — [Why it matters]

### Medium (should fix)
- [File:line] [Finding] — [Suggested improvement]

### Low (optional)
- [File:line] [Observation]

### Praise (what was done well)
- [Specific thing done right]
```

## Rules

- Do not make changes. Flag findings and let the author fix.
- Separate must-fix from nice-to-have clearly.
- Every High finding must have a specific file and line reference.
- If you cannot determine correctness without running the code, say so explicitly.

## Related

- `/verify` — run tests before or after this review
- `/zoom-out` — for structural or architectural concerns beyond this diff
- `/tdd` — if tests are missing and need to be written
