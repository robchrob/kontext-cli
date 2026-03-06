# ctx

Dump your codebase into LLM-ready context. Single Bash file, zero dependencies.

```
ctx .py           # Python project → clipboard (~12,400 tokens)
ctx src/.js       # JS/TS project in src/
ctx               # everything, current dir
```

No dependencies beyond Bash 4+ and coreutils. One file.

---

<!--
Topics: llm context-window bash cli code-to-prompt developer-tools clipboard codebase chatgpt claude prompt-engineering
-->

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/YOU/ctx/main/ctx -o ~/.local/bin/ctx && chmod +x ~/.local/bin/ctx
```

Or just copy the script anywhere on your `$PATH`.

## Why

You want to paste a project into Claude / ChatGPT / Gemini.
You don't want `node_modules`, lockfiles, PNGs, or `.pyc` in there.
You want token counts. You want it in one command.

That's it. That's ctx.

## Usage

```
ctx [options] [modifiers...] [directory][.type]
```

| Flag | Effect |
|------|--------|
| `-o FILE` | Write output to file |
| `-t` / `-T` | Enable / disable directory tree (default: on) |
| `-m N`, `--max-tokens N` | Stop when token budget reached |
| `--no-clip` | Don't copy to clipboard |
| `-h` | Show help |

### Types

| Type | Includes | Excludes |
|------|----------|----------|
| `.default` | `*` | `.git .svn .hg node_modules dist build .idea .vscode coverage` |
| `.py` | `*.py *.pyw *.pyi *.toml *.cfg *.ini *.json *.yml *.yaml *.md *.txt *.rst *.j2 Makefile Dockerfile` | `__pycache__ .venv venv .mypy_cache .pytest_cache .ruff_cache .tox *.egg-info htmlcov dist build` |
| `.js` | `*.js *.ts *.jsx *.tsx *.mjs *.cjs *.json *.html *.css *.scss *.svelte *.vue *.md` | `node_modules .next .nuxt .turbo bower_components dist build .nyc_output coverage` |
| `.go` | `*.go *.mod *.sum *.json *.yml *.yaml *.md *.toml Makefile Dockerfile` | `vendor dist build` |
| `.rs` | `*.rs *.toml *.json *.yml *.yaml *.md Makefile Dockerfile` | `target dist build` |
| `.c` | `*.c *.h *.cpp *.hpp *.cc *.cxx *.hh *.inl Makefile CMakeLists.txt *.cmake *.json *.yml *.yaml *.md` | `.cache build compile_commands.json` |
| `.java` | `*.java *.xml *.gradle *.properties *.yml *.yaml *.md` | `.gradle build target .idea out` |

All types also skip: lockfiles, binaries, images, fonts, archives, sourcemaps, `.db`, `.log` files.

### Modifiers

Tweak filters inline. Globs (`*`, `?`, `[`) route to include patterns; plain names route to exclude dirs.

```bash
ctx +'Makefile,*.sql' -'*.md' .py    # add Makefile + SQL, drop markdown
ctx +'vendor' .go                    # also exclude vendor/
ctx -'dist' .js                      # stop excluding dist/
```

## Output

```
$ ctx .py
Extension | Files | Tokens
----------|-------|-------
.py       |    42 | 11,203
.toml     |     2 |    384
.md       |     3 |    847
----------|-------|-------
Context for '.' (type: py) → clipboard (~12,434 tokens)
```

The output includes:
1. An instruction line for the LLM
2. `## Context for /absolute/path`
3. Directory tree (respects `.gitignore` + excludes)
4. `AGENTS.md` contents if present (system prompt)
5. Every matched file with `### path/to/file` headers

## How it works

- `find` with exclusion pruning + include glob matching
- Native `.gitignore` support via `git ls-files -oi --exclude-standard`
- Global blocklist catches binaries/media/locks via `case` glob (no subshells)
- Token estimate: `bytes × 100/680 + words × 65/100` (calibrated against tiktoken)
- Tree: prefers `tree-git-ignore`, falls back to `tree` + `.gitignore` integration
- Clipboard: auto-detects `pbcopy` (macOS), `wl-copy` (Wayland), `xclip`/`xsel` (X11), `clip` (Windows)

## AGENTS.md

If your project root contains `AGENTS.md`, ctx includes it as a system prompt section — useful for giving the LLM project-specific instructions alongside the code.

## .ctxrc Config

Place a `.ctxrc` file in your project root for persistent config. See [`.ctxrc.example`](.ctxrc.example) for a template:

```
type=py
+Makefile,*.sql
-*.md
max-tokens=100000
```

Supported directives: `type`, `max-tokens`, `+PAT`, `-PAT`

## License

MIT
