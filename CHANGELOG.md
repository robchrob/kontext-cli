# Changelog
All notable changes to ctx will be documented in this file.

## [0.6.4]
### Added
- **`.ktxrc` support**: Searches for `.ktxrc` first, then `.ctxrc` (backward compatible)
- **`_is_known_include` function**: Dynamic include pattern detection across all types
- **`tok_est`/`tok_est_str` functions**: Token estimation with separate calculation modes
- **`GLOB_EXCLUDE_PATTERN`**: Pre-built glob pattern for fast case matching in `is_globally_excluded`
- **`get_git_ignored` function**: Native gitignore integration using `git ls-files`
- **Complete 4-layer filtering in `run_find`**:
  - Layer 1: Directory pruning with `-I` reporting
  - Layer 2: Include pattern matching (find-native or manual)
  - Layer 3: Global file exclusions via `GLOB_EXCLUDE_PATTERN`
  - Layer 4: Gitignore support via `GIT_IGNORED_MAP`
- **`show_ignored_summary`**: Summary table of all ignored items (dirs, global, patterns)
- **Smart output destinations**: Proper handling of `-o` with/without file, `--no-clip`, `SILENT_MODE`
- **`run_files` token budget**: Token cap support for explicit file-list types
- **`mapfile` header detection**: Avoids duplicate headers when files already contain path info

### Changed
- **Replaced hardcoded filenames**: `_is_known_include` replaces manual `Makefile`/`Dockerfile`/`CMakeLists.txt` checks
- **Refactored `run_tree`**: Full gitignore integration for tree display
- **Refactored `run_find`**: Complete rewrite with 4-layer filtering and `-I` support
- **Updated `apply_mods`**: Uses `_is_known_include` for dynamic include detection
- **Better config loading**: `load_ctxrc` now searches for `.ktxrc` then `.ctxrc`
- **Preserved all working `ctx` features**: Output logic, skip counting, random order, raw mode

### Fixed
- **Restored missing functions**: `tok_est`, `show_ignored_summary`, `get_git_ignored`
- **Fixed `run_find` layers**: All 4 filtering layers now properly implemented
- **Fixed output destination logic**: Proper clipboard/file/stdout handling from working `ctx`

## [0.6.3]
### Fixed
- **Removed `set -x`** — Was dumping every command to stderr (debug leftover)
- **Fixed `args+=(\())` syntax error** — Extra `)` was breaking find include grouping
- **Added `set -f`** — Prevents glob patterns like `*.egg-info` from expanding against CWD during iteration
- **Fixed `((FILE_COUNT++))` / `((SKIP_COUNT++))`** — Post-increment returns 0 when var is 0, triggering `set -e` exit. Changed to `FILE_COUNT=$((FILE_COUNT + 1))` syntax
- **Fixed `load_ctxrc` skipping `.` directory** — Changed `while [[ "$dir" != "." ]]` to `while [[ "$dir" != "/" ]]` so it enters the loop
- **Fixed missing empty dir fallback** — Added `[[ -z "$dir" ]] && dir="."` after `${dir%.*}` to handle `ktx .py` case where dir becomes empty
- **Fixed `RANDOM_ORDER` parsed but never used** — Now properly used in `run_find` with `shuf -z`
- **Fixed `SHOW_IGNORED` parsed but never used** — Now properly used in `run_find` to print skipped files
- **Added `-v/--version`** — Was documented but missing from main() case statement
- **Added `-c/--config`** — Was documented but missing from main() case statement
- **Added `CMakeLists.txt` to `apply_mods` target detection** — Was missing from glob check

### Added
- **New type presets**: `go`, `rs`, `c`, `java` — Previously only documented, now fully implemented
- **`FILE_COUNT` tracking** — Tracks files processed for "No files found" check
- **Simplified help text** — More compact, single-line format
- **`--no-clip` flag** — Skip clipboard even when available

### Changed
- **Refactored `run_files` and `run_find`** — Cleaner token budget handling, unified file counting
- **Simplified `main()` output logic** — Cleaner dests array handling
- **Unified glob pattern handling** — Consistent `set -f` / `set +f` usage

## [0.6.0]
### Added
- **File paths in `[type:]` sections**: Domain slicing via explicit file lists. Any non-directive line in a `[type:name]` section is treated as an explicit file path
- **`with=TYPE` composability**: Types can compose other types. `with=infra` in `[type:health]` pulls in all files from the `infra` type. Resolves transitively with cycle detection
- **Dual-mode type sections**: A type uses **file list** mode if it has explicit paths; otherwise uses **pattern** mode (`include=`/`exclude=`). Both modes support `with=`

### Changed
- **Routing logic**: Automatically chooses between `run_files` (explicit list) and `run_find` (pattern discovery) based on type content

## [0.5.1]
### Changed
- **Removed `--no-clip`**: Clipboard is now automatic when available. Behavior:
  - `ctx` → stdout + clipboard (if available)
  - `ctx -o` → clipboard only (falls back to stdout if no clipboard)
  - `ctx -o file.txt` → file + clipboard
- **Made `-o/--output` file optional**: `-o` can now be used without a filename argument
- **Simplified tree options**: Removed `-t/--tree` since tree is now default. Only `-T/--no-tree` remains to disable it
- **Enhanced `-I/--show-ignored` summary**: Now prints a summary table at the top showing:
  - Ignored directories count
  - Global exclusions count
  - Pattern mismatches count
  - Total ignored count
- **Updated usage documentation** to reflect new option signatures

## [0.5.0]
### Added
- **`-I` / `--show-ignored` reports all four filtering layers**: Previously only showed global excludes and gitignore. Now reports:
  - **Dir prune** (`SKIP [dir]:`): Pre-scans and reports excluded directories like `.git`, `.venv`, etc.
  - **Include filter** (`SKIP [include]:`): Reports file count and patterns that didn't match include patterns (e.g., `847 files not matching: *.py *.pyw *.pyi ...`)
  - **Global excludes** (`SKIP [.env]:`, etc.): Already existed, still works
  - **Gitignore** (`SKIP [gitignore]:`): Already existed, still works

### Changed
- **Summary line now shows skip counts**: When `-I` is active, shows total skipped across all layers (e.g., `853 skipped`). Without `-I`, shows only file-level skips (cheap, no extra traversal)

## [0.4.0]
### Added
- **`FORCE_INCLUDE` array**: `+` modifiers now populate it. `is_globally_excluded` checks whitelist first — `+'.env,LICENSE'` overrides global excludes
- **`-type d` in find prune clause**: Old code pruned FILES matching exclude names too. `find -name '.env' -prune` kills the .env file before include patterns see it. Now only dirs are pruned, so `+'.env'` actually works
- **`+` always adds to INCLUDE_PATTERNS**: `+'.env'` needs to be in the find include list for non-`*` types, otherwise find never yields it. Non-glob tokens additionally add to EXCLUDE_DIRS (backward compat: `+'vendor'` still excludes the dir)
- **`ctx src/ .js` — separate type arg**: New trailing-arg loop consumes `.TYPE` after input. Both `ctx src/.js` and `ctx src/ .js` now work
- **`-I` / `--show-ignored`**: Prints `SKIP [pattern]: path` to stderr for every globally-excluded or gitignored file
- **`-r` / `--random`**: Pipes find output through `shuf -z`. Pair with `-m` for random sampling: `ctx -r -m 50000 .py`
- **add the upward search behavior** to `load_ctxrc`. This will find the nearest .ctxrc walking up from the target directory, giving you project-wide settings

## [0.3.0]
### Added
- **Cross-platform clipboard support**: Falls back through `pbcopy` (macOS), `wl-copy` (Wayland), `xclip` (X11), `xsel` (X11 alt), `clip` (Windows/WSL)
- **C/C++ type preset (`.c`)**: Includes `*.c *.h *.cpp *.hpp *.cc *.cxx *.hh *.inl Makefile CMakeLists.txt *.cmake`
- **Java type preset (`.java`)**: Includes `*.java *.xml *.gradle *.properties *.yml *.yaml *.md`
- **`.ctxrc` config file support**: Per-project config in `.ctxrc` with `type`, `max-tokens`, `+PAT`, `-PAT`
- **`--max-tokens` / `-m` flag**: Stop output when token budget is reached
- **Native `.gitignore` support in `run_find`**: Uses `git ls-files -oi --exclude-standard` to skip ignored files
- **`.ctxrc.example`**: Template for config file

### Changed
- Tree enabled by default (was opt-in)
- Output uses `→` instead of "copied to"

## [0.2.0]
### Added
- Language type presets (`.js`, `.py`, `.go`, `.rs`)
- Inline modifiers (`+PAT`, `-PAT`)
- `AGENTS.md` inclusion
- Token estimation with statistics

## [0.1.0]
### Added
- Initial release
- Basic find + tree output
- xclip clipboard support

(End of file - total 100 lines)
