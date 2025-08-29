#!/usr/bin/env bash
set -euo pipefail

readonly POMARCHY_ROOT="${POMARCHY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"
source "${POMARCHY_ROOT}/src/lib/common.sh"
load_config

show_help() {
    echo "Usage: pomarchy setup packages [OPTIONS]"
    echo ""
    echo "Install and configure packages for Omarchy Linux."
    echo ""
    echo "What this command does:"
    echo "  • Removes unnecessary packages (1password, spotify, etc.)"
    echo "  • Installs essential packages (firefox, code, micro, go, etc.)"
    echo "  • Installs AUR packages (awsvpnclient, k6-bin)"
    echo "  • Installs micro editor plugins (fzf, lsp, snippets, etc.)"
    echo "  • Sets Firefox as default browser"
    echo ""
    echo "Options:"
    echo "  --yes, -y    Skip confirmation prompts"
    echo "  --help, -h   Show this help message"
    echo ""
    echo "Examples:"
    echo "  pomarchy setup packages         # Install packages with confirmation"
    echo "  pomarchy setup packages --yes   # Install packages without prompts"
}

for arg in "$@"; do
    case "$arg" in
        --help|-h|help)
            show_help
            exit 0
            ;;
    esac
done

setup_error_handling "packages"
pre_setup_validation
create_safety_backup "packages" "$HOME/.config/micro/plug"

log STEP "Package Management"

readonly CORE_PACKAGES=("ttf-ubuntu-mono-nerd" "micro")
IFS=' ' read -ra REMOVE_PACKAGES <<< "$PACKAGES_REMOVE"
IFS=' ' read -ra INSTALL_PACKAGES <<< "$PACKAGES_INSTALL"

echo ""
log STEP "Removing unwanted packages..."
for pkg in "${REMOVE_PACKAGES[@]}"; do
    if yay -Qi "$pkg" &> /dev/null; then
        log INFO "Removing $pkg..."
        yay -Rns --noconfirm "$pkg" || log WARN "Failed to remove $pkg (might be already removed)"
    else
        log INFO "$pkg is not installed (skipping)"
    fi
done

echo ""
log STEP "Installing core packages (always installed)..."
for pkg in "${CORE_PACKAGES[@]}"; do
    if ! yay -Qi "$pkg" &> /dev/null; then
        log INFO "Installing core package: $pkg..."
        yay -S --noconfirm "$pkg" || log ERROR "Failed to install core package $pkg"
    else
        log INFO "Core package $pkg is already installed"
    fi
done

echo ""
log STEP "Installing optional packages..."
for pkg in "${INSTALL_PACKAGES[@]}"; do
    if ! yay -Qi "$pkg" &> /dev/null; then
        log INFO "Installing $pkg..."
        yay -S --noconfirm "$pkg" || log WARN "Failed to install $pkg"
    else
        log INFO "$pkg is already installed"
    fi
done

if [[ -n "$DEFAULT_BROWSER" ]]; then
    echo ""
    log INFO "Setting $DEFAULT_BROWSER as default browser..."
    xdg-settings set default-web-browser "$DEFAULT_BROWSER.desktop" || log WARN "Failed to set $DEFAULT_BROWSER as default"
fi

install_micro_plugins() {
    if [[ -z "$MICRO_PLUGINS" ]]; then
        return
    fi
    
    if ! command -v micro &> /dev/null; then
        log WARN "Micro editor not installed, skipping plugin installation"
        log INFO "To install micro plugins, ensure 'micro' is in PACKAGES_INSTALL"
        return
    fi
    
    local plugins_dir="$HOME/.config/micro/plug"
    IFS=' ' read -ra PLUGINS <<< "$MICRO_PLUGINS"
    
    if [[ ! -d "$plugins_dir" ]] || [[ -z "$(ls -A "$plugins_dir" 2>/dev/null)" ]]; then
        log INFO "Installing micro plugins..."
        for plugin in "${PLUGINS[@]}"; do
            micro -plugin install "$plugin"
        done
        log INFO "Micro plugin installation complete"
    else
        log INFO "Micro plugins already installed"
    fi
}

echo ""
log INFO "Installing micro editor plugins..."
install_micro_plugins

log INFO "Package management complete!"