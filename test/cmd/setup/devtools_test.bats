#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load ../../helpers/test_helper

setup() {
    setup_test_environment
    mock_nvm
    mock_go
    mock_code
}

teardown() {
    teardown_test_environment
}

@test "devtools command shows help" {
    run -0 "$POMARCHY_ROOT/src/cmd/setup/devtools.sh" --help
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "devtools" ]]
}

@test "installs Node.js and npm packages" {
    run_in_test_env "${POMARCHY_ROOT}/src/cmd/setup/devtools.sh" --yes
    [ "$status" -eq 0 ]
    
    assert_command_called_with "nvm" "MOCK: nvm install 18"
    assert_command_called_with "npm" "MOCK: npm install -g typescript eslint"
}

@test "installs Go tools and VS Code extensions" {
    run_in_test_env "${POMARCHY_ROOT}/src/cmd/setup/devtools.sh" --yes
    [ "$status" -eq 0 ]
    
    assert_command_called_with "go" "MOCK: go install golang.org/x/tools/gopls@latest"
    assert_command_called_with "code" "MOCK: code --install-extension golang.go"
}