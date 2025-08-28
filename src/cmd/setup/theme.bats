#!/usr/bin/env bats

load ../../test_helper

setup() {
    setup_test_environment
}

teardown() {
    teardown_test_environment
}

@test "theme command shows help" {
    run "$POMARCHY_ROOT/src/cmd/setup/theme.sh" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "theme script is executable" {
    [ -x "$POMARCHY_ROOT/src/cmd/setup/theme.sh" ]
}

@test "theme command sources common.sh correctly" {
    run bash -n "$POMARCHY_ROOT/src/cmd/setup/theme.sh"
    [ "$status" -eq 0 ]
}

@test "get_theme_url function handles midnight theme" {
    source "$POMARCHY_ROOT/src/cmd/setup/theme.sh"
    run get_theme_url "midnight"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "github.com" ]]
    [[ "$output" =~ "midnight" ]]
}

@test "get_theme_url function handles empty string (defaults to midnight)" {
    source "$POMARCHY_ROOT/src/cmd/setup/theme.sh"
    run get_theme_url ""
    [ "$status" -eq 0 ]
    [[ "$output" =~ "midnight" ]]
}

@test "get_theme_url function validates GitHub URLs" {
    source "$POMARCHY_ROOT/src/cmd/setup/theme.sh"
    run get_theme_url "https://github.com/user/theme.git"
    [ "$status" -eq 0 ]
    [[ "$output" == "https://github.com/user/theme.git" ]]
}

@test "get_theme_url function rejects invalid URLs" {
    source "$POMARCHY_ROOT/src/cmd/setup/theme.sh"
    run get_theme_url "invalid-url"
    [ "$status" -eq 1 ]
}