# Extended Command Reference

Full documentation for every public tsforge command, including flags,
examples, and expected output.

## Core

### `tsc-fast [args…]`

Runs `tsc --noEmit` in the current project, wrapped in `time`.

```bash
tsc-fast
tsc-fast --pretty false
tsc-fast --noUnusedLocals --noUnusedParameters
```

**When to use:** As your daily "is my code valid?" check.

### `tsc-watch [args…]`

Runs `tsc --noEmit --watch`.

```bash
tsc-watch
```

**When to use:** During active development, alongside your bundler's dev server.

### `tsgo-fast [args…]`

Runs `tsgo --noEmit` (TypeScript 7 native Go compiler) wrapped in `time`.

```bash
tsgo-fast
```

**When to use:** Large codebases where 8–12x speedup matters.
**Requires:** `npm i -D @typescript/native-preview`

## Diagnostics

### `tsc-files [args…]`

Lists every file included in the compilation.

```bash
tsc-files
tsc-files | grep -v node_modules
```

**When to use:** You suspect an unwanted file (test, fixture, generated)
is being type-checked.

### `tsc-diag [args…]`

Prints a summary timing report: parse, bind, check, emit.

```bash
tsc-diag
```

**When to use:** First step when the build "feels slow".

### `tsc-diagx [args…]`

Prints per-file type-checking times.

```bash
tsc-diagx
tsc-diagx | head -40
```

**When to use:** When `tsc-diag` shows `Check` is the bottleneck.

### `tsc-trace [dir]`

Generates a Chrome trace compatible with Perfetto.

```bash
tsc-trace
tsc-trace my-trace
```

**When to use:** Deep profiling. Open the result at <https://ui.perfetto.dev>.

### `tsc-why [file]`

Writes `--explainFiles` output to a file.

```bash
tsc-why
tsc-why why.txt
```

**When to use:** To answer "why is this file being compiled?".

### `tsc-config [args…]`

Runs `tsc --showConfig` to print the fully resolved configuration.

```bash
tsc-config
tsc-config | jq .compilerOptions
```

**When to use:** When `extends` or `paths` resolution is unclear.

## Monorepo

### `tsc-build [args…]`

Runs `tsc --build --verbose`.

```bash
tsc-build
```

**When to use:** Rebuilding a project-references monorepo incrementally.

### `tsc-build-force [args…]`

Runs `tsc --build --force`.

```bash
tsc-build-force
```

**When to use:** When `--build` skips a project you know is stale.

## Environment

### `tsc-where`

Prints which `tsc`, `tsgo`, and `tsconfig.json` are active.

```bash
tsc-where
```

**When to use:** Before filing a bug. Paste the output into the issue.

### `tsc-optimize`

Audits `tsconfig.json` for performance flags.

```bash
tsc-optimize
```

Checks for: `incremental`, `skipLibCheck`, `isolatedDeclarations`,
`composite`.

**When to use:** After cloning a new repo.

### `tsc-clean`

Removes `.tsbuildinfo` files.

```bash
tsc-clean
```

**When to use:** When type-checking results feel stale after a config change.

## Security

### `npm-audit-scripts`

Lists dependencies that request install scripts.

```bash
npm-audit-scripts
```

**When to use:** Before upgrading to npm v12, which blocks these by default.

## Misc

### `tsforge-help`

Prints the command index.

```bash
tsforge-help
```

Alias: `tsc-help`.