#!/usr/bin/env bash
set -euo pipefail

readonly POMARCHY_ROOT="${POMARCHY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "${POMARCHY_ROOT}/lib/common.sh"
load_config
validate_config

show_help() {
    echo "Usage: pomarchy setup system [OPTIONS]"
    echo ""
    echo "Configure Omarchy Linux system settings for X1 Carbon Gen 13 OLED."
    echo ""
    echo "What this command does:"
    echo "  • Configures keyboard layouts (US/Georgian with Alt+Space switching)"
    echo "  • Sets up monitor configuration (2880x1800@120Hz, 2x scaling)"
    echo "  • Enables natural scrolling and touchpad settings"
    echo "  • Sets Waybar to 12-hour clock format"
    echo "  • Displays active keyboard layout in Waybar with click-to-switch"
    echo "  • Creates automatic configuration backup before changes"
    echo ""
    echo "Options:"
    echo "  --yes, -y    Skip confirmation prompts"
    echo "  --help, -h   Show this help message"
    echo ""
    echo "Examples:"
    echo "  pomarchy setup system           # Configure system with confirmation"
    echo "  pomarchy setup system --yes     # Configure system without prompts"
    echo ""
    echo "Note: Requires Hyprland restart to apply changes (Super+Esc → Relaunch)"
}

for arg in "$@"; do
    case "$arg" in
        --help|-h|help)
            show_help
            exit 0
            ;;
    esac
done

log STEP "System Configuration"

readonly HYPR_CONFIG_DIR="$HOME/.config/hypr"
readonly WAYBAR_CONFIG_DIR="$HOME/.config/waybar"

backup_to_snapshot() {
    local file="$1"
    local backup_dir="$2"
    if [[ -f "$file" ]]; then
        local relative_path="${file#"$HOME"/}"
        local backup_file_dir
        backup_file_dir="$(dirname "$backup_dir/$relative_path")"
        mkdir -p "$backup_file_dir"
        cp "$file" "$backup_dir/$relative_path"
    fi
}

BACKUP_DIR="${BACKUP_BASE_PATH:-$HOME/.config/omarchy-backups}/$(date +%Y%m%d_%H%M%S)"
readonly BACKUP_DIR
mkdir -p "$BACKUP_DIR"
log STEP "Creating configuration backup..."

readonly INPUT_CONF="$HYPR_CONFIG_DIR/input.conf"
readonly MONITOR_CONF="$HYPR_CONFIG_DIR/monitors.conf"  
readonly WAYBAR_CONFIG="$WAYBAR_CONFIG_DIR/config.jsonc"
readonly WAYBAR_STYLE="$WAYBAR_CONFIG_DIR/style.css"

backup_to_snapshot "$INPUT_CONF" "$BACKUP_DIR"
backup_to_snapshot "$MONITOR_CONF" "$BACKUP_DIR"
backup_to_snapshot "$WAYBAR_CONFIG" "$BACKUP_DIR"
backup_to_snapshot "$WAYBAR_STYLE" "$BACKUP_DIR"

log STEP "Configuring keyboard layouts and input..."

if [[ -n "$KEYBOARD_LAYOUTS" ]]; then
cat > "$INPUT_CONF" << EOF
input {
  kb_layout = $KEYBOARD_LAYOUTS
  kb_options = compose:caps,grp:alt_space_toggle

  repeat_rate = 40
  repeat_delay = 600

  touchpad {
    natural_scroll = ${NATURAL_SCROLL:-true}
    scroll_factor = 0.4
    disable_while_typing = ${DISABLE_WHILE_TYPING:-false}
  }
}

windowrule = scrolltouchpad 1.5, class:Alacritty
EOF
    log INFO "Keyboard layout switching configured ($KEYBOARD_LAYOUTS with Left Alt + Space)"
    log INFO "Natural scrolling $([ "$NATURAL_SCROLL" = "true" ] && echo "enabled" || echo "disabled") for touchpad"
    log INFO "Touchpad while typing $([ "$DISABLE_WHILE_TYPING" = "false" ] && echo "enabled" || echo "disabled")"
else
    log INFO "Skipping keyboard/input configuration (KEYBOARD_LAYOUTS empty)"
fi

log STEP "Configuring monitor settings..."


if [[ -n "$MONITOR_RESOLUTION" ]]; then
cat > "$MONITOR_CONF" << EOF
env = GDK_SCALE,$MONITOR_SCALE

monitor = eDP-1, $MONITOR_RESOLUTION, auto, $MONITOR_SCALE
EOF
    log INFO "Monitor configuration set: ${MONITOR_RESOLUTION} at ${MONITOR_SCALE}x scale"
else
    log INFO "Skipping monitor configuration (MONITOR_RESOLUTION empty)"
fi

if [[ -n "$CLOCK_FORMAT" ]]; then
    log STEP "Configuring Waybar clock format..."
    if [[ -f "$WAYBAR_CONFIG" ]]; then
        if [[ "$CLOCK_FORMAT" == "12h" ]]; then
            sed -i 's/"format": "{:%A %H:%M}"/"format": "{:%A %I:%M %p}"/' "$WAYBAR_CONFIG"
            log INFO "Waybar clock set to 12-hour format"
        else
            sed -i 's/"format": "{:%A %I:%M %p}"/"format": "{:%A %H:%M}"/' "$WAYBAR_CONFIG"
            log INFO "Waybar clock set to 24-hour format"
        fi
    else
        log WARN "Waybar config not found at $WAYBAR_CONFIG"
        log WARN "You may need to manually edit the clock format"
    fi
else
    log INFO "Skipping Waybar configuration (CLOCK_FORMAT empty)"
fi

if [[ -n "$KEYBOARD_LAYOUTS" && -f "$WAYBAR_CONFIG" ]]; then
    log STEP "Configuring Waybar keyboard layout display..."
    
    if ! grep -q '"hyprland/language"' "$WAYBAR_CONFIG"; then
        sed -i '/"modules-right": \[/,/\]/ {
            /"modules-right": \[/ {
                a\    "hyprland/language",
            }
        }' "$WAYBAR_CONFIG"
        log INFO "Added hyprland/language module to waybar"
    fi
    
    if ! grep -q '"hyprland/language":' "$WAYBAR_CONFIG"; then
        layout_formats=""
        IFS=',' read -ra LAYOUTS <<< "$KEYBOARD_LAYOUTS"
        for layout in "${LAYOUTS[@]}"; do
            case "$layout" in
                "us") layout_formats="$layout_formats\n    \"format-en\": \"US\"," ;;
                "ge") layout_formats="$layout_formats\n    \"format-ka\": \"GE\"," ;;
                "de") layout_formats="$layout_formats\n    \"format-de\": \"DE\"," ;;
                "fr") layout_formats="$layout_formats\n    \"format-fr\": \"FR\"," ;;
                "es") layout_formats="$layout_formats\n    \"format-es\": \"ES\"," ;;
                "ru") layout_formats="$layout_formats\n    \"format-ru\": \"RU\"," ;;
                *) layout_formats="$layout_formats\n    \"format-$layout\": \"${layout^^}\"," ;;
            esac
        done
        
        sed -i '/^  }$/i\  "hyprland/language": {\
    "format": "{}",'"$layout_formats"'\
    "on-click": "hyprctl switchxkblayout at-translated-set-2-keyboard next"\
  },' "$WAYBAR_CONFIG"
        log INFO "Added hyprland/language configuration to waybar"
    fi
    
    if [[ -f "$WAYBAR_STYLE" ]] && ! grep -q '#language' "$WAYBAR_STYLE"; then
        sed -i '/#pulseaudio,/a\#language,' "$WAYBAR_STYLE"
        log INFO "Added language module to waybar CSS"
    fi
    
    log INFO "Keyboard layout display configured for waybar"
fi

log INFO "Configuration complete!"
log INFO "Backup stored in $BACKUP_DIR"

if pgrep -x "waybar" > /dev/null; then
    log STEP "Restarting waybar to apply changes..."
    pkill waybar
    sleep 1
    hyprctl dispatch exec waybar
    log INFO "Waybar restarted with new configuration"
fi