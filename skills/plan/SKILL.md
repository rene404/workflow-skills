---
name: plan
description: Write a detailed, bite-sized implementation plan before touching any code. Each task takes 2–5 minutes and has exact file paths, commands, and expected outcomes — no placeholders. Use when the user asks to plan a feature, says "before we start", wants a roadmap, or the task is complex enough that jumping straight to code would be risky. Do NOT write code while planning — present the plan first and wait for approval.
---

## Output format

Produce a numbered checklist. Each task must have:

```
### N. [Task title]

**Files:** `path/to/file.py`, `path/to/test_file.py`
**What:** [One sentence — exactly what changes]
**Command:** [Exact verification command]
**Done when:** [Observable, binary condition]
```

No "TBD", no "as needed", no vague descriptions. If you can't write a specific file path, you don't understand the task yet — ask a clarifying question.

## Process

### 1. Understand before planning

- Read the relevant files. Do not plan from memory.
- Check `CONTEXT.md` for domain vocabulary.
- If requirements are ambiguous, run `/clarify-requirements` first.

### 2. Identify the smallest safe change

- What is the minimum set of changes that delivers the requested behaviour?
- What can be deferred without breaking the delivery?
- What are the dependencies between tasks? Order them.

### 3. Write the plan

- Tasks must be **vertical slices** — each slice adds working, tested behaviour.
- Maximum 8 tasks per plan. If more are needed, split into phases.
- Include a migration task if any schema changes are required.
- Include a test task for every behaviour-changing task.

### 4. Present and wait

- Show the complete plan.
- Do not begin implementation until the user approves.
- If the user modifies the plan, update it and confirm before starting.

## Checklist before presenting

- [ ] Every task has an exact file path (no wildcards)
- [ ] Every task has a specific verification command
- [ ] Tasks are ordered by dependency (no task assumes a later task is done)
- [ ] Schema changes have a migration task
- [ ] Behaviour changes have a test task
- [ ] No task is vague or deferred with "TBD"

## Related

- `/clarify-requirements` — clarify requirements before planning
- `/tdd` — execute the plan using red-green-refactor
- `/verify` — confirm the full plan was executed correctly
