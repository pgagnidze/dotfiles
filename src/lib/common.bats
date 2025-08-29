#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load ../test_helper

setup() {
    setup_test_environment
}

teardown() {
    teardown_test_environment
}

@test "common.sh library exists and loads correctly" {
    [ -f "$BATS_TEST_DIRNAME/common.sh" ]
    run source "$BATS_TEST_DIRNAME/common.sh"
    [ "$status" -eq 0 ]
}

@test "config loading works with defaults" {
    source "$BATS_TEST_DIRNAME/common.sh"
    load_config
    [ -n "$THEME" ]
    [ -n "$PACKAGES_INSTALL" ]
}

@test "create_safety_backup creates backup with manifest" {
    source "$BATS_TEST_DIRNAME/common.sh"
    load_config
    
    echo "test content" > "${HOME}/.test_file"
    
    run create_safety_backup "test_operation" "${HOME}/.test_file"
    [ "$status" -eq 0 ]
    local backup_found=false
    for backup_dir in "${HOME}/.local/share/pomarchy/backups"/temporary_test_operation_*; do
        if [[ -d "$backup_dir" && -f "$backup_dir/.backup_manifest" ]]; then
            backup_found=true
            assert_file_contains "$backup_dir/.backup_manifest" "operation=test_operation"
            assert_file_contains "$backup_dir/.backup_manifest" "type=temporary"
            break
        fi
    done
    [ "$backup_found" = true ]
}
