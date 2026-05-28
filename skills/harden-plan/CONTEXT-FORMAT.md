# CONTEXT.md Format

## Structure

```markdown
# {Context Name}

{One or two sentence description of what this context is and why it exists.}

## Language

**{Term}**:
{One or two sentence definition of what this term IS — not what it does.}
_Avoid_: {comma-separated list of synonyms to avoid}

**{Term}**:
{Definition}
_Avoid_: {alternatives}
```

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others under _Avoid_.
- **Keep definitions tight.** 1–2 sentences max. Define what it IS, not what it does.
- **Only project-specific terms.** General programming concepts (timeouts, error types, utility patterns) don't belong. Ask: is this unique to this project's domain? Only if yes does it belong.
- **No implementation details.** CONTEXT.md is a glossary, not a spec or scratch pad.
- **Resolve conflicts explicitly.** If a term is used ambiguously, call it out and resolve it.

## Single vs multi-context repos

**Single context (most repos):** one `CONTEXT.md` at the repo root.

**Multiple contexts:** a `CONTEXT-MAP.md` at the repo root lists contexts and relationships:

```markdown
# Context Map

## Contexts

- [{Name}](./{path}/CONTEXT.md) — {one sentence: what this context owns}

## Relationships

- **{A} → {B}**: {how they communicate or share data}
```

Create files lazily — only when you have something to write.
