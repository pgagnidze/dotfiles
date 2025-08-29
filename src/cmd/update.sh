#!/usr/bin/env bash
set -euo pipefail

readonly POMARCHY_ROOT="${POMARCHY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "${POMARCHY_ROOT}/src/lib/common.sh"

update_pomarchy() {
    log STEP "Updating Pomarchy"

    cd "${POMARCHY_ROOT}"

    if [[ ! -d ".git" ]]; then
        log ERROR "Not a git repository. Cannot update automatically."
        log INFO "Please download the latest version manually from the repository."
        exit 1
    fi

    log INFO "Fetching latest changes..."
    if ! git fetch origin; then
        log ERROR "Failed to fetch updates from remote repository"
        exit 1
    fi

    local current_branch
    current_branch=$(git branch --show-current)
    local behind_count
    behind_count=$(git rev-list --count HEAD..origin/"${current_branch}" 2>/dev/null || echo "0")

    if [[ "$behind_count" == "0" ]]; then
        log INFO "Pomarchy is already up to date"
        return 0
    fi

    log INFO "Found ${behind_count} new update(s)"

    if [[ "${YES:-false}" != true ]]; then
        echo ""
        log INFO "Recent changes:"
        git log --oneline --graph --decorate HEAD..origin/"${current_branch}" | head -10
        echo ""
        read -rp "Update to latest version? (y/N) "
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log INFO "Update cancelled"
            exit 0
        fi
    fi

    if [[ -n $(git status --porcelain) ]]; then
        log WARN "You have local changes. Stashing them before update..."
        git stash push -m "Auto-stash before pomarchy update $(date)"
        local stashed=true
    else
        local stashed=false
    fi

    log INFO "Pulling latest changes..."
    if git pull origin "${current_branch}"; then
        log INFO "Update completed successfully!"

        if [[ "$stashed" == true ]]; then
            log INFO "Your local changes were stashed. Use 'git stash pop' to restore them."
        fi

        log INFO "Run 'pomarchy doctor' to verify everything is working correctly"
    else
        log ERROR "Update failed. Please resolve any conflicts manually."
        exit 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    update_pomarchy
fi
