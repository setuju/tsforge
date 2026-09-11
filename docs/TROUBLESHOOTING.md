# Troubleshooting

## `tsc` is still slow after enabling `incremental`

**Symptom:** Second run is not noticeably faster.

**Causes & fixes:**

1. **The cache is being written somewhere ephemeral.**
   Check `tsBuildInfoFile`. If it points to a temp dir, it is wiped between
   runs. Use `./node_modules/.cache/tsconfig.tsbuildinfo`.

2. **`--noEmit` is being passed but `incremental` is ignored.**
   Older TypeScript versions required `--incremental` on the CLI. Verify
   `tsc --version` ≥ 4.0.

3. **The tsconfig is being reloaded from a different directory.**
   Run `tsc-config | grep tsBuildInfoFile` to confirm the resolved path.

## `tsc-optimize` says `skipLibCheck` is missing

Add it:

```jsonc
{ "compilerOptions": { "skipLibCheck": true } }
```

If you maintain your own `.d.ts` files, you may want to keep it `false`.
In that case, accept the slower build or split your types into a separate
`types/` project.

## `tsgo` says "not found" even though I installed it

Verify it exists:

```bash
ls -la node_modules/.bin/tsgo
```

If it does not, reinstall:

```bash
npm i -D @typescript/native-preview
```

If it exists but `tsc-where` reports "not found", you may be in a
subdirectory whose walk-up stops at a nested `node_modules/`. Run from the
project root, or use an absolute path.

## Colors are showing up in my CI logs

That should not happen — colors are TTY-gated. If it does, force-disable:

```bash
NO_COLOR=1 tsc-fast
```

Or redirect to a file, which also disables colors:

```bash
tsc-fast > build.log 2>&1
```

## `tsc-build` skips a package I know is stale

Use the force flag:

```bash
tsc-build-force
```

Then investigate why the `composite` project did not detect the change —
usually a missing `references` entry in the dependent's `tsconfig.json`.

## `tsc-why` output is enormous

Filter it:

```bash
tsc-why why.txt
grep -A2 'src/components' why.txt | head -40
```

Or run `tsc-files` instead if you only need the list.

## `npm-audit-scripts` prints nothing

You are on npm < 11.16.0, which does not support `approve-scripts`.
Upgrade:

```bash
npm install -g npm@latest
```

## Sourcing tsforge twice redefines my functions

That should be prevented by the `_TSFORGE_LOADED` guard. If you still see
it, check that the guard variable is not being unset elsewhere in your
shell config.