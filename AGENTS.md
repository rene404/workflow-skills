# AGENTS.md — workflow-skills contributor guide

This file is the source of truth for agent work in this repository.

`workflow-skills` is a methodology plugin: it ships skills (behavior-shaping markdown), plugin manifests for Claude Code / Codex / Cursor, and a session-start hook that bootstraps a router across harnesses.

## Goals

- **Stack-agnostic.** Skills must work for any project (FastAPI, Rails, Next.js, Rust CLI, anything). If a skill references one stack, generalise it.
- **Methodology only.** Concrete agent playbooks, project-specific prompts, and file-scoped instructions belong in consuming projects, not here.
- **One skill = one job.** No skill should overlap with another. If two skills both match a request, the descriptions are wrong.
- **Behavior over prose.** Skills exist to change agent behavior. If a skill doesn't measurably change what the agent does, delete it.

## Repository layout

- `skills/` — methodology skills (one folder per skill, each containing `SKILL.md` + optional `references/`)
- `skills/using-template/` — router skill template + `NEW-PROJECT-TODO.md` checklist consumers use to adopt the plugin
- `.claude-plugin/`, `.codex-plugin/`, `.cursor-plugin/` — per-harness plugin manifests
- `hooks/` — `session-start` (bash), `run-hook.cmd` (polyglot wrapper), `hooks.json` (Claude), `hooks-cursor.json` (Cursor)
- `README.md` — installation + usage docs
- `CHANGELOG.md` — releases
- `LICENSE` — MIT

## Adding or modifying a skill

1. Use the `/write-skill` skill (it ships in `skills/write-skill/`).
2. Frontmatter must include:
   - `name` — kebab-case, matches the folder name
   - `description` — one paragraph. The first sentence is what the agent sees during skill selection. Include concrete trigger phrases the user might say. Include "Do NOT use for X" if there's a close alternative.
3. Body sections (order matters for readability):
   - What this skill does (1-2 sentences)
   - When to use (concrete triggers)
   - When NOT to use (close alternatives)
   - The actual methodology / procedure
   - Anti-patterns
4. **No stack references** in the body. If you need an example, use `<migrate>` or "your test runner" not `alembic` or `pytest`.
5. **Test the skill** in at least one harness before merging. If it doesn't change observable behavior, it doesn't ship.

## Adding a new harness

1. Add a manifest at `.<harness>-plugin/plugin.json`. Follow that harness's conventions for the manifest shape.
2. Add a hook output branch to `hooks/session-start` that matches the harness's env var (`<HARNESS>_PLUGIN_ROOT` or similar) and emits the JSON shape that harness expects.
3. Add a `hooks/hooks-<harness>.json` if the harness uses a separate config file.
4. **Acceptance test**: open a clean session in the new harness, send `"plan a new feature for me"`, confirm `/plan` auto-triggers and the user is asked clarifying questions before any code is written.
5. Update `README.md` install section.

## What not to add

- **Stack-specific skills** (e.g., "fastapi-add-endpoint") — these belong in consuming projects.
- **Project-specific agent playbooks** — these belong in consuming projects.
- **Third-party dependencies** — the plugin must be zero-dep (bash + markdown only).
- **Multiple skills for the same job** — overlap is a bug.
- **Skills without test transcripts** — if you can't show before/after behavior change, the skill isn't pulling its weight.

## Versioning

Semver-ish:

- **Patch (`0.1.x`)** — wording fixes, doc clarifications, hook bugfixes
- **Minor (`0.x.0`)** — new skill added, new harness supported
- **Major (`x.0.0`)** — skill renamed/removed (consumer routers break), hook output format changed, frontmatter schema changed

Bump in `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `.cursor-plugin/plugin.json`, `.claude-plugin/marketplace.json`, and `CHANGELOG.md` in one commit. Tag the release.

## Workflow

For non-trivial changes, the skills in this very repo apply:

1. `/plan` — sketch the change
2. `/tdd` if relevant (most skill changes don't need tests — they need transcripts)
3. `/verify` — open a session, run the trigger phrase, confirm behavior changed as intended
4. `/review` — your diff before opening a PR

## Definition of done

- Skill (or hook, or manifest) does what its description says
- Behavior change demonstrated in at least one harness session (paste the transcript in the PR)
- README updated if install steps changed
- CHANGELOG updated
- Version bumped if the surface changed
