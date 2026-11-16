---
name: using-template
description: Workflow router TEMPLATE for projects that install the workflow-skills plugin. Maps task descriptions to the smallest combination of skill / agent / prompt / instruction needed to do the work. This file is intentionally generic — copy it to a project as `.claude/skills/using-<project>/SKILL.md` and fill in the "Project routes" table with that project's real paths. Use at the start of any non-trivial change: when the user describes a task without naming a skill, asks for broad "help with X", or a handoff lands on an unfamiliar request — once per task, not mid-task. Read-only — does not execute work itself. Do NOT invoke this template as-is in a project that has its own `using-<project>` router — that one has the real routes.
---

<!--
====================================================================
TEMPLATE — DO NOT USE AS-IS.

This template ships with the workflow-skills plugin so any project can
adopt the routing pattern without rebuilding it from scratch.

To use in a project:

1. Copy this folder into your project at `.claude/skills/using-<project>/`
   (where `<project>` is your repo slug, e.g. `using-acme`, `using-mobile-app`).
2. Move NEW-PROJECT-TODO.md (sibling of this file) to your repo root and
   work through it.
3. Edit the frontmatter of the copied SKILL.md:
   - `name: using-<project>`
   - `description:` — keep the shape, but list real triggers from YOUR
     "Project routes" table. The description is what Claude Code uses
     for skill discovery, so concrete trigger phrases matter.
4. Fill in the "Project routes" table below with this project's real
   triggers → artifact paths.
5. Trim the "Concepts" bullet list to only the artifact kinds you use.
6. Update "Multi-stage chains" with whatever skills you actually have
   in the project (which may include skills from this plugin AND skills
   you've added locally).
7. Optional: remove this comment block and the "Adapting to another
   project" footer.
====================================================================
-->

## Concepts

A workflow router maps a task description to the smallest combination of artifacts that satisfies it. A typical project using this plugin has up to four kinds of agent-facing artifacts:

- **Claude Code skills** — invoked via the Skill tool. Some ship from the `workflow-skills` plugin (e.g., `/plan`, `/tdd`, `/review`); others are project-local in `.claude/skills/`. Plugin skills are namespaced in Claude Code: `/plan` here means `/workflow-skills:plan`.
- **Agent playbooks** in `agents/*.agent.md` — role-specific procedures (planner, builder, debugger, etc.). Project-defined.
- **Reusable prompts** in `prompts/*.prompt.md` — named starter prompts for repeating tasks (e.g., add-endpoint, bugfix-from-trace). Project-defined.
- **Scoped instructions** in `.github/instructions/*.instructions.md` — file-scoped rules, opened when a route names them. Project-defined.

`AGENTS.md` and the instructions files remain authoritative for the rules — this router only picks which tools execute the rules.

## Project routes <!-- ← edit this section per project -->

<!--
Example rows (delete and replace with your project's real triggers):

| User signal | Use this combination |
|---|---|
| "plan this", "before we start", complex change | `/plan` skill, [planner.agent.md](../../agents/planner.agent.md) |
| Architectural decision, multi-layer change | `/design` skill, [architect.agent.md](../../agents/architect.agent.md) |
| "new endpoint", "add an endpoint" | [add-endpoint.prompt.md](../../prompts/add-endpoint.prompt.md), [backend.instructions.md](../../.github/instructions/backend.instructions.md) |
| "schema change", "new migration" | [add-migration.prompt.md](../../prompts/add-migration.prompt.md), [migrations.instructions.md](../../.github/instructions/migrations.instructions.md) |
| "bugfix from trace", stack trace provided | [bugfix-from-trace.prompt.md](../../prompts/bugfix-from-trace.prompt.md), [debugger.agent.md](../../agents/debugger.agent.md) |
| "debug this", failing test, unexpected behaviour | `/diagnose` skill |
| "test first", red-green-refactor | `/tdd` skill |
| "write tests", "add tests for X" | [write-tests.prompt.md](../../prompts/write-tests.prompt.md), [test.agent.md](../../agents/test.agent.md) |
| "review this", "is this ready to merge?" | `/review` skill, [review.agent.md](../../agents/review.agent.md) |
| "is this safe?", security audit | `/security-review` skill, [security.agent.md](../../agents/security.agent.md) |
| Architecture health, tech debt check | `/zoom-out` skill |
| Full end-to-end feature | `/new-feature` skill |
| "handoff", session ending | `/handoff` skill |

-->

| User signal | Use this combination |
|---|---|
| _(fill this in per project — see commented example above)_ | |

## Multi-stage chains

For a larger feature, chain in this order:

1. `/clarify-requirements` → clarify requirements
2. `/design` if architectural, else skip
3. `/harden-plan` if domain terms or past decisions are at stake, else skip
4. `/plan` → concrete bite-sized tasks
5. `/tdd` per task → red-green-refactor
6. `/review` (or `/security-review` if sensitive code)
7. `/handoff` if stopping mid-feature

`/new-feature` orchestrates this end-to-end if you want one entry point.

## Rules

- Pick the smallest combination that satisfies the request. A single skill is enough for most asks.
- File-scoped instructions in `.github/instructions/` are *advisory* — they're not auto-loaded by Claude Code. When the trigger row names one, open it before editing files it scopes.
- Do not stack skills mid-turn. If the task shifts, finish the current step, then re-route.
- Skills and playbooks guide *execution*; `AGENTS.md` and instructions stay authoritative for the rules. Never override them.
- If nothing in the table fits, fall back to the standard workflow in `AGENTS.md`.
- This skill does no work. It is a router. Once you've picked, invoke the chosen skill / open the chosen prompt / read the chosen instruction, and proceed.

## Anti-patterns

- Loading two overlapping skills "to be safe" (e.g. `/plan` + `/new-feature`). Pick one.
- Carrying the router into the next turn. Route once per task.
- Inventing trigger phrases. If the user's request doesn't map cleanly, route to `AGENTS.md` and ask for clarification.
- Treating instructions as optional. If a row names one, open and apply it.
