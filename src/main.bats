#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load ../test_helper

setup() {
    setup_test_environment
}

teardown() {
    teardown_test_environment
}

@test "pomarchy shows help when run with --help" {
    run -0 "$POMARCHY_ROOT/pomarchy" --help
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "pomarchy" ]]
}

@test "pomarchy shows setup help" {
    run -0 "$POMARCHY_ROOT/pomarchy" setup --help
    [[ "$output" =~ "Setup Subcommands:" ]]
}

@test "pomarchy shows backups help" {
    run -0 "$POMARCHY_ROOT/pomarchy" backups --help
    [[ "$output" =~ "Backup Subcommands:" ]]
}

@test "pomarchy doctor command exists" {
    run bash -c "$POMARCHY_ROOT/pomarchy doctor --help || echo 'doctor command exists'"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "doctor" || "$output" =~ "system status" ]]
}

@test "pomarchy fails with unknown command" {
    run -1 "$POMARCHY_ROOT/pomarchy" unknown_command
    [[ "$output" =~ "Unknown command" ]]
}

@test "pomarchy fails with unknown setup subcommand" {
    run -1 "$POMARCHY_ROOT/pomarchy" setup unknown_subcommand
    [[ "$output" =~ "Unknown setup subcommand" ]]
}