.DEFAULT_GOAL := help

.PHONY: help install lint format

help: ## Show available commands
	@printf "Usage: make <command>\n\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

install: ## Install dev dependencies
	sudo dnf install -y ShellCheck shfmt

lint: ## Run shellcheck on bin scripts
	@shellcheck bin/*
	@echo "All scripts pass shellcheck"

format: ## Format bin scripts with shfmt
	@shfmt -w -i 4 -ci bin/*
	@echo "All scripts formatted"
