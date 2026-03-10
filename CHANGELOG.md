# Changelog
All notable changes to this project will be documented in this file.

## [0.8.4]
### Added
- **`--dry-run` / `-n` flag**: Shows tree + counts files/tokens without generating output or touching clipboard
- **Expanded defaults**: `EXCLUDE_DIRS` and `INCLUDE_PATTERNS` now include updated entries `.cache`, `.temp`, `jspm_packages`, `web_modules`, `.vite`, `.svelte-kit`,...

### Changed
- **79-col line limit**: All lines reformatted to stay within 79 columns using continuation (`\`), multi-line strings, and restructured conditionals
- **`no-agents` / `no-tree` removed from config**: `no-agents=true` and `no-tree=true` directives removed from `load_ktxrc`. Agents disabled via `agents-file=` (empty string). Tree control is CLI-only (`-T`)
- **Version in usage**: `usage()` now uses `v${VERSION}` interpolated into the heredoc
- **Inline custom type fix**: The type-not-found check now falls back to `CUSTOM_TYPE_INCLUDE[$type]` before erroring, so `ktx -c <(echo '[type:x]\ninclude=*.foo') .x` works
- **Clipboard feedback**: Final summary line changed from `Context for: type: …` to `Copied N files (~X tokens) → clipboard`
- **`DRY_RUN` in `_measure_and_emit`**: When dry-running, file stats are counted but content is not emitted

## [0.8.3]
### Added
- **Comprehensive test suite expansion**: Increased test coverage from 47 to 86 tests (83% increase)
  - P0 (Critical): Exit code validation, `-o` without file behavior, `-T` CLI flag, `-c` explicit config
  - P1 (High Priority): Unknown option handling, missing argument errors, `dir.type` combined args, stats on stderr, token budget with `--raw`, three-level `with=` chains, missing `AGENTS.md` handling
  - P2 (Medium Priority): Double dash (`--`) parsing, deterministic sorting, `instruction-header` alias, `--no-clip`, modifiers on default type, file header smart detection, idempotent output, trace functionality
  - P3 (Low Priority): Version/help flags, binary/media exclusions, NUL byte handling, Windows line endings in `.ktxrc`

### Changed
- **Reverted dynamic heading customization**: Removed `context-heading`, `tree-heading`, and `file-header` from `.ktxrc` configurations to simplify the scope.
- **Streamlined output toggles**: Dropped granular CLI flags (`--no-header`, `--no-instr`, `--no-context-heading`). Disabling these headings is now exclusively handled by the `--raw` flag, which provides a clean, text-only output pipe.
- **Usage menu formatting**: Reorganized the CLI help text into a cleaner, single-column layout for improved readability.
- **README updates**: Refreshed examples and documentation for clarity.
- `instruction-header` and `agents-file` remain fully customizable via `.ktxrc`, and `--no-agents` is retained.

## [0.8.2]
### Added
- **Granular output control**: Added flags to disable specific output sections individually:
  - `--no-agents` skips `AGENTS.md` inclusion
  - `--no-header` skips `### filename` per-file headers
  - `--no-instr` skips the instruction header
  - `--no-context-heading` skips the `## Context for` heading
  - `-T, --no-tree` already existed but is now part of this granular system
- **Config toggles for output sections**: All the above `--no-*` flags can now be set in `.ktxrc` directly (e.g., `no-agents=true`).

### Changed
- **`--raw` behavior aggregated**: `--raw` is now a true aggregate flag that simply sets `--no-tree`, `--no-agents`, `--no-header`, `--no-instr`, and `--no-context-heading` internally, making it perfectly clean for piping.
- **Default agent header synced**: The default instruction header is now explicitly documented and mirrored in `.ktxrc.example`.

## [0.8.1]
### Fixed
- **Modifier +/- semantics for directories**: `+dirname` now correctly un-excludes a directory (removes from prune list), `-dirname` excludes a directory (adds to prune list). Previously `+` always force-included files and only `-` handled directories.
- **Modifier +/- with globs**: `+glob` adds to include patterns AND force-includes; `-glob` removes from include patterns. Previous logic was inconsistent.

### Changed
- **Help text updated**: Modifier documentation now clearly shows directory vs file behavior and glob vs plain-name distinction

## [0.8.0]
### Changed
- **Major code refactor**: Reduced ktx from 989 to ~516 lines (48% reduction)
- **Simplified declarations**: Combined multi-line statements into compact form
- **Removed trace helper functions**: `_trace_skip`, `_trace_accept`, `_trace_config` eliminated
- **Simplified trace output**: Streamlined to essential config info only

### Fixed
- **Modifier logic consolidated**: Cleaner apply_mods() implementation

## [0.7.9]
### Changed
- **Trace system completely overhauled** (Good feedback - previous implementation too verbose)
  - `-t` now shows compact config + skip reasons
  - `-tt` adds accepted file logging with token counts
  - Removed `_trace_header`, `_trace_kv`, `_trace_list`, `_trace_diff_words`, `_trace_summary` functions
  - Removed `_snapshot_defaults`, `_ORIG_INCLUDE`, `_ORIG_EXCLUDE` - no more diff markers
  - Single `_trace_config` function prints one compact block
  - Exclude dirs shown on single line
  - Agent header shows `(default)` or truncated custom preview
  - Fixed leading blank line bug (no more `\n` before first section)

### Removed
- **Filtering summary** - `show_stats` table + final summary line already provides accepted/token counts
- **Version line in trace** - use `ktx -v` instead
- **SHOW_IGNORED variable** - replaced by TRACE_LEVEL

## [0.7.8]
### Added
- **`--no-header` flag**: Suppresses `### filename` headers in output (useful for cleaner piping)
- **Deterministic output order**: Files are now sorted lexicographically by default (use `-r/--randomize` for random order)
- **`--trace` dir-prune visibility**: Shows pruned directories (e.g., `.git/`) in trace output
- **Shellcheck directive**: Added `# shellcheck disable=SC2086` for intentional word-splitting
- **New global blocklist entries**: `*.whl`, `*.egg`, `*.tar`, `.terraform`, `*.tfstate.backup`
- **README improvements**: Prerequisites section, platform support table, one-liner `.ktxrc` examples

### Changed
- **`--raw` now implies `--no-tree`**: Raw mode is truly pipe-friendly
- **`--limit` validation**: Rejects non-numeric values with clear error message
- **Better error messages**: Empty `.ktxrc` type sections now say "has no include patterns or files"
- **Directory handling**: Strips trailing slash from directory paths

### Removed
- **Surprising `src.py` splitting**: Removed the heuristic that tried to split `dir.ext` into directory + type

## [0.7.7]
### Fixed
- **Token total calculation**: Fixed arithmetic expansion bug where `EXT_TOK[ext]` was treated as a literal string index instead of `$ext` variable expansion, causing `total_toks` to always be 0

### Changed
- **79-character line limit**: All code reformatted or wrapped to stay within 79 columns
- **Always-excluded dirs merged**: `ALWAYS_EXCLUDE_DIRS` deleted; values now live in `EXCLUDE_DIRS[default]`; new `_get_exclude_dirs()` helper merges default + type dirs
- **Uniform declarations**: Presets use readable multi-line strings; blocklist is a direct array with comments per category
- **Removed `_build_gbl_excl`**: `GLOBAL_EXCLUDE_FILES` string and `_build_gbl_excl()` eliminated; `_GBL_EXCL` defined directly as quoted array (needed for `is_globally_excluded` iteration without `set -f`)
- **Clarified big functions**: `run_find` and `run_files` decomposed into `_build_find_args`, `_collect_file_list`, `_init_git_ignored`, `_should_skip`, `_measure_and_emit`; `main` uses standard `case`/`shift` with no custom option-vs-modifier heuristic
- **README updated**: "always-excluded" changed to "inherit from default" for exclude dirs

### Removed
- **Dead code**: `tok_est_file` (never called)

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
- **`-o` flag directory safety**: Won't consume an existing directory as the output file when `-o` is used without a filename (e.g., `ktx -o /path/to/dir .py` now works correctly)
- **Type detection from basename only**: Only considers the basename for type detection so that dots in parent directories (e.g., `/tmp/tmp.XXXXXX/proj`) are never mistaken for a type separator

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
