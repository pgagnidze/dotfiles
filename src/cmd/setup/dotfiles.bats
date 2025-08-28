#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load ../../test_helper

setup() {
    setup_test_environment
}

teardown() {
    teardown_test_environment
}

@test "dotfiles command shows help" {
    run -0 "$POMARCHY_ROOT/src/cmd/setup/dotfiles.sh" --help
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "dotfiles" ]]
}

@test "dotfiles script is executable" {
    [ -x "$POMARCHY_ROOT/src/cmd/setup/dotfiles.sh" ]
}

@test "dotfiles command sources common.sh correctly" {
    run -0 bash -n "$POMARCHY_ROOT/src/cmd/setup/dotfiles.sh"
}

@test "stow command availability is checked" {
    run bash -c "source $POMARCHY_ROOT/src/lib/common.sh && ensure_command stow"
    if command -v stow &>/dev/null; then
        [ "$status" -eq 0 ]
    else
        [ "$status" -eq 1 ]
    fi
}

@test "dotfiles detects config directory" {
    run bash -c "source $POMARCHY_ROOT/src/lib/common.sh; load_config; echo \$POMARCHY_ROOT/src/config"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "src/config" ]]
}

@test "dotfiles lists available configurations" {
    [ -d "$POMARCHY_ROOT/src/config/bash" ]
    [ -d "$POMARCHY_ROOT/src/config/micro" ]
    [ -d "$POMARCHY_ROOT/src/config/alacritty" ]
}