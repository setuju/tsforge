# ============================================================
#  Dockerfile — tsforge reproducible test container
#  Author  : Jack
#  GitHub  : https://github.com/setuju
#  Website : https://saturumah.net
#
#  Stages:
#    base    — Node 22 slim + system deps
#    deps    — install npm dependencies (cached)
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

RUN apt-get update && apt-get install -y --no-install-recommends \
      bash \
      grep \
      shellcheck \
      git \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /opt/tsforge

# ---------------------------------------------------------------------------
# Stage 2: deps — install npm dependencies (cached layer)
# ---------------------------------------------------------------------------
FROM base AS deps

COPY package.json ./

RUN --mount=type=cache,target=/root/.npm \
    npm install --no-audit --no-fund

RUN --mount=type=cache,target=/root/.npm \
    npm install --save-dev @typescript/native-preview

# ---------------------------------------------------------------------------
# Stage 3: test — run ShellCheck and smoke tests
# ---------------------------------------------------------------------------
FROM deps AS test

COPY tsforge.sh ./
RUN chmod +x tsforge.sh

RUN shellcheck tsforge.sh

RUN bash -c '\
      source ./tsforge.sh && \
      for fn in tsc-fast tsc-watch tsgo-fast tsc-files tsc-diag tsc-diagx \
                tsc-trace tsc-why tsc-config tsc-build tsc-build-force \
                tsc-where tsc-optimize tsc-clean npm-audit-scripts \
                tsforge-help; do \
        command -v "$fn" >/dev/null \
          || { echo "missing: $fn"; exit 1; }; \
        echo "OK: $fn"; \
      done && echo "All smoke tests passed" \
    '

# ---------------------------------------------------------------------------
# Stage 4: runtime — minimal image with tsforge.sh on PATH
# ---------------------------------------------------------------------------
FROM base AS runtime

RUN groupadd --system --gid 1001 tsforge \
    && useradd --system --uid 1001 --gid tsforge --create-home tsforge

COPY --from=test --chown=tsforge:tsforge /opt/tsforge/tsforge.sh /usr/local/bin/tsforge.sh

RUN npm install -g @typescript/native-preview \
    && npm cache clean --force

RUN echo 'source /usr/local/bin/tsforge.sh' >> /etc/bash.bashrc

USER tsforge

WORKDIR /workspace

CMD ["/bin/bash"]
