#!/usr/bin/env bash
# Tests for hooks/session-start. Zero-dep beyond bash + python3 (used only to
# parse the hook's JSON output, the way Claude Code would).
#
# Usage: bash tests/hook-test.sh

set -uo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="${REPO}/hooks/run-hook.cmd"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

pass=0
fail=0

# run_hook <cwd> <env assignments...> -> prints hook stdout
run_hook() {
    local dir="$1"; shift
    (cd "${dir}" && env -u CLAUDE_PLUGIN_ROOT -u CLAUDE_PROJECT_DIR \
        "$@" bash "${HOOK}" session-start)
}

# get_context -> reads hook JSON on stdin, prints the context string.
# Exits non-zero if the JSON is invalid or not Claude Code's SessionStart shape.
get_context() {
    python3 -c '
import json, sys
d = json.load(sys.stdin)
assert d["hookSpecificOutput"]["hookEventName"] == "SessionStart"
sys.stdout.write(d["hookSpecificOutput"]["additionalContext"])
'
}

check() {
    local name="$1" cond="$2"
    if [ "${cond}" = "ok" ]; then
        pass=$((pass + 1)); printf 'ok   %s\n' "${name}"
    else
        fail=$((fail + 1)); printf 'FAIL %s: %s\n' "${name}" "${cond}"
    fi
}

# expect_contains <name> <haystack> <needle>
expect_contains() {
    case "$2" in
        *"$3"*) check "$1" ok ;;
        *) check "$1" "expected to contain: $3" ;;
    esac
}

expect_not_contains() {
    case "$2" in
        *"$3"*) check "$1" "expected NOT to contain: $3" ;;
        *) check "$1" ok ;;
    esac
}

make_router() { # <dir> <name> <body>
    mkdir -p "$1"
    printf -- '---\nname: %s\ndescription: test router\n---\n%s\n' "$2" "$3" > "$1/SKILL.md"
}

# --- 1. Output shape, no project router ------------------------------------
empty="${TMP}/empty"; mkdir -p "${empty}"

ctx=$(run_hook "${empty}" CLAUDE_PLUGIN_ROOT=x | get_context) \
    && check "output is valid SessionStart JSON" ok || check "output is valid SessionStart JSON" "invalid"
expect_contains "fallback names the skills" "${ctx}" "Available skills:"
expect_contains "fallback points at .claude/skills" "${ctx}" ".claude/skills/using-<project>/"
expect_not_contains "fallback no longer lists verify" "${ctx}" "/verify"

# --- 2. Router lookup -------------------------------------------------------
proj="${TMP}/proj"
make_router "${proj}/.claude/skills/using-proj" using-proj "ROUTES-DOTCLAUDE"
ctx=$(run_hook "${proj}" CLAUDE_PLUGIN_ROOT=x | get_context)
expect_contains "router in .claude/skills is injected" "${ctx}" "ROUTES-DOTCLAUDE"

legacy="${TMP}/legacy"
make_router "${legacy}/skills/using-legacy" using-legacy "ROUTES-LEGACY"
ctx=$(run_hook "${legacy}" CLAUDE_PLUGIN_ROOT=x | get_context)
expect_contains "legacy router in skills/ is injected" "${ctx}" "ROUTES-LEGACY"

both="${TMP}/both"
make_router "${both}/skills/using-a" using-a "ROUTES-LEGACY"
make_router "${both}/.claude/skills/using-b" using-b "ROUTES-DOTCLAUDE"
ctx=$(run_hook "${both}" CLAUDE_PLUGIN_ROOT=x | get_context)
expect_contains ".claude/skills wins over skills/" "${ctx}" "ROUTES-DOTCLAUDE"

tmpl="${TMP}/tmpl"
make_router "${tmpl}/.claude/skills/using-template" using-template "ROUTES-TEMPLATE"
ctx=$(run_hook "${tmpl}" CLAUDE_PLUGIN_ROOT=x | get_context)
expect_not_contains "using-template is never injected" "${ctx}" "ROUTES-TEMPLATE"

# --- 3. M4: session started in a subdirectory -------------------------------
# Claude Code sets CLAUDE_PROJECT_DIR to the directory the session started in,
# which may be a subdirectory. Like Claude Code's own skill discovery, the hook
# walks up to the git root.
gitproj="${TMP}/gitproj"
make_router "${gitproj}/.claude/skills/using-g" using-g "ROUTES-GIT"
mkdir -p "${gitproj}/pkg/inner"
git -C "${gitproj}" init -q
ctx=$(run_hook "${gitproj}/pkg/inner" CLAUDE_PLUGIN_ROOT=x CLAUDE_PROJECT_DIR="${gitproj}/pkg/inner" | get_context)
expect_contains "claude: started in subdir of git repo finds router at git root" "${ctx}" "ROUTES-GIT"
expect_contains "router path is shown relative to where it was found" "${ctx}" '`.claude/skills/using-g/SKILL.md`'

ctx=$(run_hook "${gitproj}/pkg/inner" CLAUDE_PLUGIN_ROOT=x | get_context)
expect_contains "no project env var: falls back to PWD and walks up" "${ctx}" "ROUTES-GIT"

# A router in a nested package wins over the one at the git root (closest first).
make_router "${gitproj}/pkg/.claude/skills/using-pkg" using-pkg "ROUTES-PKG"
ctx=$(run_hook "${gitproj}/pkg/inner" CLAUDE_PLUGIN_ROOT=x CLAUDE_PROJECT_DIR="${gitproj}/pkg/inner" | get_context)
expect_contains "closest router wins" "${ctx}" "ROUTES-PKG"

# Outside a git repo, only the start directory counts: walking up to / could
# pick up an unrelated router.
outer="${TMP}/outer"
make_router "${outer}/.claude/skills/using-o" using-o "ROUTES-OUTER"
mkdir -p "${outer}/sub"
ctx=$(run_hook "${outer}/sub" CLAUDE_PLUGIN_ROOT=x CLAUDE_PROJECT_DIR="${outer}/sub" | get_context)
expect_not_contains "no git: does not walk above the start dir" "${ctx}" "ROUTES-OUTER"

# --- 4. M3: JSON escaping ---------------------------------------------------
ctrl="${TMP}/ctrl"
body=$(printf 'tab\there form\fend bell\aend esc\033end quote" back\\slash Umlaut äöü emoji ✓')
make_router "${ctrl}/.claude/skills/using-c" using-c "${body}"
if ctx=$(run_hook "${ctrl}" CLAUDE_PLUGIN_ROOT=x | get_context 2>&1); then
    expect_contains "control chars round-trip" "${ctx}" "${body}"
else
    check "control chars yield valid JSON" "invalid JSON: ${ctx##*$'\n'}"
fi

printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
[ "${fail}" -eq 0 ]
