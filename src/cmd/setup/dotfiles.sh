#!/usr/bin/env bash
set -euo pipefail

readonly POMARCHY_ROOT="${POMARCHY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"
source "${POMARCHY_ROOT}/src/lib/common.sh"
load_config

show_help() {
    echo "Usage: pomarchy setup dotfiles [OPTIONS]"
    echo ""
    echo "Install dotfiles configurations for terminal, editor, and shell."
    echo ""
    echo "What this command installs:"
    echo "  • Alacritty terminal with Omarchy theme integration"
    echo "  • Micro editor with plugins (fzf, lsp, snippets, bookmarks, etc.)"
    echo "  • Enhanced bash configuration with useful functions and aliases"
    echo ""
    echo "Bash enhancements added:"
    echo "  • cd() - Auto-list directory contents with eza/ls"
    echo "  • lsgrep() - Search directory contents with grep"
    echo "  • del() - Move files to /tmp/.trash instead of permanent deletion"
    echo "  • buf() - Backup file with timestamp (file.txt → file.txt_20231201_143022)"
    echo "  • alert() - Desktop notification when long commands complete"
    echo "  • tmuxp() - Quick tmux session management"
    echo "  • pomarchy - Global alias to run pomarchy from anywhere"
    echo ""
    echo "Options:"
    echo "  --yes, -y    Skip confirmation prompts"
    echo "  --help, -h   Show this help message"
    echo ""
    echo "Examples:"
    echo "  pomarchy setup dotfiles         # Install dotfiles with confirmation"
    echo "  pomarchy setup dotfiles --yes   # Install dotfiles without prompts"
}

stow_config() {
    if [[ -z "$DOTFILES" ]]; then
        log INFO "Skipping dotfiles installation (DOTFILES empty)"
        return
    fi
    
    log INFO "Installing dotfiles with stow..."
    
    if ! command -v stow >/dev/null 2>&1; then
        log WARN "Stow not found, installing..."
        ensure_command yay
        if ! yay -S --noconfirm stow; then
            log ERROR "Failed to install stow"
            exit 1
        fi
    fi
    
    IFS=' ' read -ra configs <<< "$DOTFILES"
    for config in "${configs[@]}"; do
        if [[ -d "${POMARCHY_ROOT}/src/config/${config}" ]]; then
            log INFO "Installing ${config} configuration..."
            stow -v -d "${POMARCHY_ROOT}/src/config" -t "${HOME}" "${config}"
        fi
    done
}

for arg in "$@"; do
    case "$arg" in
        --help|-h|help)
            show_help
            exit 0
            ;;
    esac
done

log STEP "Installing dotfiles..."
stow_config
if [[ -n "$DOTFILES" ]]; then
    log INFO "Dotfiles installation complete!"
fi