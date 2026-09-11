# Changelog

All notable changes to tsforge will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Nothing yet. Be the first to contribute!

## [1.0.0] - 2026-09-11

### Added

- Initial release.
- Core commands: `tsc-fast`, `tsc-watch`, `tsgo-fast`.
- Diagnostics: `tsc-files`, `tsc-diag`, `tsc-diagx`, `tsc-trace`, `tsc-why`, `tsc-config`.
- Monorepo: `tsc-build`, `tsc-build-force`.
- Environment: `tsc-where`, `tsc-optimize`, `tsc-clean`.
- npm v12 security: `npm-audit-scripts`.
- Help: `tsc-help` / `tsforge-help`.
- Auto-discovery of local `tsc`/`tsgo` via walk-up from `$PWD`.
- Auto-discovery of nearest `tsconfig.json`.
- TTY-aware color output.
- Double-source guard.

[Unreleased]: https://github.com/setuju/tsforge/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/setuju/tsforge/releases/tag/v1.0.0
```

---

## 📄 `SECURITY.md`

```markdown
# Security Policy

## Supported Versions

| Version | Supported |
|---|---|
| 1.x     | ✅ |
| < 1.0   | ❌ |

## Reporting a Vulnerability

tsforge is a shell script that wraps `tsc` and `tsgo`. It does not process
untrusted input directly, but it does execute local binaries.

If you discover a security issue — for example, a way to make tsforge execute
an arbitrary binary, or a path-traversal issue in the walk-up discovery — please
report it responsibly.

**Do not open a public issue.**

Instead, use GitHub's [private vulnerability reporting](https://github.com/setuju/tsforge/security/advisories/new).

Include:

- A description of the issue
- Steps to reproduce
- The potential impact
- Any suggested fix

You will receive a response within 48 hours. If the issue is confirmed, a patch
will be released as soon as possible, and you will be credited (unless you
prefer to remain anonymous).

## Scope

The following are **in scope**:

- Arbitrary command execution via tsforge functions
- Path traversal in `_ts_find_local_bin` or `_ts_find_tsconfig`
- Shell injection through argument pass-through

The following are **out of scope**:

- Vulnerabilities in `tsc`, `tsgo`, `npm`, or `grep` themselves
- Social engineering attacks
- Issues that require an attacker to already have write access to your shell config

## Thank You

Security researchers who report valid issues will be acknowledged in the
release notes.