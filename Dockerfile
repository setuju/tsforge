# ============================================================
#  Dockerfile — tsforge reproducible test container
#  Author  : Jack
#  GitHub  : https://github.com/setuju
#  Website : https://saturumah.net
#
#  Stages:
#    base    — Node 22 slim + system deps
#    deps    — install npm dependencies
#    test    — run ShellCheck + smoke tests
#    runtime — minimal image with tsforge.sh installed
#
#  Usage:
#    docker build -t tsforge:test .
#    docker run --rm -v "$PWD:/workspace" tsforge:test
# ============================================================

# syntax=docker/dockerfile:1.7

# ---------------------------------------------------------------------------
# Stage 1: base — minimal Node 22 with required system tools
# ---------------------------------------------------------------------------
FROM node:22-bookworm-slim AS base

# Install system dependencies needed for tsforge.sh
# - bash: the script uses Bash 4.0+ features
# - grep: used by tsc-optimize
# - shellcheck: for linting the script
# - git: for cloning test fixtures
RUN apt-get update && apt-get install -y --no-install-recommends \
      bash \
      grep \
      shellcheck \
      git \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set bash as default shell for RUN commands
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /opt/tsforge

# ---------------------------------------------------------------------------
# Stage 2: deps — install npm dependencies (cached layer)
# ---------------------------------------------------------------------------
FROM base AS deps

# Copy only package files first for better layer caching
COPY package.json package-lock.json* ./

# Use npm ci for deterministic, reproducible installs
RUN --mount=type=cache,target=/root/.npm \
    npm ci --ignore-scripts

# Install tsgo (TypeScript 7 native compiler) as a dev dependency
RUN --mount=type=cache,target=/root/.npm \
    npm install --save-dev @typescript/native-preview

# ---------------------------------------------------------------------------
# Stage 3: test — run ShellCheck and smoke tests
# ---------------------------------------------------------------------------
FROM deps AS test

# Copy the tsforge script and test fixtures
COPY tsforge.sh ./
COPY test/ ./test/ 2>/dev/null || true

# Make the script executable
RUN chmod +x tsforge.sh

# ShellCheck lint (fail on warnings)
RUN shellcheck tsforge.sh

# Smoke test: source the script and verify key functions are defined
RUN bash -c '\
      source ./tsforge.sh && \
      command -v tsc-help    >/dev/null && echo "✅ tsc-help defined"    && \
      command -v tsc-fast    >/dev/null && echo "✅ tsc-fast defined"    && \
      command -v tsgo-fast   >/dev/null && echo "✅ tsgo-fast defined"   && \
      command -v tsc-optimize >/dev/null && echo "✅ tsc-optimize defined" && \
      command -v tsc-where   >/dev/null && echo "✅ tsc-where defined"   && \
      echo "🎉 All smoke tests passed" \
    '

# ---------------------------------------------------------------------------
# Stage 4: runtime — minimal image with tsforge.sh on PATH
# ---------------------------------------------------------------------------
FROM base AS runtime

# Create a non-root user for security
RUN groupadd --system --gid 1001 tsforge \
    && useradd --system --uid 1001 --gid tsforge --create-home tsforge

# Copy the script from the test stage
COPY --from=test --chown=tsforge:tsforge /opt/tsforge/tsforge.sh /usr/local/bin/tsforge.sh

# Install tsgo globally for the runtime user
RUN npm install -g @typescript/native-preview \
    && npm cache clean --force

# Copy a welcome message
RUN echo 'source /usr/local/bin/tsforge.sh' >> /etc/bash.bashrc

USER tsforge

WORKDIR /workspace

# Default command: drop into a bash shell with tsforge loaded
CMD ["/bin/bash"]
```

### `package.json` (for the container)

```json
{
  "name": "tsforge-test",
  "version": "1.0.0",
  "private": true,
  "description": "Reproducible test environment for tsforge",
  "scripts": {
    "test": "shellcheck tsforge.sh && bash -c 'source ./tsforge.sh && tsc-help'",
    "lint": "shellcheck tsforge.sh"
  },
  "devDependencies": {
    "typescript": "^5.7.0",
    "@typescript/native-preview": "^1.0.0"
  }
}
```