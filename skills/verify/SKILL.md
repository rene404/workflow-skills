---
name: verify
description: Run fresh, end-to-end verification before declaring any task complete. Re-run all tests, confirm observable behaviour, and check for regressions. Use when the user says "are we done?", "does this work?", "verify the changes", or before closing a feature branch. Never skip this because "the tests were passing earlier" — always run fresh.
---

## Rule

A task is not done until verification runs fresh in this session and passes.
"I ran tests earlier" is not verification. Stale results are not evidence.

## Checklist

Run these in order. Report results for each.

### 1. Full test suite

```bash
# Backend
docker compose exec backend pytest -q

# Frontend (if frontend was touched)
docker compose exec frontend npm test
docker compose exec frontend npm run typecheck
```

All tests must pass. No skipped tests that weren't already skipped before your change.

### 2. Behaviour check

- Identify the observable behaviour that was requested.
- Confirm it works: exact endpoint call, page interaction, or script run.
- Show the output or response — do not describe it from memory.

### 3. Regression check

- For bug fixes: confirm the original failure no longer occurs.
- For new features: confirm existing behaviour is unchanged (covered by test suite).

### 4. Migration check (schema changes only)

Run the project's migration up → down → up cycle (substitute the relevant tool — Alembic, Flyway, Prisma, etc.):

```bash
<migrate> upgrade head
<migrate> downgrade -1
<migrate> upgrade head
```

Up/down/up must succeed without errors.

### 5. No uncommitted changes

```bash
git status
git diff
```

All intentional changes are staged or committed. No stray files.

## Failure handling

If any step fails:
- Do not mark the task complete.
- Return to `/diagnose` or `/tdd` to fix the failure.
- Re-run the full verification checklist from Step 1 after fixing.

## Related

- `/diagnose` — if verification reveals a failure
- `/tdd` — if a test is missing and needs to be written
