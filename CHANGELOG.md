# Changelog
All notable changes to this project will be documented in this file.

## [0.7.6]
### Changed
- **Modifier semantics simplified**: `+` always adds to include patterns (and force-include); `-` with globs removes from includes, `-` with plain names removes from excluded dirs (un-skips a directory). Removed confusing dual behavior where `+NAME` could add to exclude dirs
- **`with=` now works for pattern types**: Merges `include=` and `exclude=` lists from all dependencies via BFS DAG traversal, same cycle-safe resolution as file-list types
- **Argument order is now free-form**: Options, modifiers, dir, and .type can be intermixed — `ktx .py -o ctx.txt` works the same as `ktx -o ctx.txt .py`
- **Modifier detection improved**: `-` prefixed args are distinguished from unknown options using glob/length heuristics instead of relying on parse order
- **`-o` next-arg detection**: Won't consume `.type` or modifier args as filename — `ktx -o .py` correctly treats `.py` as a type, not an output file
- **Help text rewritten**: Clearer modifier documentation with explicit glob character explanation (`*`, `?`, `[abc]`); examples show type-first ordering
- **README examples updated**: All examples use `ktx .type` before options (e.g., `ktx .py -l 50000` instead of `ktx -l 50000 .py`)

### Added
- **`_merge_pattern_type` function**: Merges include patterns and exclude dirs across the `with=` DAG for pattern-based types
- **`_is_glob` helper**: Extracted glob detection into a named function for clarity
- **Pattern composition example in `.ktxrc.example`**: `[type:fullstack]` demonstrates `with=js` for pattern types

### Fixed
- **Modifier `-` args no longer break option parsing**: Previously, `ktx .py -'*.md'` would stop at `.py` and never see the modifier. Now all args are parsed in a single pass

## [0.7.5]
### Changed
- **Cleaned up help text**: Removed bloated modifier documentation, simplified to one line with examples
- **Fixed help alignment**: Consistent spacing for all option descriptions

## [0.7.4]
### Added
- **`_file_ext` helper**: Proper extension detection for dotfiles with sub-extensions (e.g., `.ktxrc.example` → `.ktxrc.example` not `.example`)

### Fixed
- **Stats table formatting**: Separate width tracking for Extension and Tokens columns; separator line now properly sized

## [0.7.3]
### Changed
- **Simplified help**: Removed detailed type listings. Built-in types `.default`, `.js`, `.py` mentioned briefly; custom types still documented with reference to `.ktxrc.example`
- **Improved help consistency**: All options that support long forms now show both short and long options (e.g., `-o, --output`, `-l, --limit`, `-r, --randomize`, `-T, --no-tree`, `-t, --trace`, `-c, --config`, `-v, --version`, `-h, --help`)

## [0.7.2]
### Changed
- **`-o` behavior**: `-o` alone now outputs to stdout (no clipboard); `-o FILE` writes to file. Added `OUT_TO_FILE` flag to track this
- **Help text**: Updated `-l` description to "Token limit (default = unlimited)", `-o` to "-o [FILE]"
- **Custom types help**: Condensed to 2 lines referencing `.ktxrc.example`

### Added
- **`--randomize` long option**: Alternative to `-r`/`--random`

## [0.7.1]
### Changed
- **Reduced built-in types**: Only `default`, `js`, and `py` remain built-in. Removed `go`, `rs`, `c`, `java` presets (define these in `.ktxrc` instead)
- **Renamed flag**: `-I` / `--show-ignored` → `-t` / `--trace` (shows skipped files on stderr)
- **Updated help text**: Now mentions defining custom types via `.ktxrc`

### Removed
- **Built-in type presets**: `go`, `rs`, `c`, `java` — moved to `.ktxrc` examples

## [0.7.0] — ktx
### Changed
- **Renamed `ctx` → `ktx`**, config `.ctxrc` → `.ktxrc` (backward compatible: `.ctxrc` still discovered)
- **Renamed flag**: `-m/--max-tokens` → `-l/--limit`
- **Always-excluded dirs** (`.git .svn .hg .idea .vscode .vs`) separated from per-type excludes — cleaner presets, always applied
- **`-type d` in find prune clause**: Only directories are pruned; files with matching names (e.g. `.env`) pass through to include-pattern matching
- **Expanded global file blocklist**: Added OS files (`Thumbs.db`, `desktop.ini`), secrets (`.env.*`, `*.pem`, `*.key`, `*.tfvars`, `*.tfstate`, etc.), more media/binary/archive types, meta files (`LICENSE`, `CHANGELOG`, `AGENTS.md`, `.ktxrc`)
- **Pre-split global excludes into array at startup**: Eliminates repeated `set -f` / word-split inside `is_globally_excluded` hot path
- **Combined `tok_est` into inline arithmetic** in the main file loop — avoids double `wc` calls per file
- **Dependency order in `with=` resolution**: BFS reversed so dependencies come before the dependent type (`infra` files before `api` files)

### Added
- **`--raw` flag**: Skip instruction header and `AGENTS.md` inclusion for clean file-only output
- **`--no-clip` flag**: Skip clipboard even when a clipboard tool is available
- **`agent-header=` in `.ktxrc`**: Custom instruction header; empty value disables header entirely
- **`-c FILE` flag**: Explicitly specify config file path instead of upward search
- **Separate type argument**: `ktx src/ .js` now works alongside `ktx src/.js`
- **File-list paths resolved relative to `.ktxrc` location** (`RC_DIR`): Predictable path resolution when config is found in a parent directory
- **`CUSTOM_TYPES` tracking map**: Clean registration of custom pattern types and file-list types from `.ktxrc` sections
- **`_is_known_include` function**: Dynamic include-pattern detection across all types — replaces hardcoded `Makefile`/`Dockerfile`/`CMakeLists.txt` checks in `apply_mods`
- **`_GBL_EXCL` pre-built array**: Global excludes split once at startup for use in `is_globally_excluded`
- **`--` option terminator**: Standard double-dash support for directories with unusual names

### Fixed
- **`set -e` safety**: All counters use `VAR=$((VAR + 1))` instead of `((VAR++))` to avoid exit-on-zero
- **Empty-array safety with `set -u`**: Guard `${FORCE_INCLUDE[@]}` and array slicing with length checks
- **`set -f` balanced**: All `set -f` / `set +f` pairs are balanced across all code paths including early returns
- **Modifier application order**: `.ktxrc` global modifiers apply to the `.ktxrc`'s declared type; CLI modifiers apply to the effective type after resolution

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
- **File paths in `[type:]` sections**: Domain slicing via explicit file lists
- **`with=TYPE` composability**: Types can compose other types. Resolves transitively with cycle detection
- **Dual-mode type sections**: File list or pattern mode, auto-detected

### Changed
- **Routing logic**: Chooses between `run_files` (explicit list) and `run_find` (pattern discovery) based on type content

## [0.5.1]
### Changed
- **Removed `--no-clip`**: Clipboard automatic when available
- **Made `-o/--output` file optional**
- **Simplified tree options**: Only `-T/--no-tree` remains
- **Enhanced `-I/--show-ignored` summary**: Prints summary table

## [0.5.0]
### Added
- **`-I` reports all four filtering layers**: Dir prune, include filter, global excludes, gitignore

### Changed
- **Summary line shows skip counts** when `-I` active

## [0.4.0]
### Added
- **`FORCE_INCLUDE` array**: `+` modifiers override global blocklist
- **`-type d` in find prune**: Only prune directories, not files
- **`+` always adds to INCLUDE_PATTERNS**: Non-glob tokens also add to EXCLUDE_DIRS
- **`ctx src/ .js` — separate type arg**
- **`-I` / `--show-ignored`**
- **`-r` / `--random`**
- **Upward search** in `load_ctxrc`

## [0.3.0]
### Added
- **Cross-platform clipboard**: pbcopy, wl-copy, xclip, xsel, clip
- **C/C++ and Java type presets**
- **`.ctxrc` config file support**
- **`--max-tokens` / `-m` flag**
- **Native `.gitignore` support**

### Changed
- Tree enabled by default

## [0.2.0]
### Added
- Language type presets, inline modifiers, `AGENTS.md`, token estimation

## [0.1.0]
### Added
- Initial release: find + tree output, xclip clipboard
