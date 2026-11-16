# Examples: before/after transcripts

`AGENTS.md` asks every skill to show that it changes what the agent does. These are
real, unedited headless Claude Code sessions, each run once without and once with the
plugin. Only local paths and the username were replaced.

## Setup

- Claude Code 2.1.325, model `claude-opus-5-5`, recorded 2026-11-16
- Project: [`demo-project/`](demo-project/), a 45-line todo CLI with two tests. It has
  a planted bug: `pending()` returns finished todos, so one test fails.
- Each run starts from a fresh copy of the project, with user settings and plugins off
  (`--setting-sources project`). The "with" run adds `--plugin-dir <this repo>`.
- Allowed tools: read/search, `Skill`, and `python3 -m unittest`, `git status|diff|log`,
  `ls`. No edits, so a run cannot "solve" its way past the question.

```sh
claude -p "<prompt>" --setting-sources project [--plugin-dir /path/to/workflow-skills] \
  --allowedTools "Read,Glob,Grep,Skill,Bash(python3 -m unittest*),Bash(git status*),Bash(git diff*),Bash(git log*),Bash(ls*)" \
  --max-turns 12 --output-format stream-json --verbose
```

## Results

| Transcript | Prompt | Skill triggered | Behaviour change |
|---|---|---|---|
| [plan.md](plan.md) | "plan a new feature for me: todos should support due dates" | `workflow-skills:plan` | **Yes, in the shape of the plan.** Both runs find the planted bug, plan to fix it first, and wait for the user before coding. Without the plugin the plan is organised by layer (all functions, then the CLI, then a separate tests section) with no verification step per task. With it, the plan is 7 vertical tasks, each with its own tests, an exact command to run and a "done when", and it states its assumptions and what it deliberately leaves out. |
| [verify.md](verify.md) | "I fixed the bug in todo.py and the tests were green earlier. We're done, right?" | `workflow-skills:verify` | **No difference in outcome.** Both runs re-run the tests, find the failure and say "not done". The skill triggers correctly, but this model already does the right thing without it. |

The `verify` result is kept on purpose: it is the honest finding for this model, and a
reason to re-check whether the skill still earns its place (`AGENTS.md`: "If it doesn't
change observable behavior, it doesn't ship"). Weaker or faster models may still
benefit; that is untested.
