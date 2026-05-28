---
name: diagnose
description: Systematic debugging loop for hard bugs, unexpected failures, and performance regressions. Reproduce → minimise → hypothesise → instrument → fix → regression test. Use when the user says "debug this", "diagnose", reports a bug, describes something broken or throwing, or pastes a stack trace. Do NOT skip straight to a fix — always reproduce first.
---

## Loop

Run each phase in order. Do not skip ahead.

### 1. Reproduce

- Get a reliable reproduction: exact command, request, or input that triggers the failure.
- If the bug is intermittent, find the condition that makes it deterministic.
- Write down the observed vs expected behaviour precisely.

### 2. Minimise

- Strip away unrelated code, data, or config until you have the smallest case that still reproduces.
- A minimal reproduction exposes the root cause faster and makes the regression test obvious.

### 3. Hypothesise

- List 2–4 concrete hypotheses ranked by likelihood.
- Each hypothesis must be falsifiable (i.e., there is a test that would disprove it).
- Do not start instrumenting until you have at least two hypotheses.

### 4. Instrument

- Add targeted logging, assertions, or temporary print statements to test the top hypothesis.
- Run the reproduction. Observe. Does the evidence support or falsify the hypothesis?
- If falsified, move to the next hypothesis and repeat.
- Do not scatter logging everywhere — one focused probe at a time.

### 5. Fix

- Implement the minimal change that addresses the confirmed root cause.
- Do not refactor surrounding code while fixing. Scope is the bug.
- Run the full test suite. All tests must pass before continuing.

### 6. Regression test

- Write a test that would have caught this bug.
- Confirm it fails on the unfixed code (or verify the condition conceptually).
- Confirm it passes on the fixed code.
- Commit: fix + regression test together.

## Hard rules

- Never jump to Step 5 without completing Steps 1–4.
- Never fix two bugs in one commit.
- If the fix is large or touches many files, use `/plan` to break it into safe steps first.

## Common traps

| Trap | Correct action |
|---|---|
| "I think I know what it is" | Still reproduce and hypothesise |
| Fix doesn't hold in CI | The reproduction was not complete — go back to Step 1 |
| Can't reproduce locally | Document the exact environment difference; don't fix blind |
| Multiple failures at once | Fix the deepest root cause first, then re-run |

## Related

- `/tdd` — if the fix requires new behaviour, drive it with tests
- `/verify` — final check after fix is in place
