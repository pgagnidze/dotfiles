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
    echo "  • Installs essential packages (firefox, go, etc.)"
    echo "  • Installs AUR packages (awsvpnclient, k6-bin)"
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

SKIP_CONFIRM="${YES:-false}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help | -h | help)
            show_help
            exit 0
            ;;
        --yes | -y)
            SKIP_CONFIRM=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

setup_error_handling "packages"
pre_setup_validation

if [[ "${SKIP_CONFIRM}" == "false" ]]; then
    log STEP "Installing packages for Omarchy..."
    echo "This will remove unwanted packages and install essential packages."
    echo "Packages to remove: ${PACKAGES_REMOVE}"
    echo "Packages to install: ${PACKAGES_INSTALL}"
    echo ""
    read -rp "Do you want to continue? (y/N) "
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log INFO "Package installation cancelled."
        exit 0
    fi
fi

create_safety_backup "packages"

log STEP "Package Management"

readonly CORE_PACKAGES=("ttf-ubuntu-mono-nerd" "gnupg" "diff-so-fancy")
IFS=' ' read -ra REMOVE_PACKAGES <<<"$PACKAGES_REMOVE"
IFS=' ' read -ra INSTALL_PACKAGES <<<"$PACKAGES_INSTALL"

echo ""
log STEP "Removing unwanted packages..."
for pkg in "${REMOVE_PACKAGES[@]}"; do
    if yay -Qi "$pkg" &>/dev/null; then
        log INFO "Removing $pkg..."
        yay -Rns --noconfirm "$pkg" || log WARN "Failed to remove $pkg (might be already removed)"
    else
        log INFO "$pkg is not installed (skipping)"
    fi
done

echo ""
log STEP "Installing core packages (always installed)..."
for pkg in "${CORE_PACKAGES[@]}"; do
    if ! yay -Qi "$pkg" &>/dev/null; then
        log INFO "Installing core package: $pkg..."
        yay -S --noconfirm "$pkg" || log ERROR "Failed to install core package $pkg"
    else
        log INFO "Core package $pkg is already installed"
    fi
done

echo ""
log STEP "Installing optional packages..."
for pkg in "${INSTALL_PACKAGES[@]}"; do
    if ! yay -Qi "$pkg" &>/dev/null; then
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

log INFO "Package management complete!"
