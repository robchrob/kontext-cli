# ktx
CLI util for 'Codebase → Context' ingest. Single bash file, zero deps.

```bash
ktx                                   # all files (filtered by defaults) → clipboard
ktx .py                               # Python files + configs → clipboard
ktx src/ .js                          # JS/TS files under src/
ktx .py -r -l 50000                   # random sample, stay under 50k tokens
ktx .py +'*.sql,Makefile' -'*.md'     # add SQL+Makefile, drop markdown
ktx .py -o ctx.txt                    # save to file + clipboard
ktx --raw -o                          # stdout only, skip all headers/tree/agents (pipe-friendly)
ktx .py -t                            # show what's skipped on stderr
ktx .py +'dist'                       # un-exclude dist/ (normally pruned)
ktx .py -'build'                      # exclude build/ directory

# Quick custom type on the fly
echo -e '[type:go]\ninclude=*.go Makefile' > .ktxrc
ktx .go
```

## Install
```bash
curl -fsSL https://raw.githubusercontent.com/rcdev/kontext-cli/main/ktx \
  -o ~/.local/bin/ktx && chmod +x ~/.local/bin/ktx
```

## Output
```
cd ~/python_proj && ktx .py
```

```
Extension      | Files | Tokens
---------------|-------|-------
.py            |    42 | 11,203
.toml          |     2 |    384
Context for: type: py, files: 44, tokens: 12,434
```
Content (in clipboard): instruction header → `## Context` heading → directory tree → `AGENTS.md` → files (ordered or `--randomize`), with `### path`.
You can disable the agents file via `--no-agents`, the directory tree via `-T`, or strip all formatting (headers, headings, tree, and agents) at once with `--raw` (pipe-friendly).

## Options
```
ktx [options] [modifiers...] [dir] [.type]
```

| Flag | Description |
|------|-------------|
| `-o, --output [FILE]` | Write to file (no arg = stdout) |
| `-l, --limit N` | Token limit (default/empty = unlimited) |
| `-r, --randomize` | Randomize file order (default: sorted/deterministic) |
| `-T, --no-tree` | Skip directory tree |
| `--no-agents` | Skip reading the agents file |
| `--raw` | Minimal output: skips headers, tree, and agents (pipe-friendly) |
| `-t, --trace` / `-tt` | Show skipped files on stderr, `-tt` for details |
| `-c, --config FILE` | Config file (default: nearest `.ktxrc` recursively up) |
| `--no-clip` | Skip clipboard |
| `-v, --version` | Show version |
| `-h, --help` | Show help |

## Types
Built-in: `.default` (all files), `.js`, `.py`.
Custom types via [`.ktxrc`](#ktxrc).

All types auto-exclude `.git .svn .hg .idea .vscode .vs` and a [global file blocklist](#default-exclusions).

Additional built-ins (think C++ `.cpp` or Rust `.rs`) and defaults (new filename/dir to ignore) can be added, and are welcome through PRs — see [Contributing](#contributing).

## Modifiers
`+` includes, `-` excludes. The token after the prefix determines what gets modified:

| Modifier | Token type | Effect |
|----------|-----------|--------|
| `+'*.sql'` | Glob (`*`) | Include `.sql` files |
| `-'*.md'` | Glob (`*`) | Stop including `.md` files |
| `-'build'` | Plain name | Exclude `build/` directory |
| `+'dist'` | Plain name | Un-exclude `dist/` directory (overrides type prune list) |
| `+'.env'` | Known include | Force-include `.env` (overrides global blocklist) |

**Glob characters**: `*` matches any string, `?` matches one character, `[abc]` matches character classes. These are standard shell glob patterns used in `case` matching against filenames.

Comma-separated: `+'*.sql,*.graphql'`. Precedence: built-in → `.ktxrc` → CLI modifiers.

## .ktxrc
Project config. Place in project root or any parent — searched upward from target dir. Also reads `.ctxrc`. Override: `-c path`.

### Quick Start with Custom Types
Create a custom type on the fly:
```bash
# Create a Go type and use it immediately
echo -e '[type:go]\ninclude=*.go go.mod go.sum Makefile' > .ktxrc
ktx .go
```

Or use an inline config for one-off runs:
```bash
ktx -c <(echo -e '[type:go]\ninclude=*.go go.mod') .go
```

### Filtering layers
Applied in order for every candidate file:
1. **Dir pruning** — always-excluded (`.git`, …) + type's `exclude=` dirs → `find -prune`
2. **Include patterns** — only files matching the type's globs pass (default: `*`)
3. **Global blocklist** — OS junk, secrets, binaries, media, lockfiles ([full list](#default-exclusions))
4. **Gitignore** — `git ls-files -oi --exclude-standard`
5. **Token budget** — stops at `-l N`
Force-include (`+pattern`) overrides layer 3.

### Global directives
```toml
type=py                               # default type for this project
limit=100000                          # token budget

# Output toggles
instruction-header=State full filename... # (empty string disables)
agents-file=AGENTS.md                 # (empty string disables)
no-tree=true                          # skip directory tree
no-agents=true                        # skip agents file inclusion

+*.sql,Makefile                       # modifier: add to active type
-*.md                                 # modifier: remove from active type
```

### Custom types — pattern-based
File discovery by glob. `include=` selects files, `exclude=` prunes directories.
```toml
[type:go]
include=*.go *.mod *.sum *.json Makefile Dockerfile
exclude=vendor dist build
```

```bash
ktx .go
```
Pattern types support `with=` to compose other types. Include patterns and exclude dirs are merged from all dependencies:

```toml
[type:fullstack]
with=js
include=*.py *.toml Dockerfile
exclude=__pycache__ .venv
```

```bash
ktx .fullstack    # includes JS/TS patterns + Python patterns
```

### Custom types — file lists
Explicit paths for domain slicing. Relative to `.ktxrc` location.
```toml
[type:api]
with=infra
src/api/routes.ts
src/api/middleware.ts

[type:infra]
src/db/schema.ts
package.json
```

```bash
ktx .api      # collects infra files first, then api files
```
`with=` composes types transitively (BFS, cycle-safe). Works for both file-list and pattern types.

### Type resolution
- A type is **file-list** if it contains explicit paths, **pattern-based** otherwise. Cannot mix in one type.
- `with=` merges dependencies: file-list types collect all files; pattern types merge include/exclude lists.
- Resolution order: CLI type → `with=` deps (BFS) → built-in + `.ktxrc` + CLI modifiers → filtering layers; use `--trace` or `-tt` for even more detailed info about execution.

See `.ktxrc.example` for Go, Rust, C/C++, Java presets, pattern composition, and file-list examples.

## Prerequisites
- **Bash 4.0+**
- **coreutils**: `find`, `wc`, `tr`, `sort`, `mktemp`, `sed` (standard on Linux/macOS)
- **Optional**: `tree` or `tree-git-ignore` (for directory tree output)
- **Clipboard** (optional, auto-detected):
  - macOS: `pbcopy` (built-in)
  - Linux/Wayland: `wl-copy` (`wl-clipboard`)
  - Linux/X11: `xclip` or `xsel`
  - WSL/Windows: `clip.exe` (built-in)

## Platform Support
| Platform | Status | Notes |
|----------|--------|-------|
| Linux | ✅ Supported | All features work |
| macOS | ✅ Supported | Requires Bash 4+ via Homebrew |
| WSL (Windows) | ✅ Supported | Uses clipboard via `clip.exe` |
| FreeBSD | ⚠️ Experimental | May need GNU coreutils |

## Contributing
Contributions are welcome! Areas where work can be done:
- **New built-in types** — C++ (`.cpp`), Rust (`.rs`), etc... We want to keep it robust, but standard.
- **Default exclusions** — new filenames or directories that should be ignored globally, might missed something obvious
- **Bug fixes and edge cases** — all rough edges, bugs and cross-platform issues

To contribute:
1. Make your changes to `ktx` (please adhere to general project standard)
2. Run `./test_ktx.sh` to verify nothing breaks - ADJUST OR ADD TEST CASES when neccessary! (`test_ktx.sh`)
3. Open a PR with a clear description of what changed and why, acceptance of PR is absolutely, obviously, never guaranteed.

## License
MIT
