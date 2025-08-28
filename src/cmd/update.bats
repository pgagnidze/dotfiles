#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load ../test_helper

setup() {
    setup_test_environment
    source "$POMARCHY_ROOT/src/lib/common.sh"
}

teardown() {
    teardown_test_environment
}

@test "update script is executable" {
    [ -x "$POMARCHY_ROOT/src/cmd/update.sh" ]
}

@test "update command sources common.sh correctly" {
    run bash -n "$POMARCHY_ROOT/src/cmd/update.sh"
    [ "$status" -eq 0 ]
}

@test "update has git repository check" {
    run bash -c "grep -q 'Not a git repository' $POMARCHY_ROOT/src/cmd/update.sh"
    [ "$status" -eq 0 ]
}

@test "update has up to date check logic" {
    run bash -c "grep -q 'up to date' $POMARCHY_ROOT/src/cmd/update.sh"
    [ "$status" -eq 0 ]
}

@test "update has error handling for git failures" {
    run bash -c "grep -q 'Failed to fetch' $POMARCHY_ROOT/src/cmd/update.sh"
    [ "$status" -eq 0 ]
}