#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load ../../test_helper

setup() {
    setup_test_environment
    mock_yay
}

teardown() {
    teardown_test_environment
}

@test "packages command shows help" {
    run -0 "$POMARCHY_ROOT/src/cmd/setup/packages.sh" --help
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "packages" ]]
}

@test "packages script is executable" {
    [ -x "$POMARCHY_ROOT/src/cmd/setup/packages.sh" ]
}

@test "packages command sources common.sh correctly" {
    run -0 bash -n "$POMARCHY_ROOT/src/cmd/setup/packages.sh"
}

@test "yay command availability is checked" {
    run -0 bash -c "source $POMARCHY_ROOT/src/lib/common.sh && ensure_command yay"
}

@test "core packages are defined" {
    run bash -c "grep -c 'CORE_PACKAGES.*=' $POMARCHY_ROOT/src/cmd/setup/packages.sh"
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^[1-9]$ ]]
}

@test "micro plugins installation function exists" {
    run bash -c "source $POMARCHY_ROOT/src/cmd/setup/packages.sh; declare -f install_micro_plugins"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "install_micro_plugins" ]]
}

@test "packages script has core packages array" {
    run bash -c "grep -q 'CORE_PACKAGES' $POMARCHY_ROOT/src/cmd/setup/packages.sh"
    [ "$status" -eq 0 ]
}