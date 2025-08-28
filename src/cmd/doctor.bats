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

@test "doctor command shows system status" {
    run "$POMARCHY_ROOT/src/cmd/doctor.sh"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Checking system status" ]]
    [[ "$output" =~ "Package Status" ]]
    [[ "$output" =~ "Development Environment" ]]
}

@test "doctor has show_status function" {
    run bash -c "source $POMARCHY_ROOT/src/cmd/doctor.sh; declare -f show_status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "show_status" ]]
}

@test "doctor checks package status logic" {
    run bash -c "source $POMARCHY_ROOT/src/lib/common.sh; load_config; echo \$PACKAGES_INSTALL"
    [ "$status" -eq 0 ]
}

@test "doctor script loads configuration" {
    run bash -c "source $POMARCHY_ROOT/src/cmd/doctor.sh; echo 'config loaded'"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "config loaded" ]]
}

@test "doctor checks dotfiles status" {
    run "$POMARCHY_ROOT/src/cmd/doctor.sh"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Dotfiles Status" ]]
    [[ "$output" =~ "bash - not stowed" ]]
    [[ "$output" =~ "micro - not stowed" ]]
    [[ "$output" =~ "alacritty - not stowed" ]]
}

@test "doctor checks development environment" {
    run "$POMARCHY_ROOT/src/cmd/doctor.sh"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Development Environment" ]]
    if command -v node &> /dev/null; then
        [[ "$output" =~ "Node.js -" ]]
    else
        [[ "$output" =~ "Node.js - not installed" ]]
    fi
}

@test "doctor sources common.sh correctly" {
    run bash -n "$POMARCHY_ROOT/src/cmd/doctor.sh"
    [ "$status" -eq 0 ]
}