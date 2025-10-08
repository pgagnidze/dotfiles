#!/usr/bin/env bash
set -euo pipefail

readonly POMARCHY_ROOT="${POMARCHY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"
source "${POMARCHY_ROOT}/src/lib/common.sh"
load_config

show_help() {
    echo "Usage: pomarchy theme <COMMAND> [OPTIONS]"
    echo ""
    echo "Smart theme management commands:"
    echo ""
    echo "Commands:"
    echo "  list                Show all installed themes"
    echo "  use <theme|url>     Smart install/activate theme"
    echo "                      • Theme name → Activates installed theme"
    echo "                      • 'midnight' → Installs OLED-optimized theme"
    echo "                      • GitHub URL → Installs from repository"
    echo ""
    echo "What themes include:"
    echo "  • Configurations for Alacritty, btop, Chromium, Ghostty"
    echo "  • Hyprland, Hyprlock, Mako, Neovim, Swayosd, Walker, Waybar"
    echo ""
    echo "Options:"
    echo "  --yes, -y    Skip confirmation prompts"
    echo "  --help, -h   Show this help message"
    echo ""
    echo "Examples:"
    echo "  pomarchy theme list                           # Show installed themes"
    echo "  pomarchy theme use gruvbox                    # Activate installed theme"
    echo "  pomarchy theme use midnight --yes             # Install midnight without prompts"
    echo "  pomarchy theme use https://github.com/user/theme.git  # Install from URL"
}

detect_theme_type() {
    local input="$1"

    if [[ -z "$input" || "$input" == "midnight" ]]; then
        echo "predefined"
        return
    fi

    if [[ "$input" =~ ^https://github\.com/[^/]+/[^/]+\.git$ ]]; then
        echo "url"
        return
    fi

    if [[ -d "/home/$(whoami)/.config/omarchy/themes/$input" ]]; then
        echo "installed"
        return
    fi

    echo "unknown"
}

get_theme_url() {
    local theme_name="$1"
    case "$theme_name" in
        midnight | "")
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

install_theme_from_url() {
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
        log INFO "Theme is now available. Use 'pomarchy theme list' to see installed themes."
        log INFO "Activate by pressing Ctrl+Shift+Super+Space and selecting the theme"
    else
        log ERROR "Theme installation failed"
        exit 1
    fi
}

set_installed_theme() {
    local theme_name="$1"

    log INFO "Setting omarchy theme to: $theme_name..."

    if ! command -v omarchy-theme-set >/dev/null 2>&1; then
        log ERROR "omarchy-theme-set command not found"
        log ERROR "This command requires Omarchy Linux with omarchy-theme-set available"
        exit 1
    fi

    log INFO "Running omarchy-theme-set ${theme_name}..."
    if omarchy-theme-set "${theme_name}"; then
        log SUCCESS "Theme activated successfully!"
        log INFO "Theme '$theme_name' is now active"
    else
        log ERROR "Theme activation failed"
        exit 1
    fi
}

list_themes() {
    local themes_dir="$HOME/.config/omarchy/themes"

    if [[ ! -d "$themes_dir" ]]; then
        log ERROR "Themes directory not found: $themes_dir"
        exit 1
    fi

    log INFO "Installed omarchy themes:"
    echo ""

    local count=0
    for theme in "$themes_dir"/*; do
        if [[ -e "$theme" ]]; then
            local theme_name=$(basename "$theme")
            echo "  • $theme_name"
            ((count++)) || true
        fi
    done

    if [[ $count -eq 0 ]]; then
        echo "  No themes installed"
    else
        echo ""
        echo "Use: pomarchy theme use <theme_name>"
        echo "Or activate via: Ctrl+Shift+Super+Space"
    fi
}

SKIP_CONFIRM="${YES:-false}"
THEME_COMMAND=""
THEME_INPUT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help | -h | help)
            show_help
            exit 0
            ;;
        list)
            THEME_COMMAND="list"
            shift
            ;;
        use)
            THEME_COMMAND="use"
            shift
            if [[ $# -gt 0 && "$1" != --* ]]; then
                THEME_INPUT="$1"
                shift
            fi
            ;;
        --yes | -y)
            SKIP_CONFIRM=true
            shift
            ;;
        *)
            if [[ -z "$THEME_COMMAND" ]]; then
                echo "Error: Unknown command '$1'"
                echo "Use 'pomarchy theme --help' for usage information"
                exit 1
            fi
            shift
            ;;
    esac
done

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ "$THEME_COMMAND" == "list" ]]; then
        list_themes
        exit 0
    fi

    if [[ -z "$THEME_COMMAND" ]]; then
        if [[ -n "$THEME" ]]; then
            THEME_COMMAND="use"
            THEME_INPUT="$THEME"
            log INFO "Applying configured theme: $THEME"
        else
            show_help
            exit 0
        fi
    fi

    if [[ "$THEME_COMMAND" == "use" && -z "$THEME_INPUT" ]]; then
        echo "Error: 'use' command requires a theme name or URL"
        echo "Use 'pomarchy theme --help' for usage information"
        exit 1
    fi

    setup_error_handling "theme"

    if [[ "$THEME_COMMAND" == "use" ]]; then
        THEME_TYPE=$(detect_theme_type "$THEME_INPUT")

        case "$THEME_TYPE" in
            "predefined" | "url")
                THEME_URL=$(get_theme_url "$THEME_INPUT")
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
                install_theme_from_url "$THEME_URL"
                ;;

            "installed")
                if [[ "${SKIP_CONFIRM}" == "false" ]]; then
                    log STEP "Setting omarchy theme: $THEME_INPUT..."
                    echo "This will activate the '$THEME_INPUT' theme that is already installed."
                    echo ""
                    read -rp "Do you want to continue? (y/N) "
                    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                        log INFO "Theme activation cancelled."
                        exit 0
                    fi
                fi

                log STEP "Activating omarchy theme: $THEME_INPUT..."
                set_installed_theme "$THEME_INPUT"
                ;;

            "unknown")
                log ERROR "Unknown theme: $THEME_INPUT"
                log ERROR "Available options:"
                log ERROR "  • Use 'pomarchy theme list' to see installed themes"
                log ERROR "  • Use 'midnight' for the default OLED theme"
                log ERROR "  • Provide a GitHub URL ending in .git"
                exit 1
                ;;
        esac

        log INFO "Theme operation complete!"
    fi
fi
