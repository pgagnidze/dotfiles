#!/usr/bin/env bash
set -euo pipefail

readonly POMARCHY_ROOT="${POMARCHY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"
source "${POMARCHY_ROOT}/src/lib/common.sh"
load_config
validate_config

show_help() {
    echo "Usage: pomarchy setup system [OPTIONS]"
    echo ""
    echo "Configure Omarchy Linux system settings for X1 Carbon Gen 13 OLED."
    echo ""
    echo "What this command does:"
    echo "  • Configures keyboard layouts with Caps Lock switching"
    echo "  • Sets up monitor configuration and scaling"
    echo "  • Enables natural scrolling and touchpad settings"
    echo "  • Sets Waybar clock format"
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

SKIP_CONFIRM="${YES:-false}"

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
            shift
            ;;
    esac
done

setup_error_handling "system"
pre_setup_validation

if [[ "${SKIP_CONFIRM}" == "false" ]]; then
    log STEP "Configuring system settings for Omarchy..."
    echo "This will configure keyboard layouts, monitor settings, and Waybar."
    echo "Keyboard layouts: ${KEYBOARD_LAYOUTS}"
    echo "Monitor resolution: ${MONITOR_RESOLUTION} at ${MONITOR_SCALE}x scale"
    echo ""
    read -rp "Do you want to continue? (y/N) "
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log INFO "System configuration cancelled."
        exit 0
    fi
fi

readonly HYPR_CONFIG_DIR="$HOME/.config/hypr"
readonly WAYBAR_CONFIG_DIR="$HOME/.config/waybar"
readonly INPUT_CONF="$HYPR_CONFIG_DIR/input.conf"
readonly MONITOR_CONF="$HYPR_CONFIG_DIR/monitors.conf"  
readonly WAYBAR_CONFIG="$WAYBAR_CONFIG_DIR/config.jsonc"
readonly WAYBAR_STYLE="$WAYBAR_CONFIG_DIR/style.css"

create_safety_backup "system" "$INPUT_CONF" "$MONITOR_CONF" "$WAYBAR_CONFIG" "$WAYBAR_STYLE"

log STEP "System Configuration"

create_permanent_backup() {
    local backup_timestamp
    backup_timestamp=$(date +%Y%m%d_%H%M%S)
    local permanent_backup_dir="${BACKUP_BASE_DIR}/permanent_system_${backup_timestamp}"
    
    mkdir -p "$permanent_backup_dir"
    
    local backup_manifest="${permanent_backup_dir}/.backup_manifest"
    echo "operation=system" > "$backup_manifest"
    echo "timestamp=$(date)" >> "$backup_manifest"
    echo "type=permanent" >> "$backup_manifest"
    
    local files_backed_up=0
    for file in "$INPUT_CONF" "$MONITOR_CONF" "$WAYBAR_CONFIG" "$WAYBAR_STYLE"; do
        if [[ -f "$file" ]]; then
            backup_single_file "$file" "$permanent_backup_dir" "$backup_manifest"
            ((files_backed_up++)) || true
        fi
    done
    
    if (( files_backed_up > 0 )); then
        log INFO "Permanent backup created: $permanent_backup_dir"
    else
        rm -rf "$permanent_backup_dir"
    fi
}

create_permanent_backup

log STEP "Configuring keyboard layouts and input..."

if [[ -n "$KEYBOARD_LAYOUTS" ]]; then
cat > "$INPUT_CONF" << EOF
input {
  kb_layout = $KEYBOARD_LAYOUTS
  kb_options = compose:caps,grp:caps_toggle

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
    log INFO "Keyboard layout switching configured ($KEYBOARD_LAYOUTS with Caps Lock)"
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
        sed -i '/"modules-right": \[/,/../../..
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

if pgrep -x "waybar" > /dev/null; then
    log STEP "Restarting waybar to apply changes..."
    pkill waybar
    sleep 1
    hyprctl dispatch exec waybar
    log INFO "Waybar restarted with new configuration"
fi