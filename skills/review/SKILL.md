---
name: review
description: Structured code review covering correctness, test coverage, security, and project conventions. Produces a prioritised findings list with clear accept/request-changes verdict. Use when the user asks for a code review, says "review this", "review the diff", or "is this ready to merge?". Read-only — does not make changes. Do NOT use for a deep security audit — use /security-review instead.
---

## Philosophy

A review is not a style debate. It is a structured search for problems that
would affect correctness, maintainability, or safety in production.

## Dimensions

Examine in this order. Stop and flag immediately if a High finding is found.

### 1. Correctness

- Does the code do what the task/PR description says it does?
- Are there off-by-one errors, wrong types, incorrect conditions?
- Are error cases handled? What happens on unexpected input?
- Are DB operations transactional where they need to be?

### 2. Tests

- Is the changed behaviour covered by tests?
- Do the tests test behaviour (observable output) or implementation (internals)?
- Would the tests catch a regression if this code were reverted?
- For bug fixes: is there a regression test?

### 3. Security

- Is any user input used in a DB query, shell command, or file path without sanitisation?
- Are secrets, tokens, or credentials logged or returned in responses?
- Are auth checks applied consistently on new routes?
- Does a 401 vs 403 distinction matter here and is it correct?

### 4. Conventions

- Does the code follow the patterns documented in the project (e.g., `CONTEXT.md`, `AGENTS.md`, language- or framework-specific instructions)?
- Are layer boundaries respected (e.g., routes thin, business logic in services, DAO/ORM not leaking into the transport layer)?
- Are request/response schemas distinct from internal/persistence models?
- Is the naming consistent with existing code?

### 5. Migrations (if applicable)

- Does the migration have both `upgrade` and `downgrade`?
- Is the downgrade safe (no data loss for a simple rollback)?
- Was the migration tested up/down/up?

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
