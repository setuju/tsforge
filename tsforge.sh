#!/usr/bin/env bash
# ============================================================================
#  tsforge.sh — TypeScript Performance & Diagnostics Toolkit
# ============================================================================
#
#  Author  : Jack
#  GitHub  : https://github.com/setuju
#  Website : https://saturumah.net
#
#  Description:
#    A collection of shell functions that wrap the TypeScript compiler to
#    make type-checking faster, more observable, and easier to debug across
#    any project directory.
#
#  Features (2026-ready):
#    - Auto-discovers local tsc/tsgo from node_modules/.bin walking upward
#    - TypeScript 7 native Go compiler support (tsgo — up to 10x faster)
#    - Incremental compilation with .tsbuildinfo caching
#    - isolatedDeclarations for parallel .d.ts emit
#    - Project references support for monorepos
#    - Rich diagnostics: --diagnostics, --extendedDiagnostics, --explainFiles
#    - tsconfig health-check (incremental, skipLibCheck, isolatedDeclarations)
#    - npm v12 install-script safety helpers
#
#  Installation:
#    curl -fsSL https://raw.githubusercontent.com/setuju/tsforge/main/tsforge.sh \
#      -o ~/tsforge.sh
#    echo '[ -f "$HOME/tsforge.sh" ] && source "$HOME/tsforge.sh"' >> ~/.bashrc
#    source ~/.bashrc
#
#  Usage:
#    cd /any/project          # works from any directory
#    tsc-fast                 # fast type-check with timing
#    tsc-diagx                # deep performance diagnostics
#    tsforge-help             # show all commands
#
#  License: MIT — see LICENSE.md
# ============================================================================

# ---------------------------------------------------------------------------
# Guard: prevent double-sourcing
# ---------------------------------------------------------------------------
[ -n "${_TSFORGE_LOADED:-}" ] && return 0
_TSFORGE_LOADED=1

# ---------------------------------------------------------------------------
# Colors (auto-disabled when output is not a TTY)
# ---------------------------------------------------------------------------
if [ -t 1 ]; then
  _TF_RESET=$'\033[0m'
  _TF_RED=$'\033[31m'
  _TF_GREEN=$'\033[32m'
  _TF_YELLOW=$'\033[33m'
  _TF_BLUE=$'\033[34m'
  _TF_CYAN=$'\033[36m'
  _TF_DIM=$'\033[2m'
  _TF_BOLD=$'\033[1m'
else
  _TF_RESET=""; _TF_RED=""; _TF_GREEN=""; _TF_YELLOW=""
  _TF_BLUE=""; _TF_CYAN=""; _TF_DIM=""; _TF_BOLD=""
fi

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

# Walk up from $PWD to find an executable in node_modules/.bin/
# This makes every command work from any subdirectory of a project.
_tsf_find_local_bin() {
  local name="$1" dir="$PWD"
  while [ "$dir" != "/" ] && [ -n "$dir" ]; do
    if [ -x "$dir/node_modules/.bin/$name" ]; then
      printf '%s\n' "$dir/node_modules/.bin/$name"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

# Find the nearest tsconfig.json walking up from $PWD
_tsf_find_tsconfig() {
  local dir="$PWD"
  while [ "$dir" != "/" ] && [ -n "$dir" ]; do
    if [ -f "$dir/tsconfig.json" ]; then
      printf '%s\n' "$dir/tsconfig.json"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

# Resolve tsc binary: prefer local, fallback to global
_tsf_tsc() {
  local bin
  if bin="$(_tsf_find_local_bin tsc)"; then
    "$bin" "$@"; return $?
  fi
  if command -v tsc >/dev/null 2>&1; then
    tsc "$@"; return $?
  fi
  printf '%s❌ tsc not found.%s\n' "$_TF_RED" "$_TF_RESET" >&2
  printf '   Run: npm install --save-dev typescript\n' >&2
  return 127
}

# Resolve tsgo binary (TypeScript 7 native Go compiler, 8-12x faster)
_tsf_tsgo() {
  local bin
  if bin="$(_tsf_find_local_bin tsgo)"; then
    "$bin" "$@"; return $?
  fi
  if command -v tsgo >/dev/null 2>&1; then
    tsgo "$@"; return $?
  fi
  printf '%s❌ tsgo not found.%s\n' "$_TF_RED" "$_TF_RESET" >&2
  printf '   Install: npm i -D @typescript/native-preview\n' >&2
  printf '   Docs:    https://github.com/microsoft/typescript-go\n' >&2
  return 127
}

_tsf_header() { printf '%s▶ %s%s\n' "$_TF_BLUE" "$*" "$_TF_RESET"; }
_tsf_ok()     { printf '%s  ✅ %s%s\n' "$_TF_GREEN" "$*" "$_TF_RESET"; }
_tsf_warn()   { printf '%s  ⚠️  %s%s\n' "$_TF_YELLOW" "$*" "$_TF_RESET"; }
_tsf_fail()   { printf '%s  ❌ %s%s\n' "$_TF_RED" "$*" "$_TF_RESET"; }

# ===========================================================================
# PUBLIC COMMANDS
# ===========================================================================

# --- Core type-checking ---------------------------------------------------

# Fast type-check with timing. The bread-and-butter command.
# Uses incremental caching when tsconfig has "incremental": true.
tsc-fast() {
  _tsf_header "tsc --noEmit (from $PWD)"
  time _tsf_tsc --noEmit "$@"
}

# Watch mode: re-type-check on every file save.
tsc-watch() {
  _tsf_header "tsc --noEmit --watch"
  _tsf_tsc --noEmit --watch "$@"
}

# Native Go compiler: 8-12x faster than tsc on large projects.
# Requires: npm i -D @typescript/native-preview
tsgo-fast() {
  _tsf_header "tsgo --noEmit (native, TS 7)"
  time _tsf_tsgo --noEmit "$@"
}

# --- Diagnostics & profiling ----------------------------------------------

# Show every file included in compilation. Useful for catching
# accidental inclusions from node_modules or build folders.
tsc-files() {
  _tsf_header "tsc --noEmit --listFiles"
  _tsf_tsc --noEmit --listFiles "$@"
}

# Summary timing: parse / bind / check / emit phases.
tsc-diag() {
  _tsf_header "tsc --noEmit --diagnostics"
  _tsf_tsc --noEmit --diagnostics "$@"
}

# Per-file type-checking times. Use when tsc-diag shows a bottleneck.
tsc-diagx() {
  _tsf_header "tsc --noEmit --extendedDiagnostics"
  _tsf_tsc --noEmit --extendedDiagnostics "$@"
}

# Generate a Chrome trace for deep profiling.
# Open the output in chrome://tracing or https://ui.perfetto.dev
tsc-trace() {
  local out="${1:-tsc-trace}"
  _tsf_header "tsc --noEmit --generateTrace $out"
  _tsf_tsc --noEmit --generateTrace "$out"
  printf '%s📊 Trace written to %s/%s\n' "$_TF_CYAN" "$PWD" "$out" "$_TF_RESET"
  printf '   Analyze: https://ui.perfetto.dev\n'
}

# Explain why each file is included. Great for tracking down
# unwanted file inclusions in large projects.
tsc-why() {
  local out="${1:-tsc-explain.txt}"
  _tsf_header "tsc --noEmit --explainFiles > $out"
  _tsf_tsc --noEmit --explainFiles > "$out"
  printf '%s✅ Written to %s%s\n' "$_TF_GREEN" "$out" "$_TF_RESET"
  printf '   Read with: less %s\n' "$out"
}

# Show the resolved tsconfig after extends/paths resolution.
# Invaluable when you're unsure which config is actually active.
tsc-config() {
  _tsf_header "tsc --showConfig"
  _tsf_tsc --showConfig "$@"
}

# --- Project references (monorepos) ---------------------------------------

# Build all referenced projects. Only rebuilds stale ones.
# --verbose is the ONLY way to get verbose output from tsc.
tsc-build() {
  _tsf_header "tsc --build --verbose"
  _tsf_tsc --build --verbose "$@"
}

# Force full rebuild of all project references.
tsc-build-force() {
  _tsf_header "tsc --build --force"
  _tsf_tsc --build --force "$@"
}

# --- Environment inspection ------------------------------------------------

# Show which tsc/tsgo is being used and which tsconfig is active.
tsc-where() {
  _tsf_header "TypeScript environment"

  local bin tsconfig
  if bin="$(_tsf_find_local_bin tsc)"; then
    _tsf_ok "tsc (local)   : $bin"
  elif command -v tsc >/dev/null 2>&1; then
    _tsf_warn "tsc (global)  : $(command -v tsc)"
  else
    _tsf_fail "tsc not found"
  fi

  if bin="$(_tsf_find_local_bin tsgo)"; then
    _tsf_ok "tsgo (native) : $bin"
  elif command -v tsgo >/dev/null 2>&1; then
    _tsf_ok "tsgo (global) : $(command -v tsgo)"
  else
    _tsf_warn "tsgo not installed (install: npm i -D @typescript/native-preview)"
  fi

  if tsconfig="$(_tsf_find_tsconfig)"; then
    printf '%s  📄 tsconfig    : %s%s\n' "$_TF_CYAN" "$tsconfig" "$_TF_RESET"
  else
    _tsf_fail "tsconfig.json not found"
  fi

  if [ -f "$PWD/package.json" ]; then
    printf '%s  📦 package.json: %s%s\n' "$_TF_CYAN" "$PWD/package.json" "$_TF_RESET"
  fi
}

# --- tsconfig health-check -------------------------------------------------

# Check for performance-critical compilerOptions and suggest fixes.
tsc-optimize() {
  local cfg
  if ! cfg="$(_tsf_find_tsconfig)"; then
    _tsf_fail "tsconfig.json not found"
    return 1
  fi

  _tsf_header "Analyzing $cfg"
  local issues=0

  # incremental: true — 50-90% faster rebuilds
  if grep -Eq '"incremental"[[:space:]]*:[[:space:]]*true' "$cfg"; then
    _tsf_ok "incremental: true  (fast rebuilds)"
  else
    _tsf_fail "incremental: true  MISSING → add it for 50-90% faster rebuilds"
    issues=$((issues + 1))
  fi

  # skipLibCheck: true — skips .d.ts checking from node_modules
  if grep -Eq '"skipLibCheck"[[:space:]]*:[[:space:]]*true' "$cfg"; then
    _tsf_ok "skipLibCheck: true (skipping node_modules .d.ts)"
  else
    _tsf_fail "skipLibCheck: true MISSING → add it to skip node_modules checks"
    issues=$((issues + 1))
  fi

  # isolatedDeclarations: true — parallel .d.ts emit (TS 5.5+)
  if grep -Eq '"isolatedDeclarations"[[:space:]]*:[[:space:]]*true' "$cfg"; then
    _tsf_ok "isolatedDeclarations: true (parallel .d.ts emit)"
  else
    _tsf_warn "isolatedDeclarations: true not set (optional, speeds up declaration emit)"
  fi

  # composite: true — needed for project references
  if grep -Eq '"composite"[[:space:]]*:[[:space:]]*true' "$cfg"; then
    _tsf_ok "composite: true (project references enabled)"
  fi

  if [ "$issues" -gt 0 ]; then
    printf '\n%sSuggested fixes for %s:%s\n' "$_TF_YELLOW" "$cfg" "$_TF_RESET"
    printf '  Add inside "compilerOptions":\n'
    printf '    "incremental": true,\n'
    printf '    "skipLibCheck": true\n'
    printf '\n%sTip: add *.tsbuildinfo to .gitignore%s\n' "$_TF_DIM" "$_TF_RESET"
    return 1
  fi

  printf '%s✨ tsconfig looks optimal.%s\n' "$_TF_GREEN" "$_TF_RESET"
}

# Clear incremental build cache (use when results feel stale).
tsc-clean() {
  _tsf_header "Cleaning TypeScript caches"
  local removed=0

  # Default location (Node 18+)
  if [ -f "$PWD/.tsbuildinfo" ]; then
    rm -f "$PWD/.tsbuildinfo" && _tsf_ok "removed .tsbuildinfo" && removed=1
  fi

  # Custom location from tsconfig
  if [ -f "$PWD/node_modules/.cache/tsconfig.tsbuildinfo" ]; then
    rm -f "$PWD/node_modules/.cache/tsconfig.tsbuildinfo" \
      && _tsf_ok "removed node_modules/.cache/tsconfig.tsbuildinfo" && removed=1
  fi

  # Any *.tsbuildinfo in project root
  for f in "$PWD"/*.tsbuildinfo; do
    [ -f "$f" ] && rm -f "$f" && _tsf_ok "removed $f" && removed=1
  done

  [ "$removed" -eq 0 ] && _tsf_warn "no cache files found"
}

# --- npm v12 security helpers ---------------------------------------------

# List dependencies that request install scripts (preinstall/install/postinstall).
# npm v12 will block these by default — use this to build an allowlist.
# Ref: https://github.blog/changelog/2026-06-09-upcoming-breaking-changes-for-npm-v12/
npm-audit-scripts() {
  _tsf_header "Dependencies requesting install scripts (npm v12 preview)"
  if ! command -v npm >/dev/null 2>&1; then
    _tsf_fail "npm not found"; return 1
  fi
  npm approve-scripts --allow-scripts-pending 2>/dev/null \
    || printf '%s⚠️  npm < 11.16.0 — upgrade to see this list%s\n' "$_TF_YELLOW" "$_TF_RESET"
}

# --- Discovery & help ------------------------------------------------------

tsforge-help() {
  cat <<EOF
${_TF_BOLD}${_TF_BLUE}tsforge.sh${_TF_RESET} — TypeScript Performance & Diagnostics Toolkit
${_TF_DIM}Author: Jack · https://github.com/setuju · https://saturumah.net${_TF_RESET}

${_TF_BOLD}CORE TYPE-CHECKING${_TF_RESET}
  ${_TF_GREEN}tsc-fast${_TF_RESET}        tsc --noEmit with timing (use daily)
  ${_TF_GREEN}tsc-watch${_TF_RESET}       tsc --noEmit --watch
  ${_TF_GREEN}tsgo-fast${_TF_RESET}       tsgo --noEmit (native Go, 8-12x faster)

${_TF_BOLD}DIAGNOSTICS & PROFILING${_TF_RESET}
  ${_TF_GREEN}tsc-files${_TF_RESET}       List every file included in compilation
  ${_TF_GREEN}tsc-diag${_TF_RESET}        Summary timing (parse/bind/check/emit)
  ${_TF_GREEN}tsc-diagx${_TF_RESET}       Per-file type-checking times (deep)
  ${_TF_GREEN}tsc-trace${_TF_RESET}       Chrome trace for perfetto.dev analysis
  ${_TF_GREEN}tsc-why${_TF_RESET}         Explain why each file is included
  ${_TF_GREEN}tsc-config${_TF_RESET}      Show resolved tsconfig after extends/paths

${_TF_BOLD}PROJECT REFERENCES (MONOREPOS)${_TF_RESET}
  ${_TF_GREEN}tsc-build${_TF_RESET}       tsc --build --verbose (only stale projects)
  ${_TF_GREEN}tsc-build-force${_TF_RESET} tsc --build --force (full rebuild)

${_TF_BOLD}ENVIRONMENT & HEALTH${_TF_RESET}
  ${_TF_GREEN}tsc-where${_TF_RESET}       Which tsc/tsgo/tsconfig is active
  ${_TF_GREEN}tsc-optimize${_TF_RESET}    Check tsconfig for performance flags
  ${_TF_GREEN}tsc-clean${_TF_RESET}       Clear incremental build cache

${_TF_BOLD}NPM v12 SECURITY${_TF_RESET}
  ${_TF_GREEN}npm-audit-scripts${_TF_RESET} List deps requesting install scripts

${_TF_BOLD}MISC${_TF_RESET}
  ${_TF_GREEN}tsforge-help${_TF_RESET}     Show this help

All commands accept extra tsc flags, e.g.:
  tsc-fast --pretty false
  tsc-diagx --noUnusedLocals
EOF
}

# Alias for backward compatibility
tsc-help() { tsforge-help "$@"; }

# ============================================================================
#  Author  : Jack
#  GitHub  : https://github.com/setuju
#  Website : https://saturumah.net
# ============================================================================