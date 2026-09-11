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
- Path traversal in `_tsf_find_local_bin` or `_tsf_find_tsconfig`
- Shell injection through argument pass-through

The following are **out of scope**:

- Vulnerabilities in `tsc`, `tsgo`, `npm`, or `grep` themselves
- Social engineering attacks
- Issues that require an attacker to already have write access to your shell config

## Thank You

Security researchers who report valid issues will be acknowledged in the
release notes.
```

---

## 📄 `CODEOWNERS`

```gitignore
# ============================================================
#  CODEOWNERS — tsforge
#  Author  : Jack
#  GitHub  : https://github.com/setuju
#  ============================================================
#
#  Default owner for everything in the repo.
#  See: https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners

*       @setuju

# Script & tooling
tsforge.sh              @setuju
Makefile                @setuju
Dockerfile              @setuju
shell.nix               @setuju
flake.nix               @setuju

# Documentation
README.md               @setuju
CONTRIBUTING.md         @setuju
CHANGELOG.md            @setuju
SECURITY.md             @setuju
docs/**                 @setuju

# CI & GitHub configuration
.github/**              @setuju