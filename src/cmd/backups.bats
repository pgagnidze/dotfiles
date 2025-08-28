#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load ../test_helper

setup() {
    setup_test_environment
}

teardown() {
    teardown_test_environment
}

@test "backups command shows help" {
    run "$POMARCHY_ROOT/src/cmd/backups.sh" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "backups" ]]
}

@test "backups script is executable" {
    [ -x "$POMARCHY_ROOT/src/cmd/backups.sh" ]
}

@test "backups command sources common.sh correctly" {
    run -0 bash -n "$POMARCHY_ROOT/src/cmd/backups.sh"
}

@test "backup base path configuration exists" {
    source "$POMARCHY_ROOT/src/lib/common.sh"
    load_config
    [ -n "$BACKUP_BASE_PATH" ]
}

@test "backups list function exists" {
    run bash -c "source $POMARCHY_ROOT/src/cmd/backups.sh; declare -f manage_backups"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "manage_backups" ]]
}

@test "backups script has main execution guard" {
    run bash -c "grep -q 'BASH_SOURCE.*0.*0' $POMARCHY_ROOT/src/cmd/backups.sh"
    [ "$status" -eq 0 ]
}