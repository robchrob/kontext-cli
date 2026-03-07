# ktx

Codebase → LLM context. Single bash file, zero deps.

```bash
ktx                                   # all files, cwd → clipboard
ktx .py                               # Python project → clipboard
ktx src/ .js                          # JS/TS in src/
ktx -l 50000 .py                      # ~50k token budget
ktx -r -l 50000 .py                   # random sample within budget
ktx +'*.sql,Makefile' -'*.md' .py     # add SQL+Makefile, drop markdown
ktx -o ctx.txt --raw .py              # file output, no header/AGENTS.md
ktx .api                              # custom file-list type (.ktxrc)
```

Bash 4+, coreutils. Clipboard: `pbcopy` / `wl-copy` / `xclip` / `xsel`.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/user/kontext-cli/main/ktx \
  -o ~/.local/bin/ktx && chmod +x ~/.local/bin/ktx
```

## Options

```
ktx [options] [modifiers...] [dir] [.type]
```

| Flag | Description |
|------|-------------|
| `-o, --output [FILE]` | Write to file (no arg = stdout) |
| `-l, --limit N` | Token limit (default = unlimited) |
| `-r, --randomize` | Randomize file order |
| `-T, --no-tree` | Skip directory tree |
| `-t, --trace` | Show skipped files on stderr |
| `-c, --config FILE` | Config file (default: nearest `.ktxrc`) |
| `--raw` | No instruction header, no AGENTS.md |
| `--no-clip` | Skip clipboard |
| `-v, --version` | Show version |
| `-h, --help` | Show help |

## Types

Built-in: `.default`, `.js`, `.py`. Define custom types in `.ktxrc` using `[type:name]` sections with `include=`/`exclude=` patterns or explicit file lists. See `.ktxrc.example` for patterns to use for Go, Rust, C/C++, Java, etc.

All types exclude `.git .svn .hg .idea .vscode .vs` + [global file blocklist](#default-exclusions).

## Modifiers

Globs (`*?[`) → include patterns. Plain names → excluded dirs.

```bash
ktx +'*.sql' .py           # add to includes
ktx -'*.md' .py            # remove from includes
ktx +'vendor' .go          # add to excluded dirs
ktx -'dist' .js            # remove from excluded dirs
ktx +'.env' .py            # force-include (overrides global blocklist)
```

Precedence: built-in → `.ktxrc` → CLI.

## .ktxrc

Place in project root (or any parent). Searched upward from target dir. Override: `-c path`.

### Global directives

```ini
type=py                                # default type
limit=100000                           # token budget
agent-header=Focus on error handling.  # custom header (empty = disabled)
+*.sql,Makefile                        # add patterns
-*.md                                  # remove patterns
```

### Custom types — patterns

```ini
[type:docs]
include=*.md *.rst *.txt *.adoc
exclude=build _build site
```

```bash
ktx .docs                  # uses pattern-based discovery
```

### Custom types — file lists

Explicit paths for domain slicing. `with=` composes types (transitive, cycle-safe).

```ini
[type:api]
with=infra
src/api/routes.ts
src/api/middleware.ts

[type:infra]
src/db/schema.ts
src/lib/utils.ts
package.json
```

```bash
ktx .api                   # infra + api files → clipboard
```

Type uses file-list mode if it has paths; pattern mode otherwise. See `.ktxrc.example`.

## Output

```
Extension | Files | Tokens
----------|-------|-------
.py       |    42 | 11,203
.toml     |     2 |    384
Context for '.' (type: py) → clipboard (~12,434 tokens)
```

Content order: instruction header → `## Context` heading → directory tree → `AGENTS.md` → files with `### path/to/file` headers.

`AGENTS.md` in target dir auto-included as system prompt. Disable with `--raw`.

Token estimate: $\text{bytes} \times 100/680 + \text{words} \times 65/100$

<details>
<summary><strong>Default Exclusions</strong></summary>

**Always excluded dirs:** `.git` `.svn` `.hg` `.idea` `.vscode` `.vs`

**Global file blocklist:**
- **OS:** `.DS_Store` `Thumbs.db` `desktop.ini`
- **Secrets:** `.env` `.env.*` `.envrc` `*.pem` `*.key` `*.p12` `*.pfx` `.npmrc` `.netrc` `id_rsa*` `id_ed*` `*.secret` `*.credentials` `*.tfvars` `*.tfstate`
- **Compiled:** `*.pyc` `*.pyo` `*.so` `*.dylib` `*.dll` `*.o` `*.a` `*.obj` `*.class` `*.jar` `*.exe` `*.bin`
- **Media:** `*.png` `*.jpg` `*.jpeg` `*.gif` `*.ico` `*.svg` `*.webp` `*.bmp` `*.tiff` `*.woff` `*.woff2` `*.ttf` `*.eot` `*.otf` `*.mp3` `*.mp4` `*.wav` `*.avi` `*.mov` `*.webm` `*.pdf`
- **Archives:** `*.zip` `*.gz` `*.tgz` `*.rar` `*.7z` `*.bz2` `*.xz`
- **Generated:** `*.lock` `package-lock.json` `pnpm-lock.yaml` `*.min.js` `*.min.css` `*.map`
- **Data:** `*.db` `*.sqlite` `*.sqlite3` `*.log` `*.pid` `*.out`
- **Meta:** `LICENSE` `CHANGELOG` `compile_commands.json` `AGENTS.md` `.ktxrc`

Override any exclusion with `+PATTERN`.

</details>

## License

MIT
