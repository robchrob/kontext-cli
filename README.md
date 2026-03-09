# ktx
Codebase → LLM context. Single bash file, zero deps.

```bash
ktx                                   # cwd, all files (default, filtered as config/defaults) → clipboard
ktx .py                               # Python preset → clipboard
ktx src/ .js                          # JS/TS files in src/ dir
ktx .py -r -l 50000                   # random sample within <50k token size
ktx .py +'*.sql,Makefile' -'*.md'     # add SQL+Makefile, drop markdown
ktx .py -o ctx.txt                    # save to file + clipboard
ktx --raw -o                          # stdout only + raw (pipe-friendly)

# Quick custom type on the fly
echo -e '[type:go]\ninclude=*.go go.mod go.sum Makefile' > .ktxrc
ktx .go
```

## Prerequisites

- **Bash 4.0+** (macOS ships Bash 3 — `brew install bash`)
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
| WSL (Windows) | ✅ Supported | Uses Windows clipboard via `clip.exe` |
| FreeBSD | ⚠️ Experimental | May need GNU coreutils |

## Install
```bash
curl -fsSL https://raw.githubusercontent.com/rcdev/kontext-cli/main/ktx \
  -o ~/.local/bin/ktx && chmod +x ~/.local/bin/ktx
```

## Options
```
ktx [options] [modifiers...] [dir] [.type]
```

Options and arguments can be freely intermixed:

| Flag | Description |
|------|-------------|
| `-o, --output [FILE]` | Write to file (no arg = stdout) |
| `-l, --limit N` | Token limit (default = unlimited) |
| `-r, --randomize` | Randomize file order (default: sorted) |
| `-T, --no-tree` | Skip directory tree |
| `-t, --trace` | Show skipped files on stderr |
| `-c, --config FILE` | Config file (default: nearest `.ktxrc`) |
| `--raw` | No header, no AGENTS.md, no tree (pipe-friendly) |
| `--no-header` | Suppress `### filename` headers |
| `--no-clip` | Skip clipboard |
| `-v, --version` | Show version |
| `-h, --help` | Show help |

## Types
Built-in: `.default` (all files), `.js`, `.py`. Custom types via [`.ktxrc`](#ktxrc).

All types auto-exclude `.git .svn .hg .idea .vscode .vs` and a [global file blocklist](#default-exclusions).

## Modifiers
`+` includes, `-` excludes. The token after the prefix determines what gets modified:

| Modifier | Token type | Effect |
|----------|-----------|--------|
| `+'*.sql'` | Glob (`*`) | Include `.sql` files |
| `-'*.md'` | Glob (`*`) | Stop including `.md` files |
| `-'dist'` | Plain name | Stop skipping `dist/` directory |
| `+'.env'` | Plain name | Force-include `.env` (overrides global blocklist) |
| `+'Makefile'` | Known include | Include `Makefile` in results |

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
agent-header=Focus on error handling. # instruction header (empty = disable)
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
- Resolution order: CLI type → `with=` deps (BFS) → built-in + `.ktxrc` + CLI modifiers → filtering layers.

See `.ktxrc.example` for Go, Rust, C/C++, Java presets, pattern composition, and file-list examples.

## Output
```
Extension      | Files | Tokens
---------------|-------|-------
.py            |    42 | 11,203
.toml          |     2 |    384
Context for '.' (type: py) → clipboard (~12,434 tokens)
```

Content structure: instruction header → `## Context` heading → directory tree → `AGENTS.md` → files (`### path`).

`AGENTS.md` in target dir auto-included as system prompt (disable with `--raw`).

Token estimate: $\text{bytes} \times 100/680 + \text{words} \times 65/100$

## License
MIT

