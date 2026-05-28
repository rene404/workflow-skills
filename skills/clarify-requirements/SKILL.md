---
name: clarify-requirements
description: Requirements clarification session — ask targeted questions to expose ambiguities, missing constraints, edge cases, and hidden assumptions before any planning or coding begins. Use when the user describes a feature or change but key details are unclear, when scope feels vague, or when the user says "clarify", "clarify requirements", "ask me questions first", "what do you need to know?", or "let's clarify before we plan". Do NOT write code or a plan during this skill — only ask and listen.
---

## Purpose

The cost of a wrong assumption is paid at the end of the task, when it's most
expensive to fix. Grilling surfaces those assumptions at the start, when
changing course is cheap.

## Process

### 1. Read first

Before asking anything:
- Read `CONTEXT.md` to understand domain vocabulary.
- Identify what you know vs. what you're assuming.
- List your assumptions internally — those become the clarifying questions.

### 2. Ask in rounds

**Round 1 — Scope and outcome**

Ask 3–5 questions that clarify the boundaries of success:
- "What does done look like for you?"
- "What should explicitly NOT change as a result of this?"
- "Who is the user / caller of this feature?"
- "Are there existing patterns in the codebase this should follow?"
- "What's the most important constraint? (performance, compatibility, simplicity)"

Wait for answers before proceeding.

**Round 2 — Edge cases and failure modes** (only if Round 1 reveals complexity)

- "What happens if [input is empty / user is unauthenticated / service is down]?"
- "Is [X] a hard requirement or a nice-to-have?"
- "Should this be reversible / rollback-safe?"

### 3. Confirm understanding

After the clarification, restate your understanding in one paragraph:

> "Based on what you've told me: [summary]. The scope is [X]. Out of scope: [Y]. Key constraints: [Z]. Is this correct?"

Only proceed to `/plan` or `/tdd` after the user confirms.

## Rules

- Ask in small batches (3–5 questions), not a wall of 15 at once.
- Never ask about things already answered in `CONTEXT.md`, `AGENTS.md`, or the codebase.
- Never propose solutions during clarification — that contaminates the answers.
- If the user can't answer a question, that itself is a finding worth noting.

## Related

- `/design` — use when clarification reveals the architecture is not yet decided
- `/harden-plan` — next step after design to stress-test the plan against the domain model
- `/plan` — next step when requirements and design are settled
