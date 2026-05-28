---
name: new-feature
description: Full feature workflow orchestrating requirements clarification → implementation plan → TDD implementation → verification → code review. Use when the user wants to build a complete feature end-to-end and wants structured guidance through all phases. Do NOT use for small isolated changes — use /tdd or /plan directly instead.
---

## Philosophy

A feature is not done when the code works. It is done when it is planned,
tested, verified, and reviewed — in that order.

## Phases

Each phase must complete before the next begins. Do not skip phases.

---

### Phase 0 — Design (use `/design`) — optional

Use when the feature touches the data model, auth, or multiple system layers
and the architecture is not yet decided.

**Gate:** Design is approved. → Proceed to Phase 1. Skip if design is already settled.

---

### Phase 1 — Clarify (use `/clarify-requirements`)

Before touching any code:
- Identify ambiguities and missing requirements.
- Confirm scope, constraints, and success criteria with the user.
- Read `CONTEXT.md` and relevant source files.

**Gate:** User has confirmed the requirements summary. → Proceed to Phase 1.5 or Phase 2.

---

### Phase 1.5 — Validate domain (use `/harden-plan`) — optional

Use when the feature introduces new domain terms, changes existing ones, or the design needs stress-testing against `CONTEXT.md`.

- Challenge terminology against the existing domain model.
- Update `CONTEXT.md` inline as decisions crystallise.
- Create ADRs for hard-to-reverse, surprising decisions.

**Gate:** CONTEXT.md is updated and design is validated. → Proceed to Phase 2. Skip if domain is stable.

---

### Phase 2 — Plan (use `/plan`)

- Break the feature into ordered, vertical, bite-sized tasks.
- Every task has exact file paths, commands, and a done-when condition.
- Include migration tasks for schema changes.
- Include test tasks for every behaviour change.

**Gate:** User has approved the plan. → Proceed to Phase 3.

---

### Phase 3 — Implement (use `/tdd`)

Execute the plan task by task using red-green-refactor:
- Write failing test → implement minimum → refactor → commit.
- One task, one commit.
- Do not implement task N+1 until task N is committed and green.

**Gate:** All plan tasks are committed and the full test suite is green. → Proceed to Phase 4.

---

### Phase 4 — Verify (use `/verify`)

- Run the full test suite fresh.
- Confirm the feature's observable behaviour end-to-end.
- Check for regressions.
- For schema changes: run up/down/up migration cycle.

**Gate:** All verification steps pass. → Proceed to Phase 5.

---

### Phase 5 — Review (use `/review`)

- Review the full diff for correctness, tests, security, and conventions.
- Fix any High findings before declaring done.
- Address Medium findings or document why they are deferred.

**Gate:** Review verdict is APPROVE (or all High findings are fixed). → Feature is done.

---

## Shortcuts

If architecture is already decided: skip Phase 0.
If requirements are already clear: start at Phase 2.
If a plan already exists: start at Phase 3.
If only verification and review remain: start at Phase 4.

## Exit condition

The feature is complete when:
- [ ] All plan tasks are committed
- [ ] Full test suite passes (`pytest -q`, `npm test`, `npm run typecheck`)
- [ ] Observable behaviour is confirmed
- [ ] Review verdict is APPROVE

## Related

- `/design` — Phase 0 detail
- `/clarify-requirements` — Phase 1 detail
- `/harden-plan` — Phase 1.5 detail
- `/plan` — Phase 2 detail
- `/tdd` — Phase 3 detail
- `/verify` — Phase 4 detail
- `/review` — Phase 5 detail
- `/handoff` — if the feature spans multiple sessions
