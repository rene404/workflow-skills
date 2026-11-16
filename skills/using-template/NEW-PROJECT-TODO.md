# New project setup — agent config checklist

Drop this file into a fresh project and work through it top-to-bottom. Delete the file when every box is checked.

The end state: AGENTS.md is authoritative, CLAUDE.md is a thin adapter, and one router skill (`using-<project>`) maps task triggers to the smallest combination of skill / agent / prompt / instruction. The workflow-skills plugin's SessionStart hook injects that router into every Claude Code session.

Canonical paths in this layout:

- `.claude/skills/using-<slug>/` — the router. Claude Code only discovers project skills under `.claude/skills/`, and the plugin's hook looks there first.
- `.claude/skills/<name>/` — any project-local skills of your own
- `agents/`, `prompts/` at top level
- `.github/instructions/` — file-scoped rules (a GitHub Copilot convention; Claude Code reads them only when the router points at them)

---

## 0. Decide upfront

- [ ] Project slug for the router skill (kebab-case, e.g. `acme-api`, `mobile-app`). Used as `using-<slug>`.
- [ ] Which artifact kinds you'll use:
  - [ ] Skills — the plugin's, plus project-local ones in `.claude/skills/` — always on
  - [ ] `agents/*.agent.md` (role playbooks) — optional
  - [ ] `prompts/*.prompt.md` (named starter prompts) — optional
  - [ ] `.github/instructions/*.instructions.md` (file-scoped rules) — optional
- [ ] Domain vocab file (`CONTEXT.md`) — yes/no. Worth it once terminology starts drifting between code and docs.

## 1. Core docs at repo root

- [ ] `AGENTS.md` — source of truth. Sections to include at minimum:
  - [ ] One-paragraph project summary (stack, entry points, what the project *is*)
  - [ ] Instruction order (user request > AGENTS.md > instructions > playbooks/prompts)
  - [ ] **Routing section** — one short section pointing at `.claude/skills/using-<slug>/SKILL.md`
  - [ ] Golden rules (scope, secrets, tests, migrations, verification preference)
  - [ ] Repository layout (top-level dirs, what lives where — include `.claude/skills/`, `agents/`, `prompts/`)
  - [ ] Standard workflow (inspect → smallest change → tests → narrow verification → summarize)
  - [ ] Common commands (build, test, typecheck, migrate, run locally)
  - [ ] Definition of done
- [ ] `CLAUDE.md` — Claude-facing adapter. Should:
  - [ ] Point at `AGENTS.md` as authoritative
  - [ ] In "Start here": tell the agent to load `using-<slug>` skill first
  - [ ] Carry repo reminders + common commands (duplicating a short list from AGENTS.md is OK; keeping it copy-paste close beats a single link)
  - [ ] Carry response expectations (what to summarize at end of turn)
  - [ ] NOT carry the workflow table — that lives in the router skill
- [ ] `CONTEXT.md` (optional) — domain vocabulary table. Stack / Conventions / Boundaries sections.

## 2. Router skill

- [ ] Copy the plugin's `skills/using-template/` folder to `.claude/skills/using-<slug>/`
- [ ] Move (don't delete) `NEW-PROJECT-TODO.md` from the copy to the repo root — that's the working checklist you're filling out right now
- [ ] Edit `.claude/skills/using-<slug>/SKILL.md`:
  - [ ] Frontmatter `name:` → `using-<slug>`
  - [ ] Frontmatter `description:` → keep the shape, list real triggers from your new table (concrete phrases — Claude Code uses this for skill discovery)
  - [ ] Replace the "Project routes" table with your real triggers → artifact paths
  - [ ] Trim the "Concepts" bullet list to only the artifact kinds you actually use
  - [ ] Update "Multi-stage chains" with skills you actually have. Drop steps you don't.
  - [ ] Keep the "Rules" and "Anti-patterns" sections as-is
  - [ ] Remove the "Adapting to another project" footer (you've already done it)

## 3. Project-local skills (optional)

- [ ] The plugin's skills need no copying: once the plugin is installed they are available as `/workflow-skills:<name>`.
- [ ] Add a project-local skill in `.claude/skills/<name>/` only for something specific to this project, or to override a plugin skill with project vocabulary.
- [ ] Sanity-check each local skill's references to project-specific paths or commands.

## 4. Agent playbooks (`agents/`)

Skip this section if you opted out in step 0.

- [ ] Decide which roles you need (planner, builder, debugger, test, quality, review, security, release, docs are common).
- [ ] For each: write a short `*.agent.md` covering responsibilities, inputs it expects, outputs it produces, and constraints (what it does NOT do).
- [ ] Cross-reference: every agent that appears in the router table must exist as a file here.

## 5. Reusable prompts (`prompts/`)

Skip if you opted out.

- [ ] List the *named tasks* your team does often (e.g., "add-endpoint", "bugfix-from-trace", "ci-failure-triage").
- [ ] One `*.prompt.md` per named task. Include: context the agent needs, the prompt body, expected output shape.
- [ ] Cross-reference: every prompt in the router table must exist.

## 6. File-scoped instructions (`.github/instructions/`)

Skip if you opted out. Note: these are advisory — Claude Code does not auto-load them.

- [ ] Identify file patterns that need their own rules (e.g., `backend/`, `frontend/`, `tests/`, `*.sql`, `Dockerfile`).
- [ ] One `*.instructions.md` per scope. Each one covers conventions, dos and don'ts, common pitfalls.
- [ ] Reference the relevant instructions from the router table so the agent opens them at the right moment.

## 7. Plugin and hook

- [ ] Install the workflow-skills plugin (see its README). Its SessionStart hook finds `.claude/skills/using-<slug>/SKILL.md` on its own, walking up from the session's directory to the git root. Nothing to copy or configure.
- [ ] Smoke-test the hook from the project root: `CLAUDE_PLUGIN_ROOT=x bash <plugin-path>/hooks/run-hook.cmd session-start | python3 -m json.tool` → valid JSON whose `hookSpecificOutput.additionalContext` names your router.

## 8. Local settings

- [ ] `.claude/settings.json` — project permissions allowlist (what Bash / WebFetch / MCP calls auto-allow). Start empty; add via `/fewer-permission-prompts` once you've run a few sessions.
- [ ] `.claude/settings.local.json` — local overrides (gitignored). Personal permission tweaks here, not in shared settings.

## 9. Verify the setup

- [ ] Open a fresh Claude Code session in the project. Confirm the router is in context (ask "which router are you using?").
- [ ] Ask a vague question that should route somewhere ("how should I add a new endpoint?"). Expect the agent to follow `using-<slug>`, return the right combination (prompt + instruction + agent), and then proceed.
- [ ] Ask for a code review on a small diff. Expect the `review` skill to be invoked.
- [ ] Ask "is this safe?" on auth-touching code. Expect `security-review`.
- [ ] If the agent skips the router and goes straight to code — check that CLAUDE.md actually says "load `using-<slug>` first" and that the skill's `description:` lists realistic triggers.

## 10. Clean up

- [ ] Delete this `NEW-PROJECT-TODO.md` file from the repo root.
- [ ] Commit. Suggested message: `chore: bootstrap agent config (AGENTS.md, CLAUDE.md, using-<slug> router)`.

## Common adaptations

| Project type | Adaptations |
|---|---|
| **No backend / static site** | Drop `backend.instructions.md` rows, `add-migration.prompt.md`, database commands from CLAUDE.md. |
| **Monorepo** | Add per-package instructions in `.github/instructions/`. Router rows may need package-name qualifiers. A package can carry its own `.claude/skills/using-<pkg>/`; the hook picks the router closest to where the session starts. |
| **Library, no app** | Drop "run the app" triggers. Replace with package-publish workflow. |
| **No Docker** | Update common commands. Drop `/devops` rows that reference Compose. |
| **No `.github/instructions/`** | Move scoped rules into the relevant skill or instruction-style sections inside `AGENTS.md`. |
