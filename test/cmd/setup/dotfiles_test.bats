#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load ../../helpers/test_helper

setup() {
    setup_test_environment
    mock_stow
}

teardown() {
    teardown_test_environment
}

@test "dotfiles command shows help" {
    run -0 "$POMARCHY_ROOT/src/cmd/setup/dotfiles.sh" --help
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "dotfiles" ]]
}

@test "installs dotfiles with stow" {
    run_in_test_env "${POMARCHY_ROOT}/src/cmd/setup/dotfiles.sh" --yes
    [ "$status" -eq 0 ]
    
    assert_command_called_with "stow" "MOCK: stow -v -d"
}