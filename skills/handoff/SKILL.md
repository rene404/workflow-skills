---
name: handoff
description: Generate a structured handoff document that captures the current state of work so the next session (or another agent) can continue without losing context. Use when the user says "handoff", "I need to stop here", "summarise where we are", "create a handoff", or the session is ending mid-task. Argument hint: optional topic or branch name to scope the handoff.
argument-hint: [optional: topic or branch name]
---

## Purpose

Context is expensive to rebuild. A good handoff pays for itself in the first
five minutes of the next session.

## Output format

Produce a handoff document with these sections:

```markdown
# Handoff — [topic or branch] — [date]

## What we were doing
[One paragraph: the goal, why it matters, where it fits in the project]

## Current state
- **Status:** [In progress / Blocked / Ready for review / Other]
- **Branch:** `[branch name]`
- **Last commit:** [hash + message]
- **Uncommitted changes:** [list files, or "none"]

## What was completed
- [Checked item 1]
- [Checked item 2]

## What remains
- [ ] [Next step 1] — [why / what to watch out for]
- [ ] [Next step 2]

## Key decisions made
- **[Decision]:** [Rationale] — [Alternatives considered]

## Known risks and blockers
- [Risk or blocker]: [Impact and mitigation]

## How to resume
[Exact commands to get back to a working state]
```bash
git checkout [branch]
docker compose up -d
# [any other setup steps]
```

## Files to read first
- `[path]` — [why this file is important to the task]
```

## Rules

- Be specific. Vague handoffs waste more time than no handoff.
- List exact file paths, branch names, and commands — not descriptions.
- If there are unresolved questions, list them explicitly.
- Do not include information that can be derived from `git log` or reading the code.

## Related

- `/plan` — if the remaining work needs to be planned before the next session starts
- `/verify` — run this first if the session ended mid-verification
