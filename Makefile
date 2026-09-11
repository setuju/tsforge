# ============================================================
#  Makefile — tsforge
#  Author  : Jack
#  GitHub  : https://github.com/setuju
#  Web     : https://saturumah.net
# ============================================================

SCRIPT   := tsforge.sh
DEMO_TAPE := demo.tape
DEMO_GIF  := demo.gif
SHELL    := /usr/bin/env bash

.PHONY: help lint test smoke install uninstall demo demo-clean docker-build docker-test clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

lint: ## Run ShellCheck on the script
	@command -v shellcheck >/dev/null 2>&1 || { echo "❌ Install shellcheck first"; exit 1; }
	shellcheck $(SCRIPT)
	@echo "✅ ShellCheck passed"

test: smoke ## Alias for smoke

smoke: ## Source the script and run basic smoke tests
	@bash -c 'source ./$(SCRIPT) && \
		for fn in tsc-fast tsc-watch tsgo-fast tsc-files tsc-diag tsc-diagx \
		          tsc-trace tsc-why tsc-config tsc-build tsc-build-force \
		          tsc-where tsc-optimize tsc-clean npm-audit-scripts \
		          tsforge-help; do \
			command -v "$$fn" >/dev/null \
				|| { echo "❌ missing: $$fn"; exit 1; }; \
		done && echo "🎉 All smoke tests passed"'

install: ## Symlink to ~/tsforge.sh and register in shell rc
	@ln -sf "$(PWD)/$(SCRIPT)" "$$HOME/tsforge.sh"
	@for rc in "$$HOME/.bashrc" "$$HOME/.zshrc"; do \
		[ -f "$$rc" ] || continue; \
		grep -qF 'tsforge.sh' "$$rc" || \
			echo '[ -f "$$HOME/tsforge.sh" ] && source "$$HOME/tsforge.sh"' >> "$$rc"; \
	done
	@echo "✅ Installed. Restart your shell or run: source ~/.bashrc"

uninstall: ## Remove tsforge from shell rc files
	@sed -i.bak '/tsforge\.sh/d' "$$HOME/.bashrc" "$$HOME/.zshrc" 2>/dev/null || true
	@rm -f "$$HOME/tsforge.sh"
	@echo "🗑️  Uninstalled."

demo: ## Generate the demo GIF (requires vhs, ttyd, ffmpeg)
	@command -v vhs >/dev/null 2>&1 || { echo "❌ Install vhs: brew install vhs"; exit 1; }
	vhs $(DEMO_TAPE)
	@echo "✅ Generated $(DEMO_GIF)"

demo-clean: ## Remove generated demo GIF
	rm -f $(DEMO_GIF)
	@echo "🗑️  Removed $(DEMO_GIF)"

docker-build: ## Build the test container
	docker build -t tsforge:test .

docker-test: docker-build ## Run smoke tests inside the container
	docker run --rm tsforge:test bash -c '\
		source /usr/local/bin/tsforge.sh && \
		tsforge-help | head -3 && \
		echo "🎉 container smoke test passed"'

clean: demo-clean ## Remove generated artifacts
	@rm -f tsc-explain.txt
	@rm -rf tsc-trace/ tsc-trace-*/
	@echo "🧹 Cleaned."