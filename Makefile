.DEFAULT_GOAL := help

.PHONY: help setup install lint format

setup: ## Install dotfiles using GNU Stow
	@./setup

help: ## Show available commands
	@printf "Usage: make <command>\n\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

install: ## Install dev dependencies
	sudo dnf install -y ShellCheck shfmt

lint: ## Run shellcheck on scripts
	@shellcheck setup config/bin/.local/bin/*
	@echo "All scripts pass shellcheck"

format: ## Format scripts with shfmt
	@shfmt -w -i 4 -ci setup config/bin/.local/bin/*
	@echo "All scripts formatted"
