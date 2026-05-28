---
name: grill-with-docs
description: Stress-test a plan against the project's domain model — challenge terminology against CONTEXT.md, sharpen fuzzy language, cross-reference with code, and update CONTEXT.md inline as decisions crystallise. Creates ADRs for decisions that are hard-to-reverse, surprising without context, and the result of a real tradeoff. Use when the user has a plan or design to validate, says "grill with docs", or wants to align a design with the existing domain language. Do NOT use before a plan exists — use /grill-me first to clarify requirements.
---

## Purpose

A plan that uses imprecise language will produce imprecise code. Grilling with
docs forces every term to mean exactly one thing, recorded in CONTEXT.md so
the next session starts with shared vocabulary — not rediscovered assumptions.

## Process

Interview the user relentlessly about every aspect of the plan until you reach
a shared understanding. Walk down each branch of the design tree, resolving
dependencies between decisions one by one. Ask questions one at a time, waiting
for a response before continuing.

If a question can be answered by exploring the codebase, explore it instead of asking.

---

### 1. Read before asking

- Read `CONTEXT.md` — know the existing domain vocabulary.
- Read relevant source files for the area being designed.
- If `docs/adr/` exists, read recent ADRs for prior decisions.
- Identify where the plan uses terms that conflict with or are absent from `CONTEXT.md`.

---

### 2. Challenge terminology

When the plan uses a term that conflicts with or differs from `CONTEXT.md`:

> "Your glossary defines 'X' as [definition], but you're using it to mean [Y] — which is it?"

When the plan uses vague or overloaded language:

> "You're saying 'account' — do you mean the Customer or the User? Those are different things in CONTEXT.md."

---

### 3. Stress-test with scenarios

For each domain relationship in the plan, invent a concrete scenario that probes the boundary:

> "If a Customer cancels mid-Order, does the Order belong to Fulfillment or Ordering at that point?"

Force the user to be precise about ownership and edge cases.

---

### 4. Cross-reference with code

When the user states how something works, check whether the code agrees. Surface contradictions:

> "Your plan says partial cancellation is possible, but the code cancels entire Orders — which is right?"

---

### 5. Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` immediately — do not batch. Use the format in [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

Rules for CONTEXT.md:
- Glossary and domain boundaries only — no implementation details.
- One preferred term per concept; list aliases to avoid.
- Keep definitions to 1–2 sentences.

---

### 6. Offer ADRs sparingly

Only create an ADR when **all three** are true:

1. **Hard to reverse** — the cost of changing course later is meaningful.
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real tradeoff** — there were genuine alternatives and you chose one for specific reasons.

If any of the three is missing, skip the ADR. Use the format in [ADR-FORMAT.md](./ADR-FORMAT.md).

ADRs live in `docs/adr/` with sequential numbering: `0001-slug.md`, `0002-slug.md`.
Create the directory lazily — only when the first ADR is needed.

---

## Rules

- Ask one question at a time.
- Never propose solutions — ask questions that force the user to be precise.
- Update CONTEXT.md as you go, not at the end.
- Do not create an ADR unless all three criteria are met — ADRs are for the surprising and irreversible.
- Do not write implementation code during this session.

## Related

- `/grill-me` — use before this skill to clarify requirements and scope
- `/design` — use before this skill to produce the plan being grilled
- `/plan` — next step after grilling; turn the validated design into ordered tasks
