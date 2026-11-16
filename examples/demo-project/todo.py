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
