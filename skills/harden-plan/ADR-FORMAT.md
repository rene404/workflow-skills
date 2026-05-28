# ADR Format

ADRs live in `docs/adr/` with sequential numbering: `0001-slug.md`, `0002-slug.md`.

Create the `docs/adr/` directory lazily — only when the first ADR is needed.

## Template

```markdown
# {Short title of the decision}

{1–3 sentences: what's the context, what did we decide, and why.}
```

That's it. An ADR can be a single paragraph. The value is in recording *that* a decision
was made and *why* — not in filling out sections.

## Optional sections

Only include when they add genuine value. Most ADRs won't need them.

- **Status** (`proposed | accepted | deprecated | superseded by ADR-NNNN`) — useful when decisions are revisited.
- **Considered Options** — only when rejected alternatives are worth remembering.
- **Consequences** — only when non-obvious downstream effects need to be called out.

## When to create an ADR

All three must be true:

1. **Hard to reverse** — the cost of changing course later is meaningful.
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real tradeoff** — there were genuine alternatives and you picked one for specific reasons.

### What qualifies

- Architectural shape ("the write model is event-sourced, the read model is projected into Postgres")
- Integration patterns ("Ordering and Billing communicate via domain events, not HTTP")
- Technology choices that carry lock-in (database, auth provider, deployment target)
- Boundary and scope decisions ("Customer data is owned by Customer context; others reference by ID only")
- Deliberate deviations from the obvious path ("we use raw SQL instead of ORM because X")
- Constraints not visible in the code ("we can't use X because of compliance requirements")
- Rejected alternatives when the rejection is non-obvious

### What does NOT qualify

- Easy-to-reverse decisions
- Obvious choices where there was no real alternative
- Implementation details (belongs in comments, not ADRs)
- General coding conventions (belongs in instructions files)
