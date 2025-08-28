.DEFAULT_GOAL := help

.PHONY: help install lint test clean

help: ## Show usage and commands
	@printf "Pomarchy - Personal Omarchy Setup\n\n"
	@printf "Usage: make <command>\n\n"
	@printf "Commands:\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-8s %s\n", $$1, $$2}'

install: ## Install development dependencies
	@if command -v yay >/dev/null 2>&1; then \
		yay -S --needed bats-core shellcheck; \
	else \
		sudo pacman -S --needed bats shellcheck; \
	fi

lint: ## Run shellcheck on all scripts
	@echo "Checking pomarchy main script..."
	@shellcheck --format=gcc --severity=error --shell=bash pomarchy
	@echo "Checking source scripts..."
	@shellcheck --format=gcc --severity=error --shell=bash $$(find src -name "*.sh")
	@echo "Checking test helpers..."
	@shellcheck --format=gcc --severity=error --shell=bash $$(find src -name "*.bash")
	@echo "All scripts pass shellcheck"

test: ## Run all tests
	@echo "Running all tests..."
	@find src -name "*.bats" -exec bats {} \;

clean: ## Clean test artifacts
	@rm -rf src/fixtures
	@find src -name "*.tmp" -delete 2>/dev/null || true

