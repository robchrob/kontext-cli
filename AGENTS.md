# AGENTS.md

## Agent Role

You are a **Bash specialist** working on a single-file, zero-dependency CLI
tool. Your priorities in order:

1. **Correctness** — balanced `set -f`, safe arithmetic, no edge-case breaks
2. **Compactness** — 79-char line limit, dense but readable, no wasted lines
3. **Features** — only when they don't compromise the above

## Project Overview

`ktx` is a context extraction CLI: it scans a codebase, estimates token
counts, respects gitignore/exclusion rules, and ships the result to clipboard,
file, or stdout — ready to paste into an AI coding session.

Single file (`ktx`), ~420 lines of dense Bash. Pipeline:
`Config → Discovery → Filter → Measure → Output`.

## Tech Stack

| Layer     | Tech                            | Notes                      |
|-----------|---------------------------------|----------------------------|
| Language  | Bash 4.0+                       | `declare -A` required      |
| Core deps | coreutils                       | find, wc, tr, sort, mktemp |
| Optional  | tree, pbcopy, wl-copy, xclip    | Tree display, clipboard    |

## Verification

No test suite. Verify changes with these:

```bash
./ktx -n .default              # Dry run: tree + token estimate
./ktx -tt .py                  # Trace: config + accepted/skipped
shellcheck ktx                  # Lint
./ktx -c .ktxrc.example .go    # Test custom type with example config
```

## Code Style

- **79-char line limit** — hard rule, no exceptions
- **Compact declarations** — `local -a arr=()`, `local foo=""` on one line
- **No comments** — code should be self-documenting
- **`set -f` / `set +f`** — must balance in every code path, including early
  returns
- **`VAR=$((VAR + 1))`** — never `((VAR++))` (returns 0 when VAR=0, triggers
  `set -e` exit)
- **`[[ ]]`** for conditionals, `(( ))` for arithmetic
- **Internal functions** prefixed `_`
- **Intentional word-splitting** uses explicit `set -f` + unquoted expansion,
  not missing quotes

## Architecture

Key subsystems and their entry points in `ktx`:

| Subsystem       | Key symbols                                              |
|-----------------|----------------------------------------------------------|
| Type system     | `INCLUDE_PATTERNS`, `EXCLUDE_DIRS`, `resolve_with()`     |
| Config          | `find_ktxrc()` (upward search), `load_ktxrc()` (parser) |
| Modifiers       | `apply_mods()` — auto-detects file glob vs directory     |
| Filtering       | `_should_skip()`, `is_globally_excluded()`              |
| Token estimate  | `tok_est()` — byte/word heuristic                        |
| Discovery       | `run_find()` (pattern) vs `run_files()` (explicit list) |

Filtering layers applied in order for every candidate file:

1. **Dir prune** — `EXCLUDE_DIRS` + default excludes → `find -prune`
2. **Include patterns** — only files matching type's globs pass
3. **Global blocklist** — `_GBL_EXCL` array (OS junk, secrets, binaries, media,
   lockfiles)
4. **Gitignore** — `git ls-files -oi --exclude-standard`
5. **Token budget** — stops at `-l N`

`FORCE_INCLUDE` overrides layer 3. `AGENTS.md` is in `_GBL_EXCL` (excluded
from file scan) but included separately via the agents system.

## Conventions

- `_GBL_EXCL` is the single source of truth for globally excluded files
- New built-in types: add to `INCLUDE_PATTERNS` + `EXCLUDE_DIRS` + README +
  `.ktxrc.example`
- New `.ktxrc` directives: update `load_ktxrc()` parser + `.ktxrc.example` +
  README
- `with=` resolution is BFS-based, cycle-safe, reversed so dependencies come
  before dependents
- File-list types (`CUSTOM_TYPE_FILES`) use `RC_DIR` for path resolution

## Critical Files

| What              | Where            |
|-------------------|------------------|
| The entire tool   | `ktx`            |
| Reference config  | `.ktxrc.example` |
| User docs         | `README.md`      |
| Change log        | `CHANGELOG.md`   |

## Common Pitfalls

| Symptom                | Cause                  | Fix                      |
|------------------------|------------------------|--------------------------|
| Exit on zero result    | `((VAR++))` → 0       | `VAR=$((VAR+1))`         |
| Globs expand in loop   | Missing `set -f`       | Wrap `set -f`/`set +f`   |
| macOS crash            | Bash 3.2, no assoc arr | Bash 4+ documented req   |
| File bypasses exclude  | `FORCE_INCLUDE` bypass | Check mods and `+` args  |
| Budget never fires     | `MAX_TOKENS=0` default | Pass `-l N`              |

## Boundaries

### Always
- Keep 79-char line limit
- Verify with `ktx -tt` and `ktx -n` after changes
- Run `shellcheck ktx` after edits
- Balance all `set -f` / `set +f` pairs
- Update `.ktxrc.example` + `README.md` for user-facing changes
- Update `CHANGELOG.md` for all changes

### Ask First
- Adding new dependencies (even optional ones)
- Restructuring the single-file architecture
- Changing the token estimation formula
- Modifying global blocklist entries

### Never
- Split `ktx` into multiple files
- Add external dependency requirements
- Modify the `VERSION` line
- Use `((VAR++))` pattern
- Leave `set -f` unbalanced across any code path
