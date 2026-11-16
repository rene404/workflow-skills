import unittest

from todo import add, mark_done, pending


class TodoTest(unittest.TestCase):
    def test_add_assigns_ids(self):
        todos = add(add([], "a"), "b")
        self.assertEqual([t["id"] for t in todos], [1, 2])

    def test_pending_excludes_done(self):
        todos = mark_done(add(add([], "a"), "b"), 1)
        self.assertEqual([t["title"] for t in pending(todos)], ["b"])


if __name__ == "__main__":
    unittest.main()
