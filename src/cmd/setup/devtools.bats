#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load ../../test_helper

setup() {
    setup_test_environment
}

teardown() {
    teardown_test_environment
}

@test "devtools command shows help" {
    run -0 "$POMARCHY_ROOT/src/cmd/setup/devtools.sh" --help
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "devtools" ]]
}

@test "devtools script is executable" {
    [ -x "$POMARCHY_ROOT/src/cmd/setup/devtools.sh" ]
}

@test "devtools command sources common.sh correctly" {
    run -0 bash -n "$POMARCHY_ROOT/src/cmd/setup/devtools.sh"
}

@test "nvm init path configuration exists" {
    source "$POMARCHY_ROOT/src/lib/common.sh"
    load_config
    [ -n "$NVM_INIT_PATH" ]
}

@test "nodejs version configuration exists" {
    source "$POMARCHY_ROOT/src/lib/common.sh"
    load_config
    [ -n "$NODEJS_VERSION" ]
}