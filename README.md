# ktx

Dump your codebase into LLM context. Single bash file, zero dependencies.

```bash
ktx .py                              # Python project → clipboard
ktx src/ .js                         # JS project in src/
ktx -l 50000 .py                     # Cap at ~50k tokens
ktx -r -l 50000 .py                  # Random sample within budget
ktx +'*.sql,Makefile' .py            # Include SQL files and Makefile
ktx -o context.txt .py               # Save to file + clipboard
ktx --raw .py                        # No AGENTS.md, no instruction header
ktx .health                          # Domain slice (file list from .ktxrc)
```

Requires `bash` 4+, `coreutils`. Clipboard: `pbcopy` / `wl-copy` / `xclip` / `xsel`.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/user/kontext-cli/main/ktx \
  -o ~/.local/bin/ktx && chmod +x ~/.local/bin/ktx
```

Or copy `ktx` anywhere on `$PATH`.

## Usage

```
ktx [options] [modifiers...] [dir] [.type]
```

### Options

| Flag | Long | Description |
|------|------|-------------|
| `-o` | `--output [FILE]` | Write to file. No FILE = clipboard only (silent) |
| `-T` | `--no-tree` | Skip directory tree |
| `-l` | `--limit N` | Token budget (`0` = unlimited) |
| `-r` | `--randomize` | Randomize file order |
| `-I` | `--ignored` | Print skipped files to stderr |
| `-c` | `--config FILE` | Config file (default: `.ktxrc` searched upward) |
|      | `--raw` | Disable instruction header and AGENTS.md |
| `-h` | `--help` | Help (includes version) |
| `-v` | `--version` | Print version |

### Types

Built-in types scan files by glob patterns:

| Type | Includes | Type-specific excludes |
|------|----------|------------------------|
| `default` | all files | — |
| `.py` | `*.py *.pyw *.pyi *.toml *.cfg *.ini *.json *.yml *.yaml *.md *.txt *.rst *.j2 Makefile Dockerfile` | `__pycache__ .venv venv .mypy_cache .pytest_cache .ruff_cache .tox *.egg-info htmlcov dist build` |
| `.js` | `*.js *.ts *.jsx *.tsx *.mjs *.cjs *.json *.html *.css *.scss *.svelte *.vue *.md` | `node_modules .next .nuxt .turbo bower_components dist build out coverage .nyc_output` |

All types also exclude `.git .svn .hg .idea .vscode .vs` and a [global blocklist](#default-exclusions) of binaries, secrets, media, and lock files.

Custom types (pattern-based or file-list) are defined in `.ktxrc`.

### Modifiers

Inline adjustments to the active type. Globs (`*`, `?`, `[`) modify include patterns; plain names modify excluded directories.

```bash
ktx +'*.sql,Makefile' .py            # add SQL + Makefile to includes
ktx -'*.md' .py                      # remove markdown from includes
ktx +'vendor' .go                    # add vendor/ to excluded dirs
ktx -'dist' .js                      # stop excluding dist/
ktx +'.env,LICENSE' .py              # force-include globally excluded files
```

Precedence: **built-in type → `.ktxrc` → CLI modifiers**.

## Configuration

### .ktxrc

Place `.ktxrc` in your project root (or any parent). `ktx` walks upward from the target directory to find the nearest one. Override with `-c path`.

```bash
# .ktxrc
type=py
limit=100000
agent-header=Focus on error handling and edge cases.
+*.sql,Makefile
-*.md
```

| Directive | Effect |
|-----------|--------|
| `type=NAME` | Default type when `.type` not given on CLI |
| `limit=N` | Token budget |
| `agent-header=TEXT` | Custom instruction header (empty = disabled) |
| `+PAT[,...]` | Add patterns (globs → includes, names → exclude dirs) |
| `-PAT[,...]` | Remove patterns |

### Custom Types — Patterns

Define types with glob-based file discovery using `include=` and `exclude=`:

```bash
# .ktxrc
[type:go]
include=*.go *.mod *.sum *.json *.yml *.yaml *.md *.toml Makefile Dockerfile
exclude=vendor dist build

[type:docs]
include=*.md *.rst *.txt *.adoc
exclude=build _build site
```

```bash
ktx .go                              # uses [type:go] from .ktxrc
ktx docs/ .docs                      # documentation only
```

### Custom Types — File Lists

List explicit file paths for precise domain slicing. Use `with=` to compose types:

```bash
# .ktxrc
[type:health]
with=infra
src/app/health/page.tsx
src/app/health/layout.tsx
src/components/health/BloodMarkerTrends.tsx
src/components/health/SleepDashboard.tsx
src/lib/health-scoring.ts
src/lib/oura.ts

[type:diet]
with=infra
src/app/diet/page.tsx
src/lib/diet-ai.ts
src/lib/diet-solver.ts

[type:infra]
src/app/layout.tsx
src/db/schema.ts
src/db/index.ts
src/lib/utils.ts
tsconfig.json
package.json
```

```bash
ktx .health          # infra + health files → clipboard
ktx .diet            # infra + diet files → clipboard
ktx .infra           # just infra
ktx -l 30000 .health # with token budget
ktx .js              # full JS scan (pattern-based, ignores file lists)
```

`with=` resolves transitively and handles cycles. A type uses **file list** mode if it has paths listed; otherwise it uses **pattern** mode (`include=`/`exclude=`).

See `.ktxrc.example` for a full template.

## Output

Stats to stderr, content to stdout (+ clipboard when available).

```
$ ktx .py 2>&1
Extension | Files | Tokens
----------|-------|-------
.py       |    42 | 11,203
.toml     |     2 |    384
.md       |     3 |    847
Context for '.' (type: py) → clipboard (~12,434 tokens)
```

Content structure:
1. Instruction header *(customizable, disabled with `--raw`)*
2. `## Context for /absolute/path`
3. Directory tree *(disabled with `-T`)*
4. `AGENTS.md` contents *(disabled with `--raw`)*
5. File contents with `### path/to/file` headers

Token estimation: $\text{bytes} \times 100/680 + \text{words} \times 65/100$, calibrated against tiktoken.

## AGENTS.md

If present in the target directory, contents are included before file contents. Disable with `--raw`.

```markdown
# AGENTS.md
FastAPI backend with SQLAlchemy. Use async/await.
Follow the repository pattern in app/repositories/.
```

<details>
<summary><strong>Default Exclusions</strong></summary>

**Always excluded directories:** `.git` `.svn` `.hg` `.idea` `.vscode` `.vs`

**Type-specific directories:**
- **py:** `__pycache__` `.venv` `venv` `.mypy_cache` `.pytest_cache` `.ruff_cache` `.tox` `*.egg-info` `htmlcov` `dist` `build`
- **js:** `node_modules` `.next` `.nuxt` `.turbo` `bower_components` `dist` `build` `out` `coverage` `.nyc_output`

**Global file blocklist:**
- **OS:** `.DS_Store` `Thumbs.db` `desktop.ini`
- **Secrets:** `.env` `.env.*` `.envrc` `*.pem` `*.key` `*.p12` `*.pfx` `.npmrc` `.netrc` `id_rsa*` `id_ed*` `*.secret` `*.credentials` `*.tfvars` `*.tfstate`
- **Compiled:** `*.pyc` `*.pyo` `*.so` `*.dylib` `*.dll` `*.o` `*.a` `*.obj` `*.class` `*.jar` `*.exe` `*.bin`
- **Media:** `*.png` `*.jpg` `*.jpeg` `*.gif` `*.ico` `*.svg` `*.webp` `*.bmp` `*.tiff` `*.woff` `*.woff2` `*.ttf` `*.eot` `*.otf` `*.mp3` `*.mp4` `*.wav` `*.avi` `*.mov` `*.webm` `*.pdf`
- **Archives:** `*.zip` `*.gz` `*.tgz` `*.rar` `*.7z` `*.bz2` `*.xz`
- **Locks:** `*.lock` `package-lock.json` `pnpm-lock.yaml`
- **Minified:** `*.min.js` `*.min.css` `*.map`
- **Data:** `*.db` `*.sqlite` `*.sqlite3` `*.log` `*.pid` `*.out`
- **Meta:** `LICENSE` `CHANGELOG` `compile_commands.json` `AGENTS.md` `.ktxrc`

Override any exclusion with `+PATTERN`.

</details>

## License

MIT
