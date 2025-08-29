#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load ../helpers/test_helper

setup() {
    setup_test_environment
}

teardown() {
    teardown_test_environment
}

@test "doctor command shows system status" {
    run_in_test_env "$POMARCHY_ROOT/src/cmd/doctor.sh"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "System Status" || "$output" =~ "Configuration" ]]
}

@test "doctor shows package and environment info" {
    run_in_test_env "$POMARCHY_ROOT/src/cmd/doctor.sh"
    [ "$status" -eq 0 ]
    [[ ${#output} -gt 50 ]]
}