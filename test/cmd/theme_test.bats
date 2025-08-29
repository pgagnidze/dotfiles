#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load ../helpers/test_helper

setup() {
    setup_test_environment_minimal
}

teardown() {
    teardown_test_environment
}

@test "theme command shows help" {
    run -0 "$POMARCHY_ROOT/src/cmd/theme.sh" --help
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "theme" ]]
}

@test "theme list requires themes directory" {
    run_in_test_env "$POMARCHY_ROOT/src/cmd/theme.sh" list
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Themes directory not found" ]]
}

@test "detects theme types correctly" {
    run bash -c "source $POMARCHY_ROOT/src/cmd/theme.sh; detect_theme_type midnight"
    [ "$status" -eq 0 ]
    [[ "$output" == "predefined" ]]
    
    run bash -c "source $POMARCHY_ROOT/src/cmd/theme.sh; detect_theme_type https://github.com/user/theme.git"
    [ "$status" -eq 0 ]
    [[ "$output" == "url" ]]
    
    run bash -c "source $POMARCHY_ROOT/src/cmd/theme.sh; detect_theme_type unknown-theme"
    [ "$status" -eq 0 ]
    [[ "$output" == "unknown" ]]
}

@test "validates GitHub URLs" {
    run bash -c "source $POMARCHY_ROOT/src/cmd/theme.sh; get_theme_url https://github.com/user/theme.git"
    [ "$status" -eq 0 ]
    [[ "$output" == "https://github.com/user/theme.git" ]]
    
    run bash -c "source $POMARCHY_ROOT/src/cmd/theme.sh; get_theme_url invalid-url"
    [ "$status" -eq 1 ]
}