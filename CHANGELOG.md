# Changelog

All notable changes to workflow-skills will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows [SemVer](https://semver.org/).

## [Unreleased]

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
