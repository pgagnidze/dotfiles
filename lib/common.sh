#!/usr/bin/env bash

readonly BLUE='\033[0;34m'
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly RESET='\033[0m'

log() {
    local level=$1
    shift
    local color
    case "$level" in
        INFO) color="$GREEN" ;;
        STEP) color="$BLUE" ;;
        WARN) color="$YELLOW" ;;
        ERROR) color="$RED" ;;
        SUCCESS) color="$GREEN" ;;
        *) color="$BLUE" ;;
    esac
    echo -e "${color}[$(date +'%H:%M:%S')] ${level}: $*${RESET}" >&2
}

ensure_command() {
    command -v "$1" >/dev/null 2>&1 || { log ERROR "Required command not found: $1"; exit 1; }
}

load_config() {
    local default_config="${POMARCHY_ROOT}/config/pomarchy/.config/pomarchy/pomarchy.conf"
    if [[ -f "$default_config" ]]; then
        source "$default_config"
    fi
    
    local user_config="${HOME}/.config/pomarchy/pomarchy.conf"
    if [[ -f "$user_config" ]]; then
        source "$user_config"
    fi
}

validate_config() {
    if [[ -n "$MONITOR_RESOLUTION" && ! "$MONITOR_RESOLUTION" =~ ^[0-9]+x[0-9]+(@[0-9]+)?$ ]]; then
        log ERROR "Invalid MONITOR_RESOLUTION format: $MONITOR_RESOLUTION"
        log ERROR "Expected format: WIDTHxHEIGHT or WIDTHxHEIGHT@RATE (e.g., 2880x1800@120)"
        exit 1
    fi
    
    if [[ -n "$MONITOR_SCALE" && ! "$MONITOR_SCALE" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        log ERROR "Invalid MONITOR_SCALE format: $MONITOR_SCALE"
        log ERROR "Expected format: NUMBER (e.g., 2, 1.5)"
        exit 1
    fi
    
    if [[ -n "$CLOCK_FORMAT" && "$CLOCK_FORMAT" != "12h" && "$CLOCK_FORMAT" != "24h" ]]; then
        log ERROR "Invalid CLOCK_FORMAT: $CLOCK_FORMAT"
        log ERROR "Expected: 12h or 24h"
        exit 1
    fi
}

print_pomarchy_banner() {
    echo -e "${BLUE}"
    echo "██████╗  ██████╗ ███╗   ███╗ █████╗ ██████╗  ██████╗██╗  ██╗██╗   ██╗"
    echo "██╔══██╗██╔═══██╗████╗ ████║██╔══██╗██╔══██╗██╔════╝██║  ██║╚██╗ ██╔╝"
    echo "██████╔╝██║   ██║██╔████╔██║███████║██████╔╝██║     ███████║ ╚████╔╝ "
    echo "██╔═══╝ ██║   ██║██║╚██╔╝██║██╔══██║██╔══██╗██║     ██╔══██║  ╚██╔╝  "
    echo "██║     ╚██████╔╝██║ ╚═╝ ██║██║  ██║██║  ██║╚██████╗██║  ██║   ██║   "
    echo "╚═╝      ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   "
    echo -e "${RESET}"
    echo "Personal Omarchy Setup Tool"
    echo ""
}

