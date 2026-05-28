---
name: tdd
description: Test-driven development using red-green-refactor. Write a failing test first, implement the minimum code to make it pass, then refactor. Use when the user wants to build a feature with TDD, says "test first", mentions "red-green-refactor", or wants to drive implementation from tests. Do NOT use when fixing a bug that already has a failing test — use /diagnose instead.
---

## Philosophy

If you didn't watch the test fail, you don't know if it tests the right thing.
Every task produces a passing test suite and a commit. No exceptions.

## Cycle

Repeat for each small, vertical slice of behaviour:

### 1. RED — write a failing test

- Write the smallest test that captures the next unit of behaviour.
- Run it. Confirm it fails for the right reason (not import error, not wrong assertion).
- Do not write implementation code yet.

### 2. GREEN — implement the minimum

- Write only enough code to make the test pass.
- No extra logic, no "while I'm here" additions.
- Run the full test suite. All tests must be green before continuing.

### 3. REFACTOR — clean without breaking

- Improve structure, naming, and clarity.
- Run the full suite again. Still green.
- Commit: one logical slice per commit.

## Slicing rules

- Vertical slices: each slice adds end-to-end behaviour (route → service → DB → response).
- Never horizontal slices (all routes first, then all services, then all tests).
- If a slice feels too large, split it before writing any code.

## Anti-patterns

| Anti-pattern | Why it fails |
|---|---|
| Writing tests after implementation | You can't know if the test ever failed |
| Mocking internals | Tests pass when real code breaks |
| Skipping RED | GREEN without RED is just writing code with a test file open |
| Giant slices | Debugging a 500-line diff is not TDD |

## Verification gate

Before declaring a slice done:
1. Run the full test suite fresh (`pytest -q` or `docker compose exec backend pytest -q`).
2. All tests pass.
3. No tests were skipped or suppressed.
4. Commit the slice.

## Related

- `/plan` — break the feature into TDD-ready slices before starting
- `/verify` — final check before closing the task
- `/diagnose` — if a test fails unexpectedly during the cycle
