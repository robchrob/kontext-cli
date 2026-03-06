# Changelog

All notable changes to ctx will be documented in this file.

## [0.3.0] - 2024-03-06

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

## [0.2.0] - 2024-02-XX

### Added
- Language type presets (`.js`, `.py`, `.go`, `.rs`)
- Inline modifiers (`+PAT`, `-PAT`)
- `AGENTS.md` inclusion
- Token estimation with statistics

## [0.1.0] - 2024-01-XX

### Added
- Initial release
- Basic find + tree output
- xclip clipboard support
