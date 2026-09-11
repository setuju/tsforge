# tsconfig.json Optimization Guide

This guide explains the compiler options that `tsc-optimize` checks for,
why they matter, and when **not** to enable them.

## `incremental: true`

**What:** Persists compilation state to a `.tsbuildinfo` file.
**Impact:** 50–90% faster rebuilds on subsequent runs.
**When to skip:** Never, unless you are running in a read-only filesystem.

```jsonc
{
  "compilerOptions": {
    "incremental": true,
    "tsBuildInfoFile": "./node_modules/.cache/tsconfig.tsbuildinfo"
  }
}
```

Setting `tsBuildInfoFile` inside `node_modules/` keeps the cache out of
your working tree and automatically ignored by git.

## `skipLibCheck: true`

**What:** Skips type-checking of all `.d.ts` files, including those in
`node_modules`.
**Impact:** Removes 30–60% of compile time in projects with many deps.
**When to skip:** Only if you are maintaining the `.d.ts` files yourself
and need to catch errors in them.

```jsonc
{
  "compilerOptions": {
    "skipLibCheck": true
  }
}
```

## `isolatedDeclarations: true`

**What:** Requires each file's exports to be annotated enough for `.d.ts`
generation without cross-file analysis.
**Impact:** Enables parallel declaration emit via bundlers. Speeds up
builds in large monorepos.
**When to skip:** If you cannot add explicit types to every export.
**Requires:** TypeScript 5.5+.

```jsonc
{
  "compilerOptions": {
    "isolatedDeclarations": true,
    "declaration": true
  }
}
```

## `composite: true`

**What:** Marks a project as a member of a project-references graph.
**Impact:** Required for `tsc --build` and incremental monorepo builds.
**When to skip:** Single-package projects.

```jsonc
{
  "compilerOptions": {
    "composite": true,
    "declarationMap": true
  }
}
```

## `noEmit: true`

**What:** Type-check only; do not write JavaScript.
**Impact:** Saves the emit phase entirely. Pairs with a bundler.
**When to skip:** When `tsc` is your build tool.

```jsonc
{
  "compilerOptions": {
    "noEmit": true
  }
}
```

## Recommended baseline

For a bundler-based project (Vite, Next, esbuild):

```jsonc
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "jsx": "react-jsx",
    "strict": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "skipLibCheck": true,
    "incremental": true,
    "tsBuildInfoFile": "./node_modules/.cache/tsconfig.tsbuildinfo"
  },
  "include": ["src/**/*.ts", "src/**/*.tsx"],
  "exclude": ["node_modules", "dist", "build", "out", "coverage"]
}
```

Run `tsc-optimize` to verify.