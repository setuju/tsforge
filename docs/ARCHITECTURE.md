# Architecture

tsforge is deliberately simple: a single sourced Bash file with a set of
thin wrappers around `tsc` and `tsgo`. This document explains the design
decisions behind it.

## Goals

1. **Speed** — Reduce the wall-clock cost of type-checking.
2. **Visibility** — Make it obvious where compilation time goes.
3. **Zero config** — Work in any project without editing files.
4. **Zero deps** — Require only Bash, `grep`, and `time`.
5. **Composability** — Pass through all extra arguments unchanged.

## Non-goals

- Replacing `tsc`. tsforge is a wrapper, not a compiler.
- Bundling. Use Vite, esbuild, or SWC for that.
- Cross-platform portability to Windows CMD or PowerShell.
- GUI or TUI.

## Layers

```
┌─────────────────────────────────────────────┐
│  Public commands  (tsc-fast, tsc-diagx, …)  │
├─────────────────────────────────────────────┤
│  Dispatch helpers (_tsf_tsc, _tsf_tsgo)     │
├─────────────────────────────────────────────┤
│  Discovery        (_tsf_find_local_bin,     │
│                    _tsf_find_tsconfig)      │
├─────────────────────────────────────────────┤
│  Output helpers   (_tsf_header, _tsf_ok, …) │
├─────────────────────────────────────────────┤
│  Color management (TTY-aware)               │
└─────────────────────────────────────────────┘
```

## Binary discovery

`_tsf_find_local_bin <name>` starts at `$PWD` and walks up the directory
tree. At each level it checks `<dir>/node_modules/.bin/<name>` for an
executable. The first hit wins.

This means:

- Running from `src/components/` finds `tsc` at the project root.
- Running from a monorepo sub-package finds that package's `tsc` first.
- Running outside any project falls back to the global `tsc` (with a warning).

## tsconfig discovery

`_tsf_find_tsconfig` performs the same walk, looking for `tsconfig.json`.
It is used by `tsc-optimize` and `tsc-where` to report which config is
active without requiring the user to `cd`.

## Argument pass-through

Every public command ends with `"$@"`. This is non-negotiable: users must be
able to append any `tsc` flag without tsforge swallowing it.

```bash
tsc-fast --pretty false --noUnusedLocals
```

## Color management

Colors are only emitted when `[ -t 1 ]` is true — i.e. when stdout is a
terminal. Piped output (e.g. `tsc-files | grep foo`) stays clean.

All color codes are stored in `_TF_*` variables. When the TTY check fails,
they are all set to the empty string, so no conditional logic is needed
at call sites.

## Double-source guard

`_TSFORGE_LOADED` prevents the script from redefining functions if it is
sourced twice (e.g. once in `.bashrc` and once manually). This avoids
confusing "command not found" errors from function overwrites.

## Why no `set -e`?

tsforge is sourced into an interactive shell. `set -e` would abort the
user's shell on any unexpected non-zero exit. Instead, each function
returns its own exit code and callers decide what to do.