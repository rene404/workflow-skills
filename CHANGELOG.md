# Changelog

All notable changes to workflow-skills will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows [SemVer](https://semver.org/).

## [Unreleased]

## [0.3.0] — 2026-11-16

Prepares the repo for being public: the documented install now works, the hook
survives real-world input, and the skills follow the rules in `AGENTS.md`.

### Changed

- **Install path rewritten; marketplace renamed `workflow-skills-dev` → `workflow-skills`.**
  The README showed `/plugin install workflow-skills@git+https://…`, which Claude Code
  does not accept: the part after `@` must be a registered marketplace name. Install is
  now `/plugin marketplace add rene404/workflow-skills` + `/plugin install
  workflow-skills@workflow-skills`, verified in a clean config from a local checkout and
  from GitHub (pinned via `#v0.2.0`). Anyone who added the old `workflow-skills-dev`
  marketplace must remove it and add the new one. Codex, Cursor and Copilot CLI install
  is now marked untested instead of showing commands nobody had run.
- **Routers live in `.claude/skills/using-<project>/`.** It is the only place Claude Code
  discovers project skills; a router in top-level `skills/` was injected by the hook but
  could not be invoked as `/using-<project>`. The hook checks `.claude/skills/` first and
  still reads `skills/` for existing setups.
- **Plugin skills are namespaced in Claude Code** (`/workflow-skills:plan`). The hook
  fallback, the router template and the `AGENTS.md` acceptance test now say so.
- **`tdd`, `new-feature`, `diagnose` no longer mandate commits.** They end at "ready to
  commit" and commit only when the user or project authorises it, instead of
  conflicting with harnesses that forbid unrequested commits.

### Fixed

- **Router not found when a session starts in a subdirectory.** Claude Code sets
  `CLAUDE_PROJECT_DIR` to the start directory, so a session opened in `backend/app`
  missed a router at the repo root. The hook now walks up to the git root, like Claude
  Code's own skill discovery; the closest router wins. Cursor runs plugin hooks from the
  plugin directory, so the start directory comes from `CURSOR_PROJECT_DIR` there.
- **One control character invalidated the whole hook payload.** Only `\ " \n \r \t`
  were escaped; a form feed in a router produced invalid JSON and the router was lost
  silently. All of 0x01–0x1F are now escaped. Escaping moved from bash substitution to
  awk, which also cut the hook from ~3 s to ~0.05 s on a 10 KB router under macOS
  bash 3.2.
- **Remaining stack references removed** from `security-review`, `review`, `tdd` and
  `verify` (SQLAlchemy `text()`, FastAPI dependencies, Alembic `upgrade head`,
  route → service → DB). 0.1.1 claimed they were gone.
- `plan` asked for a separate test task per change (a horizontal slice, against `tdd`);
  every task now carries its own test. `diagnose` no longer accepts a regression test
  "verified conceptually": it must be seen failing. `using-template` moved its triggers
  into the description and includes `/harden-plan` in its chain, like the hook.
- README documented Codex as getting top-level `additionalContext`; Codex reads
  `hooks/hooks.json` and gets the Claude Code shape.

### Added

- `tests/hook-test.sh` (19 cases: dialects, router lookup, escaping) and a CI workflow
  running it on Ubuntu and macOS (bash 3.2).
- `examples/`: real before/after Claude Code transcripts for `plan` and `verify`. `plan`
  changes the plan's shape; `verify` triggers but does not change the outcome on Opus
  5.5, which already re-runs tests.
- Attribution for `mattpocock/skills` (`harden-plan`) and `obra/superpowers`
  (`run-hook.cmd`), with their MIT copyright lines.

## [0.2.0] — 2026-09-21

### Changed

- **The SessionStart hook no longer injects `using-template`.** It now looks for a
  project-local router at `skills/using-<project>/SKILL.md` or
  `.claude/skills/using-<project>/SKILL.md` and injects that in full; when a project
  has none, it injects a slim fallback naming the available skills and the standard
  chain. Previously every session — customised or not — received the 6.8 KB template
  whose routing table is a single placeholder row, so uncustomised installs paid full
  context cost for a table that routed nothing. A project with its own router gets the
  same behaviour as before; one without drops from ~6,820 to ~961 characters.

  Minor rather than patch: the injected content changes for every consumer. The JSON
  output shape per harness is unchanged.
- **`design` states its shape assumption.** Its output template assumes a networked
  service over a relational store; the description now says so and tells the reader to
  map the headings to public surface / persisted state / compatibility for a CLI or
  library. The body is unchanged.

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
