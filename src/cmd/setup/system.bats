#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load ../../test_helper

setup() {
    setup_test_environment
}

teardown() {
    teardown_test_environment
}

@test "system command shows help" {
    run -0 "$POMARCHY_ROOT/src/cmd/setup/system.sh" --help
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "system" ]]
}

@test "system script is executable" {
    [ -x "$POMARCHY_ROOT/src/cmd/setup/system.sh" ]
}

@test "system command sources common.sh correctly" {
    run -0 bash -n "$POMARCHY_ROOT/src/cmd/setup/system.sh"
}

@test "backup function exists in system setup" {
    grep -q "backup_to_snapshot" "$POMARCHY_ROOT/src/cmd/setup/system.sh"
}

@test "hypr config directories are defined" {
    run bash -c "source $POMARCHY_ROOT/src/lib/common.sh; load_config; echo \$HOME/.config/hypr"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "hypr" ]]
}

@test "keyboard layouts configuration exists" {
    source "$POMARCHY_ROOT/src/lib/common.sh"
    load_config
    [ -n "$KEYBOARD_LAYOUTS" ]
    [[ "$KEYBOARD_LAYOUTS" =~ "us" ]]
}

@test "monitor configuration exists" {
    source "$POMARCHY_ROOT/src/lib/common.sh"
    load_config
    [ -n "$MONITOR_RESOLUTION" ]
    [ -n "$MONITOR_SCALE" ]
}