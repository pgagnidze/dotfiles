#!/usr/bin/env bash
set -euo pipefail

readonly POMARCHY_ROOT="${POMARCHY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "${POMARCHY_ROOT}/src/lib/common.sh"
load_config

manage_backups() {
    local action="${1:-}"
    local backup_base="${BACKUP_BASE_PATH:-$HOME/.config/omarchy-backups}"
    local safety_backup_base="${HOME}/.local/share/pomarchy/backups"

    case "$action" in
        list)
            log STEP "Available backups:"
            echo ""

            if [[ -d "$backup_base" ]]; then
                log INFO "Permanent backups (system configurations):"
                for backup in "$backup_base"/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9]/; do
                    [[ -d "$backup" ]] && echo "  $(basename "$backup")"
                done | sort -r
            fi

            if [[ -d "$safety_backup_base" ]]; then
                echo ""
                log INFO "Temporary backups (operation-specific):"
                for backup in "$safety_backup_base"/temporary_*/; do
                    if [[ -d "$backup" ]]; then
                        local backup_name
                        backup_name=$(basename "$backup")
                        if [[ -f "$backup/.backup_manifest" ]]; then
                            local operation timestamp
                            operation=$(grep '^operation=' "$backup/.backup_manifest" | cut -d= -f2)
                            timestamp=$(grep '^timestamp=' "$backup/.backup_manifest" | cut -d= -f2)
                            echo "  $backup_name ($operation - $timestamp)"
                        else
                            echo "  $backup_name"
                        fi
                    fi
                done | sort -r
            fi

            if [[ ! -d "$backup_base" && ! -d "$safety_backup_base" ]]; then
                log INFO "No backups found"
            fi
            ;;
        restore)
            if [[ ! -d "$backup_base" && ! -d "$safety_backup_base" ]]; then
                log ERROR "No backups directory found"
                exit 1
            fi

            echo "Available backups:"
            echo ""

            local backup_options=()

            if [[ -d "$backup_base" ]]; then
                log INFO "Permanent backups:"
                local permanent_list=()
                for backup in "$backup_base"/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9]/; do
                    if [[ -d "$backup" ]]; then
                        local backup_name
                        backup_name=$(basename "$backup")
                        permanent_list+=("  $backup_name (permanent)")
                        backup_options+=("$backup")
                    fi
                done
                printf '%s\n' "${permanent_list[@]}" | sort -r
                echo ""
            fi

            if [[ -d "$safety_backup_base" ]]; then
                log INFO "Temporary backups:"
                local temporary_list=()
                for backup in "$safety_backup_base"/temporary_*/; do
                    if [[ -d "$backup" ]]; then
                        local backup_name operation
                        backup_name=$(basename "$backup")
                        if [[ -f "$backup/.backup_manifest" ]]; then
                            operation=$(grep '^operation=' "$backup/.backup_manifest" | cut -d= -f2 2>/dev/null || echo "unknown")
                            temporary_list+=("  $backup_name ($operation)")
                        else
                            temporary_list+=("  $backup_name")
                        fi
                        backup_options+=("$backup")
                    fi
                done
                printf '%s\n' "${temporary_list[@]}" | sort -r
            fi

            if [[ ${#backup_options[@]} -eq 0 ]]; then
                log ERROR "No backups available"
                exit 1
            fi

            echo ""
            read -rp "Enter full backup directory name to restore: "

            local selected_backup
            if [[ "$REPLY" == *"temporary_"* ]]; then
                selected_backup="$safety_backup_base/$REPLY"
            else
                selected_backup="$backup_base/$REPLY"
            fi

            if [[ ! -d "$selected_backup" ]]; then
                log ERROR "Backup not found: $selected_backup"
                exit 1
            fi

            if [[ -f "$selected_backup/.backup_manifest" ]]; then
                show_backup_info "$selected_backup"
            fi

            if [[ "${YES:-false}" != true ]]; then
                read -rp "This will overwrite current files. Continue? (y/N) "
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    exit 1
                fi
            fi

            restore_backup_files "$selected_backup"
            ;;
        remove | rm)
            if [[ ! -d "$backup_base" ]]; then
                log ERROR "No backups directory found"
                exit 1
            fi

            echo "Available backups:"
            for backup in "$backup_base"/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9]/; do
                [[ -d "$backup" ]] && basename "$backup"
            done | sort -r
            echo ""
            read -rp "Enter backup timestamp to remove (YYYYMMDD_HHMMSS): "

            local selected_backup="$backup_base/$REPLY"
            if [[ ! -d "$selected_backup" ]]; then
                log ERROR "Backup not found: $selected_backup"
                exit 1
            fi

            if [[ "${YES:-false}" != true ]]; then
                read -rp "This will permanently delete backup $REPLY. Continue? (y/N) "
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    exit 1
                fi
            fi

            log STEP "Removing backup $REPLY..."
            if rm -rf "$selected_backup"; then
                log INFO "Backup removed successfully!"
            else
                log ERROR "Failed to remove backup"
                exit 1
            fi
            ;;
        *)
            echo "Usage: $0 backups [list|restore|remove]"
            exit 1
            ;;
    esac
}

show_backup_info() {
    local backup_path="$1"
    local manifest_file="${backup_path}/.backup_manifest"

    if [[ ! -f "$manifest_file" ]]; then
        return
    fi

    echo ""
    log INFO "Backup Information:"
    while IFS='=' read -r key value; do
        case "$key" in
            operation) echo "  Operation: $value" ;;
            timestamp) echo "  Created: $value" ;;
            type) echo "  Type: $value" ;;
        esac
    done <"$manifest_file"

    echo ""
    log INFO "Files in backup:"
    while IFS='=' read -r key value; do
        if [[ "$key" == "file" || "$key" == "dir" ]]; then
            echo "    $value"
        fi
    done <"$manifest_file"
    echo ""
}

restore_backup_files() {
    local backup_path="$1"
    local manifest_file="${backup_path}/.backup_manifest"

    log STEP "Restoring from $(basename "$backup_path")..."

    if [[ -f "$manifest_file" ]]; then
        local files_restored=0
        while IFS='=' read -r key value; do
            if [[ "$key" == "file" || "$key" == "dir" ]]; then
                local source_file="$value"
                local relative_path
                if [[ "$source_file" == "$HOME"* ]]; then
                    relative_path="${source_file#"$HOME"/}"
                else
                    relative_path="$source_file"
                fi

                local backup_file_path="$backup_path/$relative_path"

                if [[ -f "$backup_file_path" || -d "$backup_file_path" || -L "$backup_file_path" ]]; then
                    local target_dir
                    target_dir=$(dirname "$source_file")
                    mkdir -p "$target_dir"

                    if [[ -L "$backup_file_path" ]]; then
                        \cp -P "$backup_file_path" "$source_file"
                    elif [[ -d "$backup_file_path" ]]; then
                        \cp -rf "$backup_file_path" "$source_file"
                    else
                        \cp -f "$backup_file_path" "$source_file"
                    fi

                    log INFO "Restored: $source_file"
                    ((files_restored++)) || true
                else
                    log WARN "Backup file not found: $backup_file_path"
                fi
            fi
        done <"$manifest_file"
        log INFO "Restoration complete: $files_restored files restored"
    else
        if [[ -d "$backup_path/.config" ]]; then
            if cp -r "$backup_path/.config/"* "$HOME/.config/" 2>/dev/null; then
                log INFO "Restore complete!"
            else
                log ERROR "Failed to restore some files - check permissions"
                exit 1
            fi
        else
            log ERROR "Invalid backup structure"
            exit 1
        fi
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    manage_backups "$1"
fi
