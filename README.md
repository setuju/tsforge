<!-- ============================================================
     tsforge — TypeScript Performance & Diagnostics Toolkit
     Author : Jack
     GitHub : https://github.com/setuju
     Web    : https://saturumah.net
     ============================================================ -->

<div align="center">

# ⚡ tsforge

**A collection of shell functions that make TypeScript type-checking faster, observable, and easier to debug.**

Stop waiting on `npx tsc --noEmit`. Start forging.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![TypeScript](https://img.shields.io/badge/TypeScript-7.0-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Maintained](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/setuju/tsforge/graphs/commit-activity)

[Quick Start](#-quick-start) · [Commands](#-commands) · [Why tsforge?](#-why-tsforge) · [Contributing](CONTRIBUTING.md)

</div>

---

## 📖 Table of Contents

- [⚡ tsforge](#-tsforge)
  - [📖 Table of Contents](#-table-of-contents)
  - [🎯 Why tsforge?](#-why-tsforge)
  - [✨ Features](#-features)
  - [🎬 Demo](#-demo)
    - [2. Register in your shell](#2-register-in-your-shell)
    - [3. Reload and verify](#3-reload-and-verify)
    - [4. Use from any project](#4-use-from-any-project)
  - [🧰 Commands](#-commands)
    - [Core Type-Checking](#core-type-checking)
    - [Diagnostics \& Profiling](#diagnostics--profiling)
    - [Project References (Monorepos)](#project-references-monorepos)
    - [Environment \& Health](#environment--health)
    - [npm v12 Security](#npm-v12-security)
    - [MISC](#misc)
  - [⚙️ Configuration](#️-configuration)
  - [🔬 How It Works](#-how-it-works)
  - [📋 Requirements](#-requirements)
  - [📜 License](#-license)
  - [👤 Author](#-author)

---

## 🎯 Why tsforge?

Every TypeScript developer runs the same command hundreds of times a day:

```bash
npx tsc --noEmit
```

And every time, it feels slower than it should. The reasons are well-documented but rarely addressed in one place:

| Problem | Impact | tsforge Solution |
|---|---|---|
| **`npx` overhead** | Adds 50–100ms per invocation just resolving the binary | Uses local `node_modules/.bin/tsc` directly via walk-up discovery |
| **No incremental caching** | `tsc` restarts from zero on every run | `tsc-optimize` detects missing `incremental: true` |
| **`node_modules` type-checking** | `tsc` processes thousands of `.d.ts` files unnecessarily | `tsc-optimize` detects missing `skipLibCheck: true` |
| **No visibility into bottlenecks** | "It's slow" — but where? Parse? Bind? Check? | `tsc-diagx` shows per-phase and per-file timings |
| **Wrong tsconfig active** | `extends` and `paths` resolution can be confusing | `tsc-config` shows the fully resolved config |
| **TypeScript 7 (native Go)** | 8–12x faster, but hard to adopt incrementally | `tsgo-fast` works alongside `tsc` with zero config changes |

tsforge wraps `tsc` and `tsgo` in ergonomic shell functions so you get **speed, visibility, and consistency** — from any project directory.

---

## ✨ Features

- 🔍 **Auto-discovery** — Walks up from `$PWD` to find `node_modules/.bin/tsc` or `tsgo`. Works from any subdirectory of any project.
- ⚡ **TypeScript 7 ready** — First-class support for `tsgo`, the native Go compiler (8–12x speedup on real codebases).
- 📊 **Rich diagnostics** — `--diagnostics`, `--extendedDiagnostics`, `--generateTrace` (Chrome/Perfetto), `--explainFiles`, and `--showConfig`.
- 🏗️ **Monorepo support** — `tsc-build` and `tsc-build-force` for project references with `--verbose`.
- 🩺 **Health checks** — `tsc-optimize` audits your `tsconfig.json` for `incremental`, `skipLibCheck`, `isolatedDeclarations`, and `composite`.
- 🧹 **Cache management** — `tsc-clean` removes stale `.tsbuildinfo` when results feel wrong.
- 🔒 **npm v12 aware** — `npm-audit-scripts` lists dependencies that request `preinstall`/`install`/`postinstall` scripts (blocked by default in npm v12).
- 🎨 **TTY-aware colors** — Auto-disables colors when output is piped, safe for CI logs.
- 🛡️ **Double-source guard** — Sourcing the script twice does not redefine functions.
- 📦 **Zero dependencies** — Pure Bash + `grep` + `time`. Nothing to install.

---

## 🎬 Demo

<!-- Uncomment the block below once `demo.gif` exists in the repo root.
     Generate it with: `make demo` (requires vhs, ttyd, ffmpeg).
     See docs/TROUBLESHOOTING.md for installation instructions.

<div align="center">
  <img src="demo.gif" alt="tsforge demo — fast TypeScript type-checking in action" width="800" />
</div>

-->

**See it in action** (generate the GIF locally):

```bash
git clone https://github.com/setuju/tsforge.git
cd tsforge
make demo        # requires vhs, ttyd, ffmpeg
```

**What the demo shows:**

| Scene | Command | What you see |
|---|---|---|
| 1 | `time npx tsc --noEmit` | The slow baseline — the problem tsforge solves |
| 2 | `source ~/tsforge.sh` + `tsforge-help` | Loading the toolkit and listing commands |
| 3 | `tsc-where` | Which `tsc` / `tsgo` / `tsconfig` is active |
| 4 | `tsc-optimize` | Auditing `tsconfig.json` for missing perf flags |
| 5 | `tsc-fast` | Fast type-check with timing |
| 6 | `tsc-diagx \| head -30` | Per-file diagnostics — where time goes |
| 7 | `tsgo-fast` | Native Go compiler — up to 10x faster |
| 8 | — | Outro with project URL |

> 💡 **Tip:** The GIF is generated from [`demo.tape`](demo.tape) using [VHS](https://github.com/charmbracelet/vhs). Every commit to `tsforge.sh` or `demo.tape` regenerates it automatically via the [`demo.yml`](.github/workflows/demo.yml) workflow.


---

## 📁 Repository Structure

```structure
tsforge/
├── tsforge.sh                          # Main script
├── package.json                        # npm metadata (for tooling & CI)
├── README.md                           # Primary documentation
├── LICENSE.md                          # MIT License
├── CONTRIBUTING.md                     # Contribution guide
├── CODE_OF_CONDUCT.md                  # Community standards
├── CHANGELOG.md                        # Version history
├── SECURITY.md                         # Security policy
├── CODEOWNERS                          # Auto-review assignment
├── Makefile                            # Convenience commands
├── shell.nix                           # Nix reproducible shell
├── flake.nix                           # Nix flake (modern)
├── Dockerfile                          # Multi-stage container
├── .dockerignore
├── demo.tape                           # VHS demo script
├── .gitignore
├── .editorconfig
├── .shellcheckrc
├── docs/
│   ├── ARCHITECTURE.md                 # How it works internally
│   ├── COMMANDS.md                     # Extended command reference
│   ├── TSconfig.md                     # tsconfig optimization guide
│   └── TROUBLESHOOTING.md              # Common issues & fixes
└── .github/
    ├── FUNDING.yml
    ├── dependabot.yml
    ├── ISSUE_TEMPLATE/
    │   ├── bug_report.md
    │   ├── feature_request.md
    │   └── config.yml
    ├── PULL_REQUEST_TEMPLATE.md
    └── workflows/
        ├── shellcheck.yml              # Lint on every push
        ├── test.yml                    # Smoke tests (Bash + Docker + Nix)
        ├── demo.yml                    # Auto-regenerate demo.gif
        └── release.yml                 # Tag → GitHub Release
```

---

## 🚀 Quick Start

### 1. Clone or download

```bash
curl -fsSL https://raw.githubusercontent.com/setuju/tsforge/main/tsforge.sh -o ~/tsforge.sh
chmod +x ~/tsforge.sh
```

### 2. Register in your shell

```bash
# For Bash
echo '[ -f "$HOME/tsforge.sh" ] && source "$HOME/tsforge.sh"' >> ~/.bashrc

# For Zsh
echo '[ -f "$HOME/tsforge.sh" ] && source "$HOME/tsforge.sh"' >> ~/.zshrc
```

### 3. Reload and verify

```bash
source ~/.bashrc   # or source ~/.zshrc
tsforge-help       # or just: tsc-help
```

### 4. Use from any project

```bash
cd /path/to/any/typescript/project
tsc-where          # confirm environment
tsc-optimize       # audit tsconfig
tsc-fast           # type-check with timing
```

---

## 🧰 Commands

### Core Type-Checking

| Command | What it does | When to use |
|---|---|---|
| `tsc-fast` | `tsc --noEmit` with `time` | Daily driver — the fastest path to "is my code valid?" |
| `tsc-watch` | `tsc --noEmit --watch` | During active development |
| `tsgo-fast` | `tsgo --noEmit` with `time` | When you need 8–12x faster type-checking |

```bash
tsc-fast                  # type-check current project
tsc-fast --pretty false   # extra flags pass through to tsc
tsgo-fast                 # native Go compiler (if installed)
```

### Diagnostics & Profiling

| Command | What it does | When to use |
|---|---|---|
| `tsc-files` | `tsc --noEmit --listFiles` | Find accidentally-included files |
| `tsc-diag` | Summary timing (parse/bind/check/emit) | Quick performance overview |
| `tsc-diagx` | Per-file type-checking times | When `tsc-diag` shows a bottleneck |
| `tsc-trace` | `tsc --noEmit --generateTrace <dir>` | Deep profiling in [Perfetto](https://ui.perfetto.dev) |
| `tsc-why` | `tsc --noEmit --explainFiles > file` | Track down unwanted file inclusions |
| `tsc-config` | `tsc --showConfig` | See the fully resolved config after `extends`/`paths` |

```bash
tsc-diagx                 # deep timing report
tsc-why tsc-explain.txt   # write explanation to file
tsc-trace tsc-trace-dir   # then open Perfetto
```

### Project References (Monorepos)

| Command | What it does | When to use |
|---|---|---|
| `tsc-build` | `tsc --build --verbose` | Rebuild only stale referenced projects |
| `tsc-build-force` | `tsc --build --force` | Full rebuild when `--build` skips something it shouldn't |

```bash
tsc-build                 # incremental monorepo build
tsc-build-force           # nuclear option
```

### Environment & Health

| Command | What it does | When to use |
|---|---|---|
| `tsc-where` | Shows which `tsc`/`tsgo`/`tsconfig` is active | Before debugging "why is it using the wrong config?" |
| `tsc-optimize` | Audits `tsconfig.json` for performance flags | After cloning a new repo |
| `tsc-clean` | Removes `.tsbuildinfo` cache files | When results feel stale after config changes |

```bash
tsc-where                 # environment dump
tsc-optimize              # tsconfig health check
tsc-clean                 # clear incremental cache
```

### npm v12 Security

| Command | What it does | When to use |
|---|---|---|
| `npm-audit-scripts` | Lists deps requesting install scripts | Before upgrading to npm v12 (July 2026) |

```bash
npm-audit-scripts         # build your allowlist
```

### MISC

| Command | What it does |
|---|---|
| `tsc-help` / `tsforge-help` | Show all commands |

---

## ⚙️ Configuration

tsforge is driven entirely by your existing `tsconfig.json`. The `tsc-optimize` command checks for these performance-critical flags:

```jsonc
{
  "compilerOptions": {
    // 50–90% faster rebuilds
    "incremental": true,

    // Skip .d.ts checking from node_modules
    "skipLibCheck": true,

    // Parallel .d.ts emit (TypeScript 5.5+)
    "isolatedDeclarations": true,

    // Required for project references
    "composite": true,

    // Keep build info inside node_modules (auto-ignored)
    "tsBuildInfoFile": "./node_modules/.cache/tsconfig.tsbuildinfo"
  }
}
```

Run `tsc-optimize` to see which flags are missing in your project.

---

## 🔬 How It Works

tsforge is a set of pure Bash functions. There is no binary, no build step, and no runtime.

1. **Binary discovery** — `_ts_find_local_bin` walks upward from `$PWD` until it finds `node_modules/.bin/tsc` (or `tsgo`). This means it works from `src/components/` just as well as from the project root.
2. **tsconfig discovery** — `_ts_find_tsconfig` does the same for `tsconfig.json`.
3. **Command dispatch** — Each public function (`tsc-fast`, `tsc-diagx`, etc.) is a thin wrapper that adds `_ts_header`, passes through all extra arguments, and optionally wraps in `time`.
4. **Color management** — Colors are only emitted when `[ -t 1 ]` is true. Piped output stays clean.

There is no magic. Read the [script](tsforge.sh) — it is heavily commented.

---

## 📋 Requirements

| Requirement | Notes |
|---|---|
| **Bash 4.0+** or **Zsh 5.0+** | Uses `local`, `printf`, `$'\033'` escape syntax |
| **`grep`** | Used by `tsc-optimize` |
| **`time`** (Bash builtin) | Used by `tsc-fast` and `tsgo-fast` |
| **TypeScript** | `npm install --save-dev typescript` |
| **`tsgo`** (optional) | `npm install --save-dev @typescript/native-preview` for 8–12x speedup |
| **npm 11.16.0+** (optional) | Required for `npm-audit-scripts` |

No macOS/Linux-specific binaries are used. Windows users can run tsforge under WSL, Git Bash, or MSYS2.

---

## 📜 License

MIT — see [LICENSE.md](LICENSE.md).

---

## 👤 Author

**Jack**

- GitHub: [@setuju](https://github.com/setuju)
- Website: [saturumah.net](https://saturumah.net)

If tsforge saves you time, consider giving it a ⭐ on GitHub.

---

<div align="center">

**tsforge** — *TypeScript, faster.*

Made with ☕ by [Jack](https://github.com/setuju) · [saturumah.net](https://saturumah.net)

</div>