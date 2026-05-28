# workflow-skills

Stack-agnostic methodology skills for coding agents — planning, design, TDD, systematic debugging, verification, code review, security review, handoff — plus a workflow router template that maps task descriptions to the smallest combination of skill / agent / prompt / instruction.

Works in Claude Code, Codex, Cursor, and Copilot CLI through per-harness plugin manifests and a single cross-dialect SessionStart hook.

## What's in the box

- **14 skills** (in `skills/`):
  - `plan` — bite-sized implementation plan before any code
  - `tdd` — red-green-refactor
  - `verify` — fresh end-to-end verification before declaring done
  - `review` — structured correctness + coverage + conventions review
  - `security-review` — deep security audit (secrets, auth, injection, path traversal)
  - `diagnose` — systematic debugging loop
  - `design` — minimal technical design before planning
  - `clarify-requirements` — requirements clarification
  - `harden-plan` — stress-test a plan against project docs + create ADRs
  - `new-feature` — full end-to-end orchestration
  - `handoff` — structured handoff document
  - `zoom-out` — architecture health review
  - `devops` — safely change infrastructure/CI/CD/deployment
  - `write-skill` — author a new skill following these conventions
- **`using-template`** — a router skill template. Copy it into your project as `skills/using-<project>/` and fill in the routing table.
- **Cross-harness plugin manifests** for Claude Code (`.claude-plugin/`), Codex (`.codex-plugin/`), and Cursor (`.cursor-plugin/`).
- **SessionStart hook** (`hooks/session-start` + `hooks/run-hook.cmd`) that injects the router into the agent's context, emitting the right JSON dialect per harness.

## What's NOT in the box (and why)

This plugin ships methodology only — no stack-specific agents, prompts, or instructions. The `agents/` and `prompts/` patterns are project-defined; the `using-template` skill shows you how to layer them on top.

That's a deliberate choice: agent playbooks and reusable prompts in real projects always end up referencing the specific stack (FastAPI, Rails, Vue, etc.). Shipping them generically either degrades the content (vague placeholders) or hides the assumption. Better to keep them in each consuming project, where they're tuned to that stack.

## Install

### Claude Code

```sh
# from a git URL:
/plugin install workflow-skills@git+https://github.com/reneworndl/workflow-skills.git

# or from a local checkout (dev marketplace):
/plugin marketplace add /path/to/workflow-skills
/plugin install workflow-skills@workflow-skills-dev
```

The SessionStart hook fires on `startup | clear | compact` and injects the router into context.

### Codex

```sh
codex plugins install workflow-skills@git+https://github.com/reneworndl/workflow-skills.git
```

For marketplace distribution, see [docs/codex-marketplace.md](docs/codex-marketplace.md) (you submit a PR to OpenAI's `openai-codex-plugins` repo — see [obra/superpowers' sync script](https://github.com/obra/superpowers/blob/main/scripts/sync-to-codex-plugin.sh) for the pattern).

### Cursor

Add to your project's `.cursor/config`:

```json
{
  "plugins": ["workflow-skills@git+https://github.com/reneworndl/workflow-skills.git"]
}
```

### Copilot CLI

```sh
copilot plugin install workflow-skills@git+https://github.com/reneworndl/workflow-skills.git
```

## Using in a project

Once installed, the skills auto-trigger on their description triggers (e.g., user says "plan this" → `/plan`). To get the routing-table experience for your specific project, copy the `using-template` skill:

```sh
cp -r ~/.claude/plugins/workflow-skills/skills/using-template /your/project/skills/using-<your-project>
cd /your/project
mv skills/using-<your-project>/NEW-PROJECT-TODO.md ./NEW-PROJECT-TODO.md
```

Then work through `NEW-PROJECT-TODO.md`. It walks you through:

1. Filling in the router's "Project routes" table with your real triggers → artifact paths
2. Wiring `AGENTS.md` to point at the router (so Codex finds it)
3. Wiring `CLAUDE.md` to load the router first
4. Adding `agents/`, `prompts/`, `.github/instructions/` as needed
5. Smoke-testing the hook in each harness

## How the multi-harness session-start works

`hooks/session-start` is a single bash script that:

1. Reads the `using-template/SKILL.md` (the router) from this plugin
2. Detects which harness is invoking it via env vars (`CURSOR_PLUGIN_ROOT`, `CLAUDE_PLUGIN_ROOT`, `COPILOT_CLI`)
3. Emits the JSON shape that harness expects:
   - Cursor → `additional_context` (snake_case top-level)
   - Claude Code → `hookSpecificOutput.additionalContext` (nested)
   - Codex / Copilot CLI / SDK-standard → `additionalContext` (camelCase top-level)

`hooks/run-hook.cmd` is a polyglot Unix bash + Windows `.cmd` wrapper so the hook also works under Git Bash on Windows.

This pattern is borrowed from [obra/superpowers](https://github.com/obra/superpowers); credit where due.

## Versioning

Tagged releases. Consuming projects should pin to a tag (e.g., `v0.1.0`) until you're ready to track changes:

```
/plugin install workflow-skills@git+https://github.com/reneworndl/workflow-skills.git#v0.1.0
```

Breaking changes (skill renames, removed skills) get a major version bump. New skills get a minor bump. Fixes/wording get a patch bump.

## Adding a skill

Use the `/write-skill` skill (yes, the plugin ships a skill for authoring skills). Each skill is `skills/<name>/SKILL.md` with YAML frontmatter:

```markdown
---
name: <name>
description: One-paragraph description. The first sentence is what the agent sees when deciding whether to invoke. Include concrete trigger phrases the user might say.
---

## What this skill does

(body of the skill — markdown)
```

See `skills/write-skill/SKILL.md` for the conventions.

## Contributing

See [AGENTS.md](AGENTS.md).

## License

MIT — see [LICENSE](LICENSE).

## Acknowledgements

Heavily inspired by [obra/superpowers](https://github.com/obra/superpowers). The cross-harness hook pattern, the marketplace structure, and the "skills as behavior-shaping markdown" philosophy all come from there.
