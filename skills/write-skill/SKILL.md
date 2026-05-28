---
name: write-skill
description: Create a new skill following the project's skill conventions — correct frontmatter, SKILL.md structure, and plugin.json registration. Use when the user wants to add a new skill, says "write a skill for X", or needs to capture a repeatable workflow as a reusable skill. Do NOT use for one-time operations, project-specific scripts, or workflows already covered by an existing skill.
---

## When to create a skill

A skill is worth creating when:
- The workflow recurs across tasks or projects.
- The steps are non-obvious and easy to get wrong.
- There is a clear trigger phrase (what the user says to invoke it).
- It is general enough to work outside the current task's context.

Do not create a skill for a one-time operation, a project-specific script, or
something that is already covered by an existing skill.

## Process

### 1. Define the skill

Answer these before writing a single line:
- **Name:** kebab-case identifier (matches directory name)
- **Trigger:** What does the user say or do that should invoke this skill?
- **Problem:** What failure mode or inefficiency does this skill prevent?
- **Scope:** What is explicitly out of scope for this skill?
- **Related skills:** What skills does this complement or hand off to?

### 2. Write the description

The description is the **only thing the agent reads when deciding whether to load this skill**.

Rules:
- Max 1,024 characters.
- Written in third person.
- Must include explicit "Use when..." trigger phrases.
- Must include "Do NOT use when..." anti-triggers if ambiguity exists.
- Be specific — vague descriptions cause incorrect activation.

Template:
```
[What the skill does in one sentence]. Use when [explicit triggers]. Do NOT use when [anti-triggers].
```

### 3. Write SKILL.md

```markdown
---
name: [kebab-case]
description: [description from Step 2]
argument-hint: [optional — what argument the user can pass]
---

## [Philosophy or purpose — one line]

[Brief philosophy statement]

## [Main section]

[Numbered steps or phases]

## Rules / Anti-patterns

[What NOT to do — at least 2–3 explicit rules]

## Related

- `/skill-name` — [relationship]
```

### 4. Create the directory and register

```
skills/[category]/[skill-name]/SKILL.md
```

Categories: `engineering`, `productivity`, `workflow`

Add the path to `plugin.json`:
```json
"./skills/[category]/[skill-name]"
```

### 5. Test the description

Read the description aloud. Ask: "If I were the agent and only saw this text,
would I know exactly when to use this skill and when not to?" If no, rewrite.

## Checklist

- [ ] Name is kebab-case and matches the directory
- [ ] Description has explicit "Use when..." triggers
- [ ] Description has "Do NOT use when..." if needed
- [ ] SKILL.md has a philosophy/purpose statement
- [ ] SKILL.md has numbered phases or steps
- [ ] SKILL.md has at least 2 anti-pattern rules
- [ ] SKILL.md has a "Related" section
- [ ] Directory created under correct category
- [ ] `plugin.json` updated with new path

## Related

- `/plan` — if the skill requires companion scripts or supporting files
- `/review` — review the skill file before committing
