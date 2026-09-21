# Changelog

All notable changes to workflow-skills will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows [SemVer](https://semver.org/).

## [Unreleased]

## [0.1.1] — 2026-09-21

### Fixed

- **`write-skill` documented a layout this repo does not use.** It prescribed
  `skills/<category>/<skill-name>/` and told the author to register a per-skill path
  in `plugin.json`. The layout is flat, Claude Code auto-discovers `skills/`, and the
  Codex/Cursor manifests point at the directory once — following the old step produced
  a misplaced skill and a broken manifest. Its checklist now also covers the README
  skill list and CHANGELOG entry that `AGENTS.md` already required.
- **Stack assumptions removed from the core loop.** `verify` hardcoded
  `docker compose` + `pytest` + `npm`, and `tdd` and `new-feature` repeated them, so
  projects on other stacks got a checklist they could not run. They now use the
  project's documented command and ask rather than guess. `plan`'s example paths and
  `security-review`'s `subprocess`/`os.system` reference are language-neutral.
- **`devops` scope made honest.** Docker Compose and GitHub Actions are now stated as
  worked examples rather than requirements, and the hand-off to a "Release Manager
  agent" — which ships nowhere in this plugin — is gone.
- **`new-feature` phase order corrected.** Design ran before Clarify, contradicting
  both skills it orchestrates. Clarify is now Phase 1, Design the optional Phase 2.
- **`handoff` rendering and self-contradiction.** A nested ` ```bash ` block closed the
  outer ` ```markdown ` fence early, so the tail of the template rendered as live
  headings; the wrapper is now `~~~markdown`. Its rule against `git log`-derivable
  information contradicted its own "Last commit" field, and the description duplicated
  the `argument-hint` frontmatter.
- **`review` no longer stops at the first High finding**, which made its own
  five-dimension output format unreachable.
- **`CONTEXT.md` treated as optional** in `plan`, `clarify-requirements`, `review` and
  `zoom-out`. It is created lazily by `/harden-plan`, so four skills previously opened
  with a failed file read in any fresh project.
- **Missing anti-triggers added** for `zoom-out`, `verify`, `handoff` and the router;
  `tdd`'s pointed at the wrong case (a failing test is TDD's GREEN step, not an
  exclusion) and now points at not knowing *why* something fails.
- **`AGENTS.md` body-structure rule** demanded "When to use" / "When NOT to use"
  sections that no skill has ever had. It now describes the real convention and says
  why triggers belong in the description.
- Removed the stray `.copilot-plugin/plugin.json`. It was created by accident in
  `d3e3c99`, whose own message and changelog entry state that Copilot CLI reuses the
  Codex/SDK-standard hook output and needs no manifest of its own. The stub carried no
  `skills` or `hooks` pointer, so it was non-functional regardless.
- `README.md` linked to `docs/codex-marketplace.md`, which does not exist. The
  marketplace note is now inline.

## [0.1.0] — 2026-09-18

### Added

- **14 stack-agnostic methodology skills** in `skills/`:
  `plan`, `tdd`, `verify`, `review`, `security-review`, `diagnose`, `design`,
  `clarify-requirements`, `harden-plan`, `new-feature`, `handoff`, `zoom-out`,
  `devops`, `write-skill`.
- **`using-template`** — router skill template + new-project setup checklist (`NEW-PROJECT-TODO.md`).
- **Per-harness plugin manifests**: `.claude-plugin/plugin.json` + `marketplace.json`, `.codex-plugin/plugin.json`, `.cursor-plugin/plugin.json`.
- **Cross-harness SessionStart hook**: `hooks/session-start` (bash), `hooks/run-hook.cmd` (polyglot Unix/Windows wrapper), `hooks/hooks.json` (Claude Code), `hooks/hooks-cursor.json` (Cursor). Emits the right JSON dialect per harness based on env vars.
- **Docs**: `README.md`, `AGENTS.md` contributor guide, MIT `LICENSE`.

### Fixed

- Repository URLs in `README.md` install commands and in the Claude / Codex / Cursor
  plugin manifests pointed at a non-existent `reneworndl/workflow-skills`; they now
  point at `rene404/workflow-skills`, so the documented install commands work.
- `AGENTS.md` was missing Copilot CLI from the harness summary line and repository
  layout note, even though `README.md` and `hooks/session-start` already supported it
  via the Codex/SDK-standard JSON shape. Docs are now in sync.

### Notes

- Plugin is methodology-only by design. Stack-specific agents, prompts, and instructions belong in consuming projects.
- Cross-harness hook pattern borrowed from [obra/superpowers](https://github.com/obra/superpowers).
