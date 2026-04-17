# ktx init — Design Specification

## Overview

`ktx init [dir]` discovers feature domains by **path-token clustering** — a
language-agnostic, convention-free structural analysis. Outputs a `.ktxrc` with
file-list types, `[type:infra]`, and a `[type:default]` catch-all with
migration hints.

## Algorithm

```
Input: directory path
Output: .ktxrc preview → user confirms → write

═══════════════════════════════════════════════════════
PHASE 1: MANIFEST — detect base language
═══════════════════════════════════════════════════════

Scan root for manifest files:
  package.json → js       go.mod → go
  pyproject.toml / setup.py / requirements.txt → py
  Cargo.toml → rs         build.gradle / pom.xml → java
  CMakeLists.txt → c

Purpose: determines which source extensions to scan
  js: *.ts *.tsx *.js *.jsx *.mjs *.cjs
  py: *.py *.pyi *.toml
  go: *.go
  rs: *.rs
  java: *.java *.gradle
  c: *.c *.h *.cpp

If no manifest: scan all non-binary extensions.

═══════════════════════════════════════════════════════
PHASE 2: WALK — collect all source files
═══════════════════════════════════════════════════════

find all files matching source extensions
exclude _GBL_EXCL patterns
exclude binary/media/lock patterns
result: array of file paths relative to root

═══════════════════════════════════════════════════════
PHASE 3: TOKENIZE — extract domain signals
═══════════════════════════════════════════════════════

For each file path, extract tokens from:
  - Directory names in path
  - File prefix (split on `-`, `_`, camelCase boundaries)

Stop-words (always removed):
  app api src lib components db scripts public static build dist out
  target vendor node_modules internal pkg cmd pages views controllers
  models services routes middleware helpers types interfaces schemas
  migrations seeds fixtures hooks ui styles assets config test tests
  spec __tests__ index main mod root

Stop-words (removed unless token appears 3+ times):
  data utils shared common resources handlers

═══════════════════════════════════════════════════════
PHASE 4: CLUSTER — group files by token
═══════════════════════════════════════════════════════

For each remaining token:
  count files that contain this token in their path
  if count >= 3: domain candidate

For each file:
  find the most specific (deepest) matching token in its path
  assign file to that token's cluster

Parent-child resolution:
  if token A's path is a prefix of token B's path
  AND both are domain candidates:
    B is a sub-domain → merge into A's cluster

═══════════════════════════════════════════════════════
PHASE 5: INFRA — detect shared foundation
═══════════════════════════════════════════════════════

Always created. Collects:
  - Root config files (manifest, tsconfig, Dockerfile, docker-compose,
    Makefile, CI configs, editor configs)
  - Files whose path has NO domain token after filtering
  - Files in known shared directories (db/, utils/, types/, ui/)

Infra utility name patterns for lib files:
  utils constants config env format helpers shared common
  database middleware types interfaces base core foundation

═══════════════════════════════════════════════════════
PHASE 6: REMAINDER → [type:default]
═══════════════════════════════════════════════════════

Files not assigned to any cluster or infra:
  - Route handlers with generic names
  - Lib files with unique names not matching any domain
  - Script files
  - Data files matching a token below threshold

Each file gets a comment hint:
  src/lib/analytics.ts              # → reporting?
  src/app/api/webhooks/route.ts     # → integrations?

Hints generated from file prefix tokens that matched a domain below
threshold or path proximity to domain directories.

═══════════════════════════════════════════════════════
PHASE 7: ASSEMBLE — generate .ktxrc
═══════════════════════════════════════════════════════

Output format:
  - Global settings: type=<first-domain>, limit=1000000
  - Standard headers
  - [type:infra] — always first
  - [type:<domain>] — each with with=infra
  - [type:default] — last, with migration hints

═══════════════════════════════════════════════════════
PHASE 8: PREVIEW + CONFIRM
═══════════════════════════════════════════════════════

Print summary:
  "── 5 domains: catalog, checkout, users, analytics, notifications"
  "── infra: 12 files"
  "── unmatched: 8 files (review [type:default])"

Print generated .ktxrc.
"Write to ./.ktxrc? [y/N]: "
If exists: backup → .ktxrc.bak, then write.
```

## Design Decisions

| Decision | Choice |
|---|---|
| Discovery method | Path-token clustering (no hardcoded conventions) |
| Min files for domain | 3 |
| Data file handling | Token-matched like everything else |
| Unmatched files | `[type:default]` with `# → domain?` hints |
| Infra | Always created |
| All domain types | `with=infra` |
| Output | Preview + confirm, backup if overwrite |

## Generic Examples

### Monorepo

```
packages/
  billing/
    src/index.ts, src/invoices.ts, src/payments.ts
  auth/
    src/index.ts, src/tokens.ts, src/sessions.ts
  catalog/
    src/index.ts, src/products.ts, src/categories.ts
```

→ tokens: billing(3), auth(3), catalog(3) → three types, each `with=infra`

### Go microservice (layer-organized)

```
internal/
  handler/create.go, list.go, delete.go
  repository/repository.go, queries.go
  service/service.go, validate.go
```

→ no domain tokens (handler, repository, service are stop-words) → single
`include=*.go` type

### Python FastAPI (layer-organized with domain files)

```
app/
  routers/orders.py, products.py, users.py
  models/order.py, product.py, user.py
  services/order_service.py, product_service.py, user_service.py
```

→ tokens: order(3), product(3), user(3) → three types despite layer
organization
