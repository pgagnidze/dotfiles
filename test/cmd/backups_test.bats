#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load ../helpers/test_helper

setup() {
    setup_test_environment
}

teardown() {
    teardown_test_environment
}

@test "backups command shows help" {
    run_in_test_env "$POMARCHY_ROOT/src/cmd/backups.sh" invalid_action
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "backups" ]]
}

@test "lists available backups" {
    local temp_backup_dir="${TEST_TMP}/home/.local/share/pomarchy/backups/temporary_test_20240101_120000"
    local perm_backup_dir="${TEST_TMP}/home/.local/share/pomarchy/backups/permanent_system_20240102_140000"
    
    mkdir -p "$temp_backup_dir"
    cat > "$temp_backup_dir/.backup_manifest" << 'EOF'
operation=test
timestamp=2024-01-01 12:00:00
type=temporary
EOF
    
    mkdir -p "$perm_backup_dir"
    
    [ -d "$temp_backup_dir" ]
    [ -f "$temp_backup_dir/.backup_manifest" ]
    [ -d "$perm_backup_dir" ]
    
    run_in_test_env "${POMARCHY_ROOT}/src/cmd/backups.sh" list
    
    [[ "$output" =~ "temporary_test_20240101_120000" ]]
    [[ "$output" =~ "permanent_system_20240102_140000" ]]
}