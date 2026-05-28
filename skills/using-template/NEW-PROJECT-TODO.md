# New project setup — agent config checklist

Drop this file into a fresh project and work through it top-to-bottom. Delete the file when every box is checked.

The end state matches the rene404 setup: AGENTS.md is authoritative, CLAUDE.md is a thin adapter, one router skill (`using-<project>`) maps task triggers to the smallest combination of skill / agent / prompt / instruction, and plugin manifests let Claude Code AND Codex (and Cursor / Copilot CLI) bootstrap the same router.

Canonical paths in this layout:

- `skills/` (top-level) — canonical home for Claude Code skills, also referenced by `.codex-plugin/` and `.cursor-plugin/`
- `.claude/skills/ → ../skills/` — optional symlink that lets Claude Code auto-discover skills when you open the repo (without installing the plugin)
- `agents/`, `prompts/` at top level
- `.github/instructions/` stays in `.github/` — GitHub Copilot convention

---

## 0. Decide upfront

- [ ] Project slug for the router skill (kebab-case, e.g. `acme-api`, `mobile-app`). Used as `using-<slug>` and as the `name` in both plugin manifests.
- [ ] Which artifact kinds you'll use:
  - [ ] `skills/` (Claude Code skills + Codex/Cursor plugin skills) — recommended, always on
  - [ ] `agents/*.agent.md` (role playbooks) — optional
  - [ ] `prompts/*.prompt.md` (named starter prompts) — optional
  - [ ] `.github/instructions/*.instructions.md` (file-scoped Copilot-style rules) — optional, only if you also use GitHub Copilot
- [ ] Which harnesses you need to support:
  - [ ] Claude Code (always)
  - [ ] Codex
  - [ ] Cursor
  - [ ] Copilot CLI / other SDK-standard tools
- [ ] Domain vocab file (`CONTEXT.md`) — yes/no. Worth it once terminology starts drifting between code and docs.

## 1. Core docs at repo root

- [ ] `AGENTS.md` — source of truth. Sections to include at minimum:
  - [ ] One-paragraph project summary (stack, entry points, what the project *is*)
  - [ ] Instruction order (user request > AGENTS.md > instructions > playbooks/prompts)
  - [ ] **Routing section** — one short section pointing at `skills/using-<slug>/SKILL.md` so Codex (which only reads AGENTS.md) sees the router entry point
  - [ ] Golden rules (scope, secrets, tests, migrations, verification preference)
  - [ ] Repository layout (top-level dirs, what lives where — include `skills/`, `agents/`, `prompts/`, `hooks/`)
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

- [ ] `cp -r <path-to-rene404>/skills/using-rene404/ <new-repo>/skills/using-<slug>/`
- [ ] Move (don't delete) `NEW-PROJECT-TODO.md` from the copy to the repo root — that's the working checklist you're filling out right now
- [ ] Edit `skills/using-<slug>/SKILL.md`:
  - [ ] Frontmatter `name:` → `using-<slug>`
  - [ ] Frontmatter `description:` → keep the shape, list real triggers from your new table (concrete phrases — Claude Code uses this for skill discovery)
  - [ ] Replace the "Project routes" table with your real triggers → artifact paths
  - [ ] Trim the "Concepts" bullet list to only the artifact kinds you actually use
  - [ ] Update "Multi-stage chains" with skills you actually have. Drop steps you don't.
  - [ ] Keep "When to use this skill", "Rules", "Anti-patterns" sections as-is
  - [ ] Remove the "Adapting to another project" footer (you've already done it)
- [ ] If you're keeping the `.claude/skills/ → ../skills/` symlink, create it:
  - [ ] `cd .claude && ln -s ../skills skills && cd ..`
  - [ ] `git add .claude/skills`
  - [ ] Skip this step if you'd rather install the plugin via marketplace and not pollute `.claude/`.

## 3. Skills (`skills/`)

- [ ] Decide which skills to bring over. Sensible defaults: `plan`, `tdd`, `verify`, `review`, `diagnose`, `handoff`. Optional: `design`, `grill-me`, `new-feature`, `security-review`, `zoom-out`.
- [ ] Copy each chosen skill's folder into `skills/`. Edit the frontmatter `description:` if the project's vocabulary differs.
- [ ] Sanity-check each skill's references to project-specific paths or commands.

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

Skip if you opted out. Note: these are advisory — Claude Code does not auto-load them. GitHub Copilot does.

- [ ] Identify file patterns that need their own rules (e.g., `backend/`, `frontend/`, `tests/`, `*.sql`, `Dockerfile`).
- [ ] One `*.instructions.md` per scope. Each one covers conventions, dos and don'ts, common pitfalls.
- [ ] Reference the relevant instructions from the router table so the agent opens them at the right moment.

## 7. Cross-harness plugin manifests + hooks

This is what makes the same routing work across Claude Code, Codex, Cursor, and Copilot CLI.

- [ ] `.claude-plugin/plugin.json` — minimal Claude Code plugin manifest (`name`, `description`, `version`, repo metadata). Copy from rene404 and rename.
- [ ] `.claude-plugin/marketplace.json` — local marketplace stub so you can `/plugin install <slug>@<slug>-dev` from this checkout. Update `name`, `owner`, and the inner plugin entry.
- [ ] `.codex-plugin/plugin.json` — Codex marketplace listing. Includes an `interface` block (displayName, brandColor, defaultPrompt) for the Codex marketplace UI. Update slug, description, brand color, default prompts.
- [ ] `.cursor-plugin/plugin.json` (only if supporting Cursor) — Cursor's manifest with `skills`, `agents`, `commands`, `hooks` paths.
- [ ] `hooks/session-start` — bash hook that injects the router at session start. Copy from rene404; the only edit needed is the path to your router skill (`skills/using-<slug>/SKILL.md`).
- [ ] `hooks/run-hook.cmd` — polyglot bash/.cmd wrapper for Windows. Copy verbatim.
- [ ] `hooks/hooks.json` — Claude Code SessionStart registration. Copy verbatim.
- [ ] `chmod +x hooks/session-start hooks/run-hook.cmd`
- [ ] Smoke-test the hook locally:
  - [ ] `CLAUDE_PLUGIN_ROOT="$(pwd)" ./hooks/run-hook.cmd session-start | python3 -m json.tool` → valid JSON with `hookSpecificOutput.additionalContext`
  - [ ] `CODEX_PLUGIN_ROOT="$(pwd)" ./hooks/run-hook.cmd session-start | python3 -m json.tool` → valid JSON with `additionalContext`
  - [ ] `CURSOR_PLUGIN_ROOT="$(pwd)" ./hooks/run-hook.cmd session-start | python3 -m json.tool` → valid JSON with `additional_context`

## 8. Local settings

- [ ] `.claude/settings.json` — project permissions allowlist (what Bash / WebFetch / MCP calls auto-allow). Start empty; add via `/fewer-permission-prompts` once you've run a few sessions.
- [ ] `.claude/settings.local.json` — local overrides (gitignored). Personal permission tweaks here, not in shared settings.

## 9. Verify the setup

### Claude Code (project-local, via symlink or auto-discovery)

- [ ] Open a fresh Claude Code session in the project.
- [ ] Ask a vague question that should route somewhere ("how should I add a new endpoint?"). Expect the agent to invoke `using-<slug>`, return the right combination (prompt + instruction + agent), and then proceed.
- [ ] Ask for a code review on a small diff. Expect `/review` to be invoked.
- [ ] Ask "is this safe?" on auth-touching code. Expect `/security-review`.
- [ ] If the agent skips the router and goes straight to code — check that CLAUDE.md actually says "load `using-<slug>` first" and that the skill's `description:` lists realistic triggers.

### Claude Code (plugin install path)

- [ ] `/plugin install <slug>@<slug>-dev` (uses your `.claude-plugin/marketplace.json`)
- [ ] Confirm the SessionStart hook fires on next `/clear` — the router content should be injected as additional context.

### Codex (reading AGENTS.md)

- [ ] Open the repo in Codex. Send: "Let's add a new endpoint for X."
- [ ] Expect Codex to read AGENTS.md → notice the Routing section → open `skills/using-<slug>/SKILL.md` → find the matching row → propose the right combination.
- [ ] If Codex skips the router: check that AGENTS.md's Routing section explicitly names the file with a relative path, and that the section is high in the document (after Instruction order, before Golden rules).

### Codex (plugin install path)

- [ ] If you've published to the OpenAI Codex marketplace, install via Codex's plugin UI. Confirm the SessionStart hook fires and the router is in context.

## 10. Clean up

- [ ] Delete this `NEW-PROJECT-TODO.md` file from the repo root.
- [ ] Commit. Suggested message: `chore: bootstrap agent config (AGENTS.md, CLAUDE.md, using-<slug> router, plugin manifests, session-start hook)`.

## Common adaptations

| Project type | Adaptations |
|---|---|
| **No backend / static site** | Drop `backend.instructions.md` rows, `add-migration.prompt.md`, database commands from CLAUDE.md. |
| **Monorepo** | Add per-package instructions in `.github/instructions/`. Router rows may need package-name qualifiers. |
| **Library, no app** | Drop "run the app" / `/verify` triggers. Replace with package-publish workflow. |
| **No Docker** | Update common commands. Drop `/devops` rows that reference Compose. |
| **No GitHub Copilot** | Drop `.github/instructions/` entirely. Move scoped rules into the relevant skill or instruction-style sections inside `AGENTS.md`. |
| **Claude Code only, no Codex/Cursor** | Skip section 7 entirely. Project-local `.claude/skills/` is enough. |
| **No symlink** (clean repo root only) | Skip the `.claude/skills` symlink step. Install the plugin via marketplace (`.claude-plugin/marketplace.json`) instead — the SessionStart hook handles bootstrapping. |
