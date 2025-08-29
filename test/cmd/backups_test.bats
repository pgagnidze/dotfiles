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
    local backup_dir="${HOME}/.local/share/pomarchy/backups/temporary_test_20240101_120000"
    mkdir -p "$backup_dir"
    cat > "$backup_dir/.backup_manifest" << 'EOF'
operation=test
timestamp=2024-01-01 12:00:00
type=temporary
EOF
    
    [ -d "$backup_dir" ]
    [ -f "$backup_dir/.backup_manifest" ]
    
    run_in_test_env "${POMARCHY_ROOT}/src/cmd/backups.sh" list
    
    [[ "$output" =~ "temporary_test_20240101_120000" ]]
}