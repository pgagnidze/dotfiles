#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load ../test_helper

setup() {
    setup_test_environment
}

teardown() {
    teardown_test_environment
}

@test "pomarchy root directory is set correctly" {
    [ -n "$POMARCHY_ROOT" ]
    [ -d "$POMARCHY_ROOT" ]
    [ -f "$POMARCHY_ROOT/pomarchy" ]
}

@test "common.sh library exists and is sourceable" {
    [ -f "$BATS_TEST_DIRNAME/common.sh" ]
    run source "$BATS_TEST_DIRNAME/common.sh"
    [ "$status" -eq 0 ]
}

@test "config loading works" {
    source "$BATS_TEST_DIRNAME/common.sh"
    run load_config
    [ "$status" -eq 0 ]
}

@test "log function works" {
    source "$BATS_TEST_DIRNAME/common.sh"
    run log INFO "Test message"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Test message" ]]
}

@test "ensure_command detects missing commands" {
    source "$BATS_TEST_DIRNAME/common.sh"
    run ensure_command nonexistent_command_12345
    [ "$status" -eq 1 ]
}

@test "ensure_command passes for existing commands" {
    source "$BATS_TEST_DIRNAME/common.sh"
    run ensure_command bash
    [ "$status" -eq 0 ]
}