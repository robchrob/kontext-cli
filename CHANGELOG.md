# Changelog
All notable changes to this project will be documented in this file.

## [0.3.3]
### Changed
- **Final release cleanup**: Trimmed changelog, removed LICENSE file, expanded
  `.ktxrc.example` with go/rs/c/java custom type examples and no-tree/no-agents
  config toggles, simplified README.

## [0.3.2]
### Added
- **`--dry-run` / `-n` flag**: Shows tree + counts files/tokens without
  generating output or touching the clipboard.
- **Expanded default exclusions**: `EXCLUDE_DIRS` and `INCLUDE_PATTERNS` now
  include `.cache`, `.temp`, `jspm_packages`, `web_modules`, `.parcel-cache`,
  `.vite`, `.svelte-kit`, `.serverless`, `.firebase`, `.mypy_cache`, `.tox`,
  `.coverage`, `htmlcov`.
- **Comprehensive test suite**: Increased from 47 to 86 tests (83% increase)
  across P0–P3 priority tiers.

### Changed
- **Inline custom type fix**: Type-not-found check now falls back to
  `CUSTOM_TYPE_INCLUDE[$type]` before erroring, so process substitution works.
- **`DRY_RUN` in `_measure_and_emit`**: File stats counted but content not
  emitted when dry-running.
- **79-col line limit**: All lines reformatted to stay within 79 columns.
- **`no-agents` / `no-tree` removed from config**: Agents disabled via
  `agents-file=` (empty string). Tree control is CLI-only (`-T`).

## [0.3.1]
### Changed
- **Reverted dynamic heading customization**: Removed `context-heading`,
  `tree-heading`, and `file-header` from `.ktxrc` configurations.
- **Streamlined output toggles**: Dropped granular CLI flags (`--no-header`,
  `--no-instr`, `--no-context-heading`). `--raw` exclusively handles clean
  text-only output.
- **Usage menu formatting**: Reorganized CLI help into cleaner single-column
  layout.

## [0.3.0]
### Added
- **Granular output control flags**: `--no-agents`, `--no-header`,
  `--no-instr`, `--no-context-heading`. All toggles also configurable in
  `.ktxrc`.
- **Config toggles for output sections**: `no-agents=true`, `no-tree=true`,
  etc. in `.ktxrc`.

### Changed
- **`--raw` behavior aggregated**: Sets all `--no-*` flags internally for
  pipe-friendly output.
- **Default agent header synced**: Explicitly documented and mirrored in
  `.ktxrc.example`.

## [0.2.9]
### Fixed
- **Modifier +/- semantics for directories**: `+dirname` correctly un-excludes
  a directory, `-dirname` excludes a directory.
- **Modifier +/- with globs**: `+glob` adds to includes AND force-includes;
  `-glob` removes from includes.

### Changed
- **Help text updated**: Clearer directory vs file and glob vs plain-name
  distinction.

## [0.2.8]
### Changed
- **Major code refactor**: Reduced ktx from 989 to ~516 lines (48% reduction).
- **Simplified declarations**: Combined multi-line statements into compact form.
- **Removed trace helper functions**: Replaced with single `_trace_config`.

### Fixed
- **Modifier logic consolidated**: Cleaner `apply_mods()` implementation.

## [0.2.7]
### Changed
- **Trace system completely overhauled**: `-t` shows compact config + skip
  reasons; `-tt` adds accepted file logging with token counts. Single
  `_trace_config` function prints one compact block.

### Removed
- **Filtering summary**: Redundant with stats table.
- **Version line in trace**: Use `ktx -v` instead.
- **`SHOW_IGNORED` variable**: Replaced by `TRACE_LEVEL`.

## [0.2.6]
### Added
- **`--no-header` flag**: Suppresses `### filename` headers in output.
- **Deterministic output order**: Files sorted lexicographically by default.
- **New global blocklist entries**: `*.whl`, `*.egg`, `*.tar`, `.terraform`,
  `*.tfstate.backup`.

### Changed
- **`--raw` now implies `--no-tree`**: Raw mode is truly pipe-friendly.
- **`--limit` validation**: Rejects non-numeric values with clear error.
- **Directory handling**: Strips trailing slash from paths.

### Removed
- **`src.py` splitting heuristic**: Removed surprising dir+type auto-split.

## [0.2.5]
### Fixed
- **Token total calculation**: Fixed `EXT_TOK[ext]` treated as literal string
  instead of `$ext` variable expansion.

### Changed
- **79-character line limit**: All code reformatted to stay within 79 columns.
- **Always-excluded dirs merged**: `ALWAYS_EXCLUDE_DIRS` deleted; values now
  in `EXCLUDE_DIRS[default]`.
- **Removed `_build_gbl_excl`**: `_GBL_EXCL` defined directly as quoted array.
- **Decomposed large functions**: `run_find`/`run_files` split into
  `_build_find_args`, `_collect_file_list`, `_init_git_ignored`,
  `_should_skip`, `_measure_and_emit`.

### Removed
- **Dead code**: `tok_est_file` (never called).

## [0.2.4]
### Changed
- **Modifier semantics simplified**: `+` always adds to include patterns;
  `-` with globs removes from includes, `-` with plain names removes from
  excluded dirs.
- **`with=` now works for pattern types**: Merges via BFS DAG traversal.
- **Free-form argument order**: Options, modifiers, dir, .type can be mixed.

### Added
- **`_merge_pattern_type` function**: Merges include/exclude across `with=` DAG.
- **`_is_glob` helper**: Extracted glob detection into named function.
- **Pattern composition example** in `.ktxrc.example`: `[type:fullstack]`.

### Fixed
- **Modifier `-` args no longer break option parsing**.
- **`-o` flag directory safety**: Won't consume directory as output file.
- **Type detection from basename only**: Dots in parent dirs ignored.

## [0.2.3]
### Changed
- **Cleaned up help text**: Removed bloated modifier docs, simplified to one
  line with examples.
- **Added pattern composition**: `_merge_pattern_type` with BFS DAG resolution.
- **Simplified modifier semantics**: `+` always adds to includes.

## [0.2.2]
### Added
- **`_file_ext` helper**: Proper extension detection for dotfiles with
  sub-extensions.

### Fixed
- **Stats table formatting**: Separate width tracking for Extension and Tokens
  columns; separator line properly sized.

## [0.2.1]
### Changed
- **`-o` behavior**: `-o` alone outputs to stdout (no clipboard); `-o FILE`
  writes to file.
- **Help text**: Updated `-l` and `-o` descriptions.

### Added
- **`--randomize` long option**: Alternative to `-r`/`--random`.

## [0.2.0]
### Changed
- **Reduced built-in types**: Only `default`, `js`, and `py` remain built-in.
  Removed `go`, `rs`, `c`, `java` presets (define in `.ktxrc`).
- **Renamed flag**: `-I`/`--show-ignored` → `-t`/`--trace`.

### Removed
- **Built-in type presets**: `go`, `rs`, `c`, `java` — moved to `.ktxrc`
  examples.

## [0.1.2]
### Added
- **Complete 4-layer filtering**: Directory pruning, include patterns, global
  file blocklist, gitignore — with per-layer skip counting.
- **`tok_est`/`tok_est_str` functions**: Token estimation helpers.
- **`GLOB_EXCLUDE_PATTERN`**: Pre-built glob for fast case matching.
- **`get_git_ignored` function**: Native gitignore via `git ls-files`.
- **`show_ignored_summary`**: Summary table of all ignored items.
- **Smart output destinations**: Proper `-o` with/without file handling.
- **`mapfile` header detection**: Avoids duplicate headers.

### Fixed
- **`set -e` crashes**: Counter increments converted to `VAR=$((VAR + 1))`.
- **Array existence checks**: Uses `-v` test instead of `+_`.

## [0.1.1]
### Fixed
- **Removed `set -x`**: Debug leftover dumping commands to stderr.
- **`set -f` for glob safety**: Prevents expansion in word helpers.
- **Counter increments**: All `((VAR++))` → `VAR=$((VAR + 1))` for `set -e`.
- **Config loading**: Fixed `load_ctxrc` directory loop boundary.
- **Missing flags**: Added `-v/--version` and `-c/--config` to parser.

### Added
- **New type presets**: `go`, `rs`, `c`, `java` fully implemented.
- **`FILE_COUNT` tracking**: Detects "no files found".

## [0.1.0]
### Added
- **Renamed `ctx` → `ktx`**, config `.ctxrc` → `.ktxrc` (backward compatible).
- **`--raw` flag**: Skip instruction header and `AGENTS.md` for clean output.
- **`--no-clip` flag**: Skip clipboard even when available.
- **`agent-header=` in `.ktxrc`**: Custom instruction header.
- **`-c FILE` flag**: Explicit config file path.
- **Separate type argument**: `ktx src/ .js` works alongside `ktx src/.js`.
- **File-list paths resolved relative to `.ktxrc` location** (`RC_DIR`).
- **`_is_known_include` function**: Dynamic include-pattern detection.
- **`_GBL_EXCL` pre-built array**: Global excludes split once at startup.
- **`--` option terminator**: Standard double-dash support.

### Changed
- **Renamed flag**: `-m/--max-tokens` → `-l/--limit`.
- **Always-excluded dirs separated** from per-type excludes.
- **`-type d` in find prune clause**: Only directories pruned.
- **Expanded global file blocklist**: OS files, secrets, media, binaries.

### Fixed
- **`set -e` safety**: All counters use `VAR=$((VAR + 1))`.
- **`set -f` balanced**: All pairs balanced across every code path.
- **Modifier application order**: `.ktxrc` global modifiers apply to declared
  type; CLI modifiers apply after resolution.
