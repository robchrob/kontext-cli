# Changelog
All notable changes to ctx will be documented in this file.

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
