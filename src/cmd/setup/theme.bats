#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load ../../test_helper

setup() {
    setup_test_environment_minimal
}

teardown() {
    teardown_test_environment
}

@test "theme command shows help" {
    run -0 "$POMARCHY_ROOT/src/cmd/setup/theme.sh" --help
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "theme" ]]
}

@test "handles midnight theme (default)" {
    run bash -c "source $POMARCHY_ROOT/src/cmd/setup/theme.sh; get_theme_url midnight"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "omarchy-midnight-theme" ]]
}

@test "validates GitHub URLs" {
    run bash -c "source $POMARCHY_ROOT/src/cmd/setup/theme.sh; get_theme_url https://github.com/user/theme.git"
    [ "$status" -eq 0 ]
    
    run bash -c "source $POMARCHY_ROOT/src/cmd/setup/theme.sh; get_theme_url invalid-url"
    [ "$status" -eq 1 ]
}