#!/usr/bin/env bash
set -euo pipefail

readonly POMARCHY_ROOT="${POMARCHY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "${POMARCHY_ROOT}/lib/common.sh"

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

log STEP "Package Management"

readonly REMOVE_PACKAGES=(
    "1password-beta"
    "1password-cli"
    "kdenlive"
    "obsidian"
    "pinta"
    "signal-desktop"
    "typora"
    "spotify"
)

readonly INSTALL_PACKAGES=(
    "firefox"
    "code"
    "lite-xl"
    "lua"
    "atuin"
    "micro"
    "go"
    "ttf-ubuntu-mono-nerd"
)

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
log STEP "Installing required packages..."
for pkg in "${INSTALL_PACKAGES[@]}"; do
    if ! yay -Qi "$pkg" &> /dev/null; then
        log INFO "Installing $pkg..."
        yay -S --noconfirm "$pkg" || log ERROR "Failed to install $pkg"
    else
        log INFO "$pkg is already installed"
    fi
done

echo ""
log STEP "Installing AUR packages..."

if ! yay -Qi awsvpnclient &> /dev/null; then
    log INFO "Installing AWS Client VPN from AUR..."
    yay -S --noconfirm awsvpnclient || {
        log WARN "awsvpnclient not found in AUR, you may need to install it manually"
        echo "Visit: https://docs.aws.amazon.com/vpn/latest/clientvpn-user/client-vpn-connect-linux.html"
    }
else
    log INFO "AWS Client VPN is already installed"
fi

if ! yay -Qi k6-bin &> /dev/null; then
    log INFO "Installing k6 from AUR..."
    yay -S --noconfirm k6-bin || log ERROR "Failed to install k6-bin"
else
    log INFO "k6 is already installed"
fi

echo ""
log INFO "Setting Firefox as default browser..."
xdg-settings set default-web-browser firefox.desktop || log WARN "Failed to set Firefox as default"

install_micro_plugins() {
    local plugins_dir="$HOME/.config/micro/plug"
    
    if [[ ! -d "$plugins_dir" ]] || [[ -z "$(ls -A "$plugins_dir" 2>/dev/null)" ]]; then
        log INFO "Installing micro plugins..."
        micro -plugin install fzf
        micro -plugin install editorconfig
        micro -plugin install detectindent
        micro -plugin install snippets
        micro -plugin install bookmark
        micro -plugin install lsp
        micro -plugin install wc
        log INFO "Micro plugin installation complete"
    else
        log INFO "Micro plugins already installed"
    fi
}

echo ""
log INFO "Installing micro editor plugins..."
install_micro_plugins

log INFO "Package management complete!"