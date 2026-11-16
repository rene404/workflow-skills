# Transcript: `plan`, with and without the plugin

Recorded 2026-11-16. Setup and method: [README](README.md).

## Without workflow-skills

- Model: `claude-opus-5-5`, Claude Code `2.1.325`
- Skills invoked: none
- Turns: 4, stop: `success`

**Prompt:** plan a new feature for me: todos should support due dates

**Tool call** `Bash`: `{"command": "ls -la; git ls-files | head -50", "description": "List repository files"}`

<details><summary>Tool result</summary>

```
total 24
drwxr-xr-x   4 user  wheel  128 16 Nov. 19:53 __pycache__
drwxr-xr-x   7 user  wheel  224 16 Nov. 19:53 .
drwxr-xr-x  14 user  wheel  448 16 Nov. 19:53 ..
drwxr-xr-x  12 user  wheel  384 16 Nov. 19:53 .git
-rw-r--r--   1 user  wheel   56 16 Nov. 19:53 README.md
-rw-r--r--   1 user  wheel  444 16 Nov. 19:53 test_todo.py
-rw-r--r--   1 user  wheel  965 16 Nov. 19:53 todo.py
README.md
test_todo.py
todo.py
```
</details>

**Tool call** `Bash`: `{"command": "cat README.md todo.py test_todo.py", "description": "Show all source files"}`

<details><summary>Tool result</summary>

```
# todo

Tiny todo CLI. Run tests: `python3 -m unittest`
"""Minimal todo list CLI: add, list, done. Stores todos in todos.json."""
import json
import sys
from pathlib import Path

STORE = Path("todos.json")


def load():
    return json.loads(STORE.read_text()) if STORE.exists() else []


def save(todos):
    STORE.write_text(json.dumps(todos, indent=2))


def add(todos, title):
    todos.append({"id": len(todos) + 1, "title": title, "done": False})
    return todos


def mark_done(todos, todo_id):
    for t in todos:
        if t["id"] == todo_id:
            t["done"] = True
    return todos


def pending(todos):
    return [t for t in todos if t["done"]]


def main(argv):
    todos = load()
    cmd = argv[1] if len(argv) > 1 else "list"
    if cmd == "add":
        save(add(todos, " ".join(argv[2:])))
    elif cmd == "done":
        save(mark_done(todos, int(argv[2])))
    else:
        for t in pending(todos):
            print(f'{t["id"]}. {t["title"]}')


if __name__ == "__main__":
    main(sys.argv)
import unittest

from todo import add, mark_done, pending


class TodoTest(unittest.TestCase):
    def test_add_assigns_ids(self):
        todos = add(add([], "a"), "b")
        s …[truncated]
```
</details>

**Tool call** `Bash`: `{"command": "python3 -m unittest 2>&1 | tail -15", "description": "Run the existing test suite"}`

<details><summary>Tool result</summary>

```
First differing element 0:
'a'
'b'

- ['a']
?   ^

+ ['b']
?   ^


----------------------------------------------------------------------
Ran 2 tests in 0.001s

FAILED (failures=1)
```
</details>

**Assistant:**

> The plan is below. One thing first: **the test suite is already failing.** `pending()` in `todo.py:28` returns the todos that are done, not the ones still open (`if t["done"]` should be `if not t["done"]`), so `test_pending_excludes_done` fails. Every due-date view goes through `pending()`, so this needs fixing first.
> 
> ---
> 
> # Plan: due dates for todos
> 
> ## Current state
> - `todo.py` (about 45 lines): `add`, `mark_done`, `pending`, `main`. Data is stored in `todos.json` as `{"id", "title", "done"}`.
> - The CLI uses `argv` directly: `add <title...>`, `done <id>`, and anything else lists todos.
> - `test_todo.py` has 2 unit tests on the pure functions. One fails because of the bug above.
> 
> ## Design decisions
> | Decision | Choice | Why |
> |---|---|---|
> | Storage | Optional `"due": "YYYY-MM-DD"` key, left out when there's no date | Existing `todos.json` files keep working with no migration. ISO strings are readable and sort correctly as text. |
> | Input format | ISO dates only (`2026-11-20`), checked with `date.fromisoformat` | No extra dependencies, no ambiguity between date formats (`11/12` could mean two different days) |
> | Time of day | Dates only, no times | Matches a minimal CLI and avoids timezone handling |
> | "Today" | Passed in as a parameter (`today: date`) to the functions that need it | Tests stay deterministic, with no need to fake the clock |
> | List order | Dated todos first, earliest due first, then undated todos, with ties broken by id | The most urgent items show at the top |
> 
> ## Changes
> 
> **1. Fix `pending()`** (prerequisite): `if not t["done"]`.
> 
> **2. New and changed functions in `todo.py`**
> - `parse_due(s) -> str`: checks `s` with `date.fromisoformat` and returns the normalized string. On bad input it raises `ValueError` with a clear message.
> - `add(todos, title, due=None)`: sets `"due"` only when a date is given. Existing callers keep working.
> - `set_due(todos, todo_id, due)`: sets a todo's due date, or clears it when `due` is `None`.
> - `is_overdue(todo, today) -> bool`: true when the todo is not done, has a due date, and that date is before `today`.
> - `sort_by_due(todos) -> list`: sort key `(t.get("due") is None, t.get("due") or "", t["id"])`.
> 
> **3. CLI (`main`)**
> - `add <title...> [--due YYYY-MM-DD]`: a small helper pulls `--due VALUE` out of `argv[2:]` before the rest is joined into the title.
> - `due <id> <YYYY-MM-DD|none>`: new command to set or clear a due date on an existing todo.
> - List output: `3. Pay rent (due 2026-11-20)`, with `OVERDUE` added for overdue items.
> - An invalid date prints an error to stderr, exits with status 1, and leaves the store unchanged.
> 
> **4. Tests (`test_todo.py`)**
> - `add` with and without a due date. Without one, the todo has no `due` key.
> - `parse_due` accepts a valid date and rejects `2026-13-01` and `tomorrow`.
> - `set_due` sets a date and clears it.
> - `is_overdue`: past, today (not overdue), future, no date, and done todos (never overdue).
> - `sort_by_due`: dated todos before undated ones, ordered by date, ties by id.
> - A `main` test for `--due` parsing, run against a temporary store (point `STORE` at a temp directory).
> 
> **5. README**: document `--due` and the `due` command.
> 
> ## Order of work
> 1. Fix `pending()` and confirm the tests pass.
> 2. Add the pure functions with their tests.
> 3. Wire up the CLI and list output.
> 4. Update the README.
> 
> ## Open questions for you
> 1. Should the input also accept words like `today` or `tomorrow`, or relative forms like `+3d`? These are easy to add to `parse_due` later.
> 2. Should there be a `list --overdue` or `list --due-before DATE` filter, or is the sorted list enough for now?
> 3. Should the `due` command clear a date with `none` or with a separate `--clear` flag?
> 
> Ready to implement once you've answered these. The defaults would be: ISO only, no filters, and `none`.


---

## With workflow-skills

- Model: `claude-opus-5-5`, Claude Code `2.1.325`
- Skills invoked: `workflow-skills:plan`
- Turns: 6, stop: `success`

**Prompt:** plan a new feature for me: todos should support due dates

**Tool call** `Skill`: `{"skill": "workflow-skills:plan", "args": "todos should support due dates"}`

<details><summary>Tool result</summary>

```
Launching skill: workflow-skills:plan
```
</details>

**Tool call** `Bash`: `{"command": "git ls-files; cat CONTEXT.md AGENTS.md CLAUDE.md 2>/dev/null | head -50", "description": "List tracked files and project docs"}`

<details><summary>Tool result</summary>

```
README.md
test_todo.py
todo.py
```
</details>

**Tool call** `Bash`: `{"command": "cat README.md; echo ----; cat -n todo.py; echo ----; cat -n test_todo.py", "description": "Show README, source, and tests"}`

<details><summary>Tool result</summary>

```
# todo

Tiny todo CLI. Run tests: `python3 -m unittest`
----
     1	"""Minimal todo list CLI: add, list, done. Stores todos in todos.json."""
     2	import json
     3	import sys
     4	from pathlib import Path
     5	
     6	STORE = Path("todos.json")
     7	
     8	
     9	def load():
    10	    return json.loads(STORE.read_text()) if STORE.exists() else []
    11	
    12	
    13	def save(todos):
    14	    STORE.write_text(json.dumps(todos, indent=2))
    15	
    16	
    17	def add(todos, title):
    18	    todos.append({"id": len(todos) + 1, "title": title, "done": False})
    19	    return todos
    20	
    21	
    22	def mark_done(todos, todo_id):
    23	    for t in todos:
    24	        if t["id"] == todo_id:
    25	            t["done"] = True
    26	    return todos
    27	
    28	
    29	def pending(todos):
    30	    return [t for t in todos if t["done"]]
    31	
    32	
    33	def main(argv):
    34	    todos = load()
    35	    cmd = argv[1] if len(argv) > 1 else "list"
    36	    if cmd == "add":
    37	        save(add(todos, " ".join(argv[2:])))
    38	    elif cmd == "done":
    39	        save(mark_done(todos, int(argv[2])))
    40	    else:
    41	        for t  …[truncated]
```
</details>

**Tool call** `Bash`: `{"command": "python3 -m unittest 2>&1 | tail -15", "description": "Run the existing test suite"}`

<details><summary>Tool result</summary>

```
First differing element 0:
'a'
'b'

- ['a']
?   ^

+ ['b']
?   ^


----------------------------------------------------------------------
Ran 2 tests in 0.001s

FAILED (failures=1)
```
</details>

**Assistant:**

> I read `todo.py`, `test_todo.py` and `README.md` and ran the tests. **One of the two existing tests already fails.** `pending()` at `todo.py:30` keeps the todos that are done instead of the ones that aren't, so `list` prints finished items. Task 1 fixes that first so the later tests have a passing baseline.
> 
> ## Assumptions (tell me if any are wrong)
> - **Input:** `python3 todo.py add Buy milk --due 2026-11-20`. Dates must be `YYYY-MM-DD`; anything else is rejected.
> - **Storage:** a `"due"` key holding an ISO date string, or `null`. Todos saved before this change have no `due` key and are read with `t.get("due")`, so the existing `todos.json` doesn't need converting.
> - **Display:** `list` shows `(due 2026-11-20)`. A date before today shows as `(OVERDUE 2026-11-10)` instead.
> - **Left out for now:** changing or removing a due date on an existing todo, sorting by due date, times of day and time zones.
> 
> ## Plan
> 
> ### 1. Fix `pending()` so it returns todos that aren't done
> **Files:** `todo.py`, `test_todo.py`
> **What:** Change the filter at `todo.py:30` from `if t["done"]` to `if not t["done"]`. The existing `test_pending_excludes_done` covers it.
> **Command:** `python3 -m unittest -v`
> **Done when:** Both existing tests pass.
> 
> ### 2. `add()` accepts an optional due date
> **Files:** `todo.py`, `test_todo.py`
> **What:** Change the signature to `add(todos, title, due=None)`. `due` is a `datetime.date`, saved as `due.isoformat()` or `None`.
> **Command:** `python3 -m unittest test_todo.TodoTest.test_add_stores_due_date test_todo.TodoTest.test_add_without_due_stores_none -v`
> **Done when:** Both new tests pass: `add([], "a", date(2026, 11, 20))[0]["due"] == "2026-11-20"`, and `add([], "a")[0]["due"] is None`.
> 
> ### 3. Parse `--due` from the arguments to `add`
> **Files:** `todo.py`, `test_todo.py`
> **What:** Add `parse_add_args(args) -> (title, due)`. It removes `--due YYYY-MM-DD` from anywhere in `args` and joins what's left into the title. A malformed date or a missing value raises `ValueError`.
> **Command:** `python3 -m unittest test_todo.TodoTest.test_parse_add_args_with_due test_todo.TodoTest.test_parse_add_args_without_due test_todo.TodoTest.test_parse_add_args_rejects_bad_date test_todo.TodoTest.test_parse_add_args_rejects_missing_value -v`
> **Done when:** All four tests pass:
> - `["Buy", "milk", "--due", "2026-11-20"]` gives `("Buy milk", date(2026, 11, 20))`.
> - With no flag, the result is `(title, None)`.
> - `"--due 20-11-2026"` and a trailing `"--due"` both raise `ValueError`.
> 
> ### 4. Use the parser in `main` for `add`
> **Files:** `todo.py`, `test_todo.py`
> **What:** The `add` branch of `main` calls `parse_add_args(argv[2:])` and then `add(todos, title, due)`. If the date is invalid, it prints `error: invalid due date, expected YYYY-MM-DD` to stderr, exits with code 2 and doesn't save.
> **Command:** `python3 -m unittest test_todo.MainTest -v`
> **Done when:** Both `MainTest` tests pass. Each runs in a temporary working directory, because `STORE` is a path relative to the current directory.
> - `test_add_with_due_persists`: `todos.json` contains `"due": "2026-11-20"`.
> - `test_add_with_bad_due_exits_without_saving`: raises `SystemExit(2)` and doesn't create `todos.json`.
> 
> ### 5. Format a todo line with its due date and overdue marker
> **Files:** `todo.py`, `test_todo.py`
> **What:** Add `format_todo(t, today) -> str`:
> - no due date: `"1. a"`
> - due today or later: `"1. a (due 2026-11-20)"`
> - due before today: `"1. a (OVERDUE 2026-11-10)"`
> 
> It reads the date with `t.get("due")`, so old todos without the key also work.
> **Command:** `python3 -m unittest test_todo.TodoTest.test_format_no_due test_todo.TodoTest.test_format_future_due test_todo.TodoTest.test_format_due_today_not_overdue test_todo.TodoTest.test_format_overdue test_todo.TodoTest.test_format_legacy_todo_without_key -v`
> **Done when:** All five tests pass. Each passes a fixed `today`, so the results don't depend on the current date.
> 
> ### 6. `list` prints the formatted lines
> **Files:** `todo.py`, `test_todo.py`
> **What:** The `list` branch of `main` prints `format_todo(t, date.today())` for each todo in `pending(todos)`.
> **Command:** `python3 -m unittest test_todo.MainTest.test_list_shows_due_dates -v`
> **Done when:** The test writes a `todos.json` with one dated todo, one undated todo and one done todo, captures stdout from `main(["todo.py", "list"])`, and gets exactly the two lines for the todos that aren't done, with the dated one showing `(due …)`.
> 
> ### 7. Document the feature and run everything
> **Files:** `README.md`
> **What:** Add a usage section covering `add <title> [--due YYYY-MM-DD]`, `list` (including the OVERDUE marker) and `done <id>`.
> **Command:** `python3 -m unittest -v && python3 todo.py add Demo --due 2020-01-01 && python3 todo.py list` (run this in a scratch directory)
> **Done when:** All tests pass and the last command prints `1. Demo (OVERDUE 2020-01-01)`.
> 
> Tasks 2–6 each change behaviour and include their own test. None of them needs a separate migration step, for the storage reason above.
> 
> Do you approve this plan, or do you want to change any of the assumptions, for example by adding sorting by due date or a way to set the due date on an existing todo? I won't start until you confirm. When you do, I'll work through the tasks with `/tdd`.

