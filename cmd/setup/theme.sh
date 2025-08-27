#!/usr/bin/env bash
set -euo pipefail

readonly POMARCHY_ROOT="${POMARCHY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "${POMARCHY_ROOT}/lib/common.sh"
load_config

show_help() {
    echo "Usage: pomarchy setup theme [THEME_URL] [OPTIONS]"
    echo ""
    echo "Install omarchy themes from GitHub repositories."
    echo ""
    echo "Available themes:"
    echo "  midnight    Dark OLED-optimized theme with inky blacks"
    echo "  [URL]       Any GitHub repository URL ending in .git"
    echo ""
    echo "What this command installs:"
    echo "  • Theme configurations for Alacritty, btop, Chromium, Ghostty"
    echo "  • Hyprland, Hyprlock, Mako, Neovim, Swayosd, Walker, Waybar themes"
    echo ""
    echo "After installation:"
    echo "  • Press Ctrl+Shift+Super+Space and select the theme to activate"
    echo ""
    echo "Options:"
    echo "  --yes, -y    Skip confirmation prompts"
    echo "  --help, -h   Show this help message"
    echo ""
    echo "Examples:"
    echo "  pomarchy setup theme                           # Install midnight theme"
    echo "  pomarchy setup theme midnight --yes            # Install midnight theme without prompts"
    echo "  pomarchy setup theme https://github.com/user/theme.git  # Install custom theme"
}

get_theme_url() {
    local theme_name="$1"
    case "$theme_name" in
        midnight|"")
            echo "https://github.com/JaxonWright/omarchy-midnight-theme.git"
            ;;
        *.git)
            if [[ "$theme_name" =~ ^https://github\.com/[^/]+/[^/]+\.git$ ]]; then
                echo "$theme_name"
            else
                log ERROR "Invalid GitHub URL format: $theme_name"
                log ERROR "Expected format: https://github.com/user/repo.git"
                exit 1
            fi
            ;;
        *)
            log ERROR "Unknown theme: $theme_name"
            log ERROR "Use 'midnight' or provide a full GitHub URL ending in .git"
            exit 1
            ;;
    esac
}

install_theme() {
    local theme_url="$1"
    local theme_name
    
    if [[ "$theme_url" == *"midnight"* ]]; then
        theme_name="midnight"
    else
        theme_name="$(basename "$theme_url" .git)"
    fi
    
    log INFO "Installing omarchy theme: $theme_name..."
    
    if ! command -v omarchy-theme-install >/dev/null 2>&1; then
        log ERROR "omarchy-theme-install command not found"
        log ERROR "This command requires Omarchy Linux with omarchy-theme-install available"
        exit 1
    fi
    
    log INFO "Running omarchy-theme-install ${theme_url}..."
    if omarchy-theme-install "${theme_url}"; then
        log SUCCESS "Theme installation completed successfully!"
        log INFO "Activate the theme by pressing Ctrl+Shift+Super+Space and selecting the theme"
    else
        log ERROR "Theme installation failed"
        exit 1
    fi
}

SKIP_CONFIRM="${YES:-false}"
USER_THEME=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h|help)
            show_help
            exit 0
            ;;
        --yes|-y)
            SKIP_CONFIRM=true
            shift
            ;;
        *)
            if [[ -z "$USER_THEME" ]]; then
                USER_THEME="$1"
            fi
            shift
            ;;
    esac
done

THEME_TO_INSTALL="${USER_THEME:-$THEME}"
THEME_URL=$(get_theme_url "$THEME_TO_INSTALL")
THEME_NAME=$(basename "$THEME_URL" .git)

if [[ "${SKIP_CONFIRM}" == "false" ]]; then
    log STEP "Installing omarchy theme: $THEME_NAME..."
    echo "This will install the '$THEME_NAME' theme for Omarchy."
    echo "The theme includes configurations for terminal, desktop, and applications."
    echo ""
    read -rp "Do you want to continue? (y/N) "
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log INFO "Theme installation cancelled."
        exit 0
    fi
fi

log STEP "Installing omarchy theme: $THEME_NAME..."
install_theme "$THEME_URL"
log INFO "Theme installation complete!"