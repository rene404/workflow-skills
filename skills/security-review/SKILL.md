---
name: security-review
description: Deep security audit covering secrets handling, auth correctness, injection risks, path traversal, and error leakage. Produces High / Medium / Low findings with recommended fixes and tests to add. Use when the user asks for a security review, says "check this for security issues", "is this safe?", or the change touches auth, user input handling, file access, or external requests. Do NOT use for general code quality review — use /review instead.
---

## Philosophy

Security bugs are silent. They don't cause test failures — they cause breaches.
A security review assumes the attacker is smart and looks for what tests don't cover.

## Dimensions

Examine each area. Report every finding — do not filter by likelihood.

### 1. Secrets and credentials

- Are secrets, tokens, passwords, or API keys logged at any level?
- Are they returned in HTTP responses or error messages?
- Are they hardcoded in source files (even in comments or tests)?
- Are they present in any configuration committed to the repo?

### 2. Authentication and authorisation

- Are all protected routes enforcing auth via a dependency — not inline?
- Is the 401 vs 403 distinction correct? (401 = not authenticated, 403 = not authorised)
- Can a lower-privilege caller reach a higher-privilege resource by manipulating IDs or parameters?
- Are auth decisions based on verified data (DB lookup) not unverified input (e.g., a user-supplied role claim)?

### 3. Injection

- Is any user input used in a raw SQL query, ORM `.execute()`, or `text()` without parameterisation?
- Is any user input used in a shell command (`subprocess`, `os.system`)?
- Is any user input interpolated into a file path without sanitisation?
- Is any user input rendered as HTML without escaping?

### 4. File and path access

- Are file paths constructed from user input?
- Is there a path traversal risk (`../` or absolute paths)?
- Are uploaded files validated for type and size before processing?

### 5. External requests (SSRF)

- Does any code fetch a URL provided by the user or derived from user input?
- Is the target URL validated against an allowlist?

### 6. Error and information leakage

- Do error responses include stack traces, SQL queries, or internal paths?
- Do validation errors reveal the existence of private resources (e.g., "user not found" vs "invalid credentials")?
- Is debug mode or verbose logging disabled in production config?

## Output format

```
## Security Review

### High (exploitable — fix before merge)
- [File:line] [Finding] — [Attack scenario]

### Medium (risk exists — should fix)
- [File:line] [Finding] — [Risk]

### Low (defence-in-depth — optional)
- [File:line] [Observation]

### Recommended fixes
1. [Specific fix with file reference]

### Tests to add
- [Auth failure case / injection case / boundary case]
```

## Rules

- Read-only — do not make changes.
- Every High finding must have a file, line, and concrete attack scenario.
- Do not report style issues or general code quality here — use `/review`.
- If you cannot confirm exploitability, report it as Medium with a note.

## Related

- `/review` — general code review (correctness, tests, conventions)
- `/verify` — confirm tests pass after security fixes are applied
