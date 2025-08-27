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

