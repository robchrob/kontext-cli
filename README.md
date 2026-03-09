# ktx
CLI util for 'Codebase → Context in clipboard' ingest.
Single bash file, zero deps.

```bash
ktx                               # all files → clipboard
ktx .py                           # Python files + configs
ktx src/ .js                      # JS/TS files under src/
ktx .py -r -l 50000 --raw         # random sample, raw, limited
ktx .py +'*.sql,Makefile' -'*.md' # add SQL+Makefile, drop md
ktx .py --no-clip -o ctx.txt      # save to file, no clipboard
ktx .py -n                        # dry run — tree + token estimate
ktx .py -tt                       # detailed debug trace on stderr

# Custom type on the fly
ktx -c <(echo -e '[type:go]\ninclude=*.go Makefile') .go
```

## Install
```bash
curl -fsSL \
  https://raw.githubusercontent.com/robchrob/kontext-cli/master/ktx \
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

Copied 44 files (~12,434 tokens) → clipboard
```

To control what's included in the output: disable the agents file
with `--no-agents`, skip the directory tree with `-T`, or strip all
formatting (headers, headings, tree, agents) at once with `--raw`.

## Options
```
ktx [options] [modifiers...] [dir] [.type]
```

| Flag | Description |
|------|-------------|
| `-o, --output [FILE]` | Write to file (no arg = stdout) |
| `-l, --limit N` | Token limit (unlimited if unset) |
| `-r, --randomize` | Randomize file order (default: sorted) |
| `-n, --dry-run` | Show tree + token estimate, no output |
| `-T, --no-tree` | Skip directory tree |
| `--no-agents` | Skip reading the agents file |
| `--raw` | No headers/tree/agents (pipe-friendly) |
| `-t, --trace` / `-tt` | Skipped files on stderr, `-tt` verbose |
| `-c, --config FILE` | Config file (default: `.ktxrc` up) |
| `--no-clip` | Skip clipboard |
| `-v, --version` | Show version |
| `-h, --help` | Show help |

## Types
Built-in: `.default` (all files + default excludes),
`.js`, `.py` (more coming soon™).
Custom types via [`.ktxrc`](#ktxrc).

Additional built-ins (think `.cpp`, `.rs`, `.go`) and default
entries are welcome through PRs — see [Contributing](#contributing).

## Modifiers
`+` includes, `-` excludes.
Supports comma-separated lists: `+'*.sql,*.graphql'`.

The token after the prefix determines what gets modified:

| Modifier | Token type | Effect |
|----------|-----------|--------|
| `+'*.sql'` | Glob (`*`) | Include `.sql` files |
| `-'*.md'` | Glob (`*`) | Stop including `.md` files |
| `-'build'` | Plain name | Exclude `build/` directory |
| `+'dist'` | Plain name | Un-exclude `dist/` directory |
| `+'.env'` | Known blocklist | Force-include `.env` |

**Glob characters**:
`*` matches any string, `?` matches one char,
`[abc]` matches character classes.
Standard shell glob patterns used in `case` matching.

## .ktxrc
Precedence: built-in → `.ktxrc` → CLI modifiers.
`.ktxrc` in project root or any parent — searches upward from the target directory.
Override: `-c path`.

### Quick Start
```bash
# Create a Go type and use it immediately
echo -e '[type:go]\ninclude=*.go Makefile' > .ktxrc
ktx .go
```

Or use an inline config for one-off runs:
```bash
ktx -c <(echo -e '[type:custom]\ninclude=*.foobar') .custom
```

### Filtering layers
Applied in order for every candidate file:
1. **Dir prune** — default excludes (`.git`, …) + type `exclude=` dir → `find -prune`
2. **Include patterns** — only files matching the type's globs pass (default: `*`)
3. **Global blocklist** — OS junk, secrets, binaries, media, lockfiles
4. **Gitignore** — (`git ls-files -oi --exclude-standard`) are skipped
5. **Token budget** — stops at `-l N`
Force-include (`+pattern`) overrides layer 3.

### Global directives
```toml
type=py                        # default type
limit=100000                   # token budget

# Output toggles (empty string disables)
instruction-header=Full code!  # custom header
agents-file=AGENTS.md          # agents file path
agents-file=                   # ← disables agents

+*.sql,Makefile                # modifier: include
-*.md                          # modifier: exclude
```

### Custom types — pattern-based
File discovery by glob.
`include=` selects files, `exclude=` prunes directories.
```toml
[type:go]
include=*.go *.json Makefile Dockerfile
exclude=vendor dist build

[type:docs]
include=*.md
```

```bash
ktx .go
```

Pattern types support `with=` to compose other types.
Include patterns and exclude dirs merge from all deps:
```toml
[type:fullstack]
with=js
include=*.py *.toml Dockerfile
exclude=__pycache__ .venv
```

```bash
ktx .fullstack    # includes js type + fullstack
```

### Custom types — file lists
List explicit file paths (one per line):
```toml
[type:api]
with=infra
src/api/routes.ts
src/api/middleware.ts
src/api/auth.ts

[type:infra]
src/db/schema.ts
src/db/index.ts
tsconfig.json
```

```bash
ktx .api    # includes api + infra files
```

### Type resolution
- A type is **file-list** if it has explicit paths,
  **pattern-based** if it uses `include=`. Cannot mix.
- `with=` merges dependencies: file-list types collect all files;
  pattern types merge include/exclude.
- `with=` composes transitively (BFS, cycle-safe).
- Resolution: CLI type → `with=` deps → built-in + `.ktxrc` + CLI mods → filtering.
- Use `-t` / `-tt` for trace info about execution.

## Prerequisites
- **Bash 4.0+**
- **coreutils**: `find`, `wc`, `tr`, `sort`, `mktemp`, `sed`
- **Optional**: `tree` or `tree-git-ignore` (dir tree)
- **Clipboard** (optional, auto-detected):
  - macOS: `pbcopy`
  - Linux/Wayland: `wl-copy`
  - Linux/X11: `xclip` or `xsel`
  - WSL/Windows: `clip.exe`

## Platform Support
| Platform | Status | Notes |
|----------|--------|-------|
| Linux | ✅ Supported | All features work |
| macOS | ✅ Supported | Requires Bash 4+ (Homebrew) |
| WSL | ✅ Supported | Clipboard via `clip.exe` |
| FreeBSD | ⚠️ Experimental | May need GNU coreutils |

## Contributing
Contributions welcome! Areas of interest:
- **New built-in types** — `.cpp`, `.rs`, `.go`, etc. Keep them robust and standard.
- **Default exclusions** —  What should be globally ignored but are missing.
- **Bug fixes and edge cases** — rough edges, cross-platform issues.

To contribute:
1. Edit `ktx` (follow the project style)
2. Run `./test_ktx.sh` — update or add tests as needed
3. Open a PR with a clear description

## License
MIT
