#!/usr/bin/env bash

if [[ -z "${BLUE:-}" ]]; then
    readonly BLUE='\033[0;34m'
    readonly GREEN='\033[0;32m'
    readonly RED='\033[0;31m'
    readonly YELLOW='\033[1;33m'
    readonly RESET='\033[0m'
fi

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
    command -v "$1" >/dev/null 2>&1 || {
        log ERROR "Required command not found: $1"
        exit 1
    }
}

load_config() {
    local default_config="${POMARCHY_ROOT}/src/config/pomarchy/.config/pomarchy/pomarchy.ini"
    local user_config="${HOME}/.config/pomarchy/pomarchy.ini"

    if [[ -f "$default_config" ]]; then
        load_config_from_file "$default_config"
    fi

    if [[ -f "$user_config" ]]; then
        load_config_from_file "$user_config"
    fi
}

load_config_from_file() {
    local config_file="$1"

    while IFS='=' read -r key value; do
        case "$key" in
            theme.name) THEME="$value" ;;
            dotfiles.enabled) DOTFILES="$value" ;;
            packages.remove) PACKAGES_REMOVE="$value" ;;
            packages.install) PACKAGES_INSTALL="$value" ;;
            packages.default-browser) DEFAULT_BROWSER="$value" ;;
            system.keyboard-layouts) KEYBOARD_LAYOUTS="$value" ;;
            system.monitor-resolution) MONITOR_RESOLUTION="$value" ;;
            system.monitor-scale) MONITOR_SCALE="$value" ;;
            system.natural-scroll) NATURAL_SCROLL="$value" ;;
            system.disable-while-typing) DISABLE_WHILE_TYPING="$value" ;;
            system.clock-format) CLOCK_FORMAT="$value" ;;
            devtools.nodejs-version) NODEJS_VERSION="$value" ;;
            devtools.npm-packages) NPM_PACKAGES="$value" ;;
            devtools.go-tools) GO_TOOLS="$value" ;;
        esac
    done < <(git config -f "$config_file" --list 2>/dev/null)
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

if [[ -z "${BACKUP_BASE_DIR:-}" ]]; then
    readonly BACKUP_BASE_DIR="${HOME}/.local/share/pomarchy/backups"
fi

create_safety_backup() {
    local operation_name="$1"
    shift
    local files_to_backup=("$@")

    if [[ ${#files_to_backup[@]} -eq 0 ]]; then
        log INFO "No files specified for safety backup"
        return
    fi

    local backup_timestamp
    backup_timestamp=$(date +%Y%m%d_%H%M%S)
    local operation_backup_dir="${BACKUP_BASE_DIR}/temporary_${operation_name}_${backup_timestamp}"

    mkdir -p "$operation_backup_dir"

    local backup_manifest="${operation_backup_dir}/.backup_manifest"
    echo "operation=$operation_name" >"$backup_manifest"
    echo "timestamp=$(date)" >>"$backup_manifest"
    echo "type=temporary" >>"$backup_manifest"

    local files_backed_up=0
    for file_pattern in "${files_to_backup[@]}"; do
        if [[ "$file_pattern" == *"*"* ]] || [[ "$file_pattern" == *"?"* ]]; then
            for file in $file_pattern; do
                if [[ -f "$file" || -d "$file" ]]; then
                    backup_single_file "$file" "$operation_backup_dir" "$backup_manifest"
                    ((files_backed_up++)) || true
                fi
            done
        else
            if [[ -f "$file_pattern" || -d "$file_pattern" ]]; then
                backup_single_file "$file_pattern" "$operation_backup_dir" "$backup_manifest"
                ((files_backed_up++)) || true
            fi
        fi
    done

    if ((files_backed_up > 0)); then
        export POMARCHY_SAFETY_BACKUP_DIR="$operation_backup_dir"
        log INFO "Temporary backup created: $operation_backup_dir ($files_backed_up files)"
    else
        rm -rf "$operation_backup_dir"
        log INFO "No existing files found to backup for $operation_name"
    fi
}

backup_single_file() {
    local source_file="$1"
    local backup_base_dir="$2"
    local manifest_file="$3"

    local relative_path
    if [[ "$source_file" == "$HOME"* ]]; then
        relative_path="${source_file#"$HOME"/}"
    else
        relative_path="$source_file"
    fi

    local backup_file_path="$backup_base_dir/$relative_path"
    local backup_dir
    backup_dir=$(dirname "$backup_file_path")

    mkdir -p "$backup_dir"

    if [[ -d "$source_file" ]]; then
        cp -r "$source_file/." "$backup_file_path/"
        echo "dir=$source_file" >>"$manifest_file"
    else
        cp "$source_file" "$backup_file_path"
        echo "file=$source_file" >>"$manifest_file"
    fi
}

handle_setup_failure() {
    local operation_name="$1"
    local exit_code="$2"

    log ERROR "$operation_name failed with exit code $exit_code"

    if [[ -n "${POMARCHY_SAFETY_BACKUP_DIR:-}" && -d "$POMARCHY_SAFETY_BACKUP_DIR" ]]; then
        log ERROR ""
        log ERROR "Temporary backup preserved at: $POMARCHY_SAFETY_BACKUP_DIR"
        log ERROR "To restore: pomarchy restore \"$POMARCHY_SAFETY_BACKUP_DIR\""
        log ERROR "Backup manifest: $POMARCHY_SAFETY_BACKUP_DIR/.backup_manifest"
    else
        log ERROR "No temporary backup was created (no existing files were modified)"
    fi

    exit "$exit_code"
}

cleanup_successful_backup() {
    if [[ -n "${POMARCHY_SAFETY_BACKUP_DIR:-}" && -d "$POMARCHY_SAFETY_BACKUP_DIR" ]]; then
        log INFO "Cleaning up temporary backup (operation succeeded): $(basename "$POMARCHY_SAFETY_BACKUP_DIR")"
        rm -rf "$POMARCHY_SAFETY_BACKUP_DIR"
        unset POMARCHY_SAFETY_BACKUP_DIR
    fi
}

setup_error_handling() {
    local operation_name="$1"
    export POMARCHY_OPERATION_NAME="$operation_name"

    cleanup_on_exit() {
        local exit_code=$?
        if ((exit_code != 0)); then
            handle_setup_failure "${POMARCHY_OPERATION_NAME}" "$exit_code"
        else
            cleanup_successful_backup
        fi
    }

    trap cleanup_on_exit EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
}
