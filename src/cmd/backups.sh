#!/usr/bin/env bash
set -euo pipefail

readonly POMARCHY_ROOT="${POMARCHY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "${POMARCHY_ROOT}/src/lib/common.sh"
load_config

manage_backups() {
    local action="${1:-}"
    local backup_base="${BACKUP_BASE_PATH:-$HOME/.config/omarchy-backups}"
    
    case "$action" in
        list)
            log STEP "Available backups:"
            if [[ -d "$backup_base" ]]; then
                for backup in "$backup_base"/*/; do
                    [[ -d "$backup" ]] && basename "$backup"
                done | sort -r
            else
                log INFO "No backups found"
            fi
            ;;
        restore)
            if [[ ! -d "$backup_base" ]]; then
                log ERROR "No backups directory found"
                exit 1
            fi
            
            echo "Available backups:"
            for backup in "$backup_base"/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9]/; do
                [[ -d "$backup" ]] && basename "$backup"
            done | sort -r
            echo ""
            read -rp "Enter backup timestamp to restore (YYYYMMDD_HHMMSS): "
            
            local selected_backup="$backup_base/$REPLY"
            if [[ ! -d "$selected_backup" ]]; then
                log ERROR "Backup not found: $selected_backup"
                exit 1
            fi
            
            if [[ "${YES:-false}" != true ]]; then
                read -rp "This will overwrite current configs. Continue? (y/N) "
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    exit 1
                fi
            fi
            
            log STEP "Restoring from $selected_backup..."
            if [[ -d "$selected_backup/.config" ]]; then
                if cp -r "$selected_backup/.config/"* "$HOME/.config/" 2>/dev/null; then
                    log INFO "Restore complete!"
                else
                    log ERROR "Failed to restore some files - check permissions"
                    exit 1
                fi
            else
                log ERROR "Invalid backup structure - missing .config directory"
                exit 1
            fi
            ;;
        remove|rm)
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

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    manage_backups "$1"
fi