# Contributing to tsforge

First off — thank you for considering a contribution. tsforge exists because
TypeScript type-checking should be fast and observable. Every improvement,
no matter how small, makes that vision better.

## 📜 Code of Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code.

## 🐛 Reporting Bugs

Before opening an issue:

1. **Search existing issues** — someone may have already reported it.
2. **Run `tsforge-help`** and confirm you are on the latest version.
3. **Run `tsc-where`** and include the output in your issue.
4. **Run `tsc-diagx`** if the bug is performance-related, and include the output.

When opening an issue, include:

- Your OS and shell (`echo $SHELL`, `bash --version`)
- Node.js and TypeScript versions (`node -v`, `npx tsc -v`)
- The exact command you ran
- The full output (with `--pretty false` if tsc output is noisy)
- Steps to reproduce

## 💡 Suggesting Features

Open an issue with the `enhancement` label. Describe:

- The problem you are trying to solve
- Why existing commands do not solve it
- What the ideal command name and behavior would be
- Any edge cases you can think of

## 🛠️ Pull Requests

### Setup

```bash
git clone https://github.com/setuju/tsforge.git
cd tsforge
# No build step — it's pure Bash
```

### Testing

Source the script and run a few commands in a test project:

```bash
source ./tsforge.sh
tsforge-help
tsc-where
tsc-optimize
```

### Guidelines

- **One concern per PR.** Bug fix and feature should be separate PRs.
- **Keep functions small and focused.** Each public command should do one thing.
- **Comment non-obvious logic.** The script is meant to be readable.
- **Preserve pass-through behavior.** Extra arguments must reach `tsc`/`tsgo`.
- **Update `README.md`** if you add or change a command.
- **Update `CHANGELOG.md`** under the `[Unreleased]` section.

### Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add tsc-trace command for Perfetto profiling
fix: tsc-optimize now detects tsBuildInfoFile
docs: clarify monorepo usage in README
chore: bump version to 1.1.0
```

## 📐 Style Guide

- **Shell:** Bash 4.0+ compatible. Avoid Bashisms that break on macOS's Bash 3.2 unless guarded.
- **Naming:** Public commands are `kebab-case` (`tsc-fast`). Internal helpers are prefixed with `_ts_` (`_ts_find_local_bin`).
- **Colors:** Always use `_TS_RESET` after a color code. Never hardcode `\033[0m`.
- **Errors:** Write to `stderr` with `>&2`. Return non-zero on failure.
- **Output:** Use `printf`, not `echo -e`.

## 📄 License

By contributing, you agree that your contributions will be licensed under the
[MIT License](LICENSE.md).

---

*Thank you for making tsforge better.*