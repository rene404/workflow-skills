# workflow-skills

Stack-agnostic methodology skills for coding agents — planning, design, TDD, systematic debugging, verification, code review, security review, handoff — plus a workflow router template that maps task descriptions to the smallest combination of skill / agent / prompt / instruction.

Works in Claude Code, Codex, Cursor, and Copilot CLI through per-harness plugin manifests and a single cross-dialect SessionStart hook. (Copilot CLI needs no manifest of its own — it reuses the Codex/SDK-standard hook output.)

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
- **`using-template`** — a router skill template. Copy it into your project as `.claude/skills/using-<project>/` and fill in the routing table.
- **Cross-harness plugin manifests** for Claude Code (`.claude-plugin/`), Codex (`.codex-plugin/`), and Cursor (`.cursor-plugin/`).
- **SessionStart hook** (`hooks/session-start` + `hooks/run-hook.cmd`) that injects the router into the agent's context, emitting the right JSON dialect per harness.

## What's NOT in the box (and why)

This plugin ships methodology only — no stack-specific agents, prompts, or instructions. The `agents/` and `prompts/` patterns are project-defined; the `using-template` skill shows you how to layer them on top.

That's a deliberate choice: agent playbooks and reusable prompts in real projects always end up referencing the specific stack (FastAPI, Rails, Vue, etc.). Shipping them generically either degrades the content (vague placeholders) or hides the assumption. Better to keep them in each consuming project, where they're tuned to that stack.

## Install

### Claude Code

Tested with Claude Code 2.1.325. In a session:

```
/plugin marketplace add rene404/workflow-skills
/plugin install workflow-skills@workflow-skills
```

Or from a shell:

```sh
claude plugin marketplace add rene404/workflow-skills
claude plugin install workflow-skills@workflow-skills
```

The skills are namespaced by the plugin: invoke them as `/workflow-skills:plan`, `/workflow-skills:tdd`, and so on. They also trigger on their descriptions, so "plan this" picks up `plan` without the slash command. The SessionStart hook fires on `startup | clear | compact` and injects the router into context.

To try a local checkout instead, pass its path: `claude plugin marketplace add /path/to/workflow-skills`.

### Codex, Cursor, Copilot CLI (untested)

The repo ships manifests for these harnesses (`.codex-plugin/plugin.json`, `.cursor-plugin/plugin.json`; Copilot CLI reuses the SDK-standard hook output), but installing through them has not been verified yet. Follow your harness's own plugin documentation and point it at `https://github.com/rene404/workflow-skills`. Reports of what works are welcome as issues.

## Using in a project

Once installed, the skills auto-trigger on their description triggers (e.g., user says "plan this" → `/plan`). To get the routing-table experience for your specific project, copy the `using-template` skill:

```sh
cd /your/project
git clone --depth 1 https://github.com/rene404/workflow-skills.git /tmp/workflow-skills
mkdir -p .claude/skills
cp -r /tmp/workflow-skills/skills/using-template .claude/skills/using-<your-project>
mv .claude/skills/using-<your-project>/NEW-PROJECT-TODO.md ./NEW-PROJECT-TODO.md
```

The router goes under `.claude/skills/` because that is where Claude Code discovers project skills; anywhere else, the hook still injects it but `/using-<your-project>` cannot be invoked.

Then work through `NEW-PROJECT-TODO.md`. It walks you through:

1. Filling in the router's "Project routes" table with your real triggers → artifact paths
2. Wiring `AGENTS.md` to point at the router (so Codex finds it)
3. Wiring `CLAUDE.md` to load the router first
4. Adding `agents/`, `prompts/`, `.github/instructions/` as needed
5. Smoke-testing the hook in each harness

## How the multi-harness session-start works

`hooks/session-start` is a single bash script that:

1. Starts from the session's directory (`CLAUDE_PROJECT_DIR` / `CURSOR_PROJECT_DIR`, else
   the current directory) and walks up to the git root, like Claude Code's own skill
   discovery, so a session started in a subdirectory still finds the router. The closest
   router wins. Outside a git repo only the start directory is checked.
2. Looks for a project-local router at `.claude/skills/using-<project>/SKILL.md`
   (or, for older setups, `skills/using-<project>/SKILL.md`). If one exists, it injects that router in
   full — it has the concrete routes for that codebase. If not, it injects a slim
   fallback naming the available skills and the standard chain. The plugin's own
   `using-template` is never injected: its routing table is an empty placeholder, so
   shipping it into every session would cost context and route nothing.
3. Detects which harness is invoking it via env vars (`CURSOR_PLUGIN_ROOT`, `CLAUDE_PLUGIN_ROOT`, `COPILOT_CLI`)
4. Emits the JSON shape that harness expects:
   - Cursor → `additional_context` (snake_case top-level), registered via `hooks/hooks-cursor.json`
   - Claude Code → `hookSpecificOutput.additionalContext` (nested), registered via `hooks/hooks.json`
   - Codex → reads `hooks/hooks.json` by default and sets `CLAUDE_PLUGIN_ROOT` for compatibility, so it gets the Claude Code shape, which Codex also accepts (untested; Codex asks you to trust plugin hooks via `/hooks` first)
   - Copilot CLI / SDK-standard → `additionalContext` (camelCase top-level)

`bash tests/hook-test.sh` covers the dialects, the router lookup and JSON escaping.

`hooks/run-hook.cmd` is a polyglot Unix bash + Windows `.cmd` wrapper so the hook also works under Git Bash on Windows.

This pattern is borrowed from [obra/superpowers](https://github.com/obra/superpowers); credit where due.

## Versioning

Tagged releases. To pin to a tag, add the marketplace at that ref:

```sh
claude plugin marketplace add 'rene404/workflow-skills#v0.3.0'
claude plugin install workflow-skills@workflow-skills
```

Third-party marketplaces do not auto-update by default. To pick up a new release, run `claude plugin marketplace update workflow-skills` and then `claude plugin update workflow-skills@workflow-skills`, or enable auto-update for the marketplace under `/plugin` > Marketplaces.

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
