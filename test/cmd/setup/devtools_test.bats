#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load ../../helpers/test_helper

setup() {
    setup_test_environment
    mock_nvm
    mock_go
    mock_micro
    mock_lpm
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

@test "installs Go tools and editor plugins" {
    run_in_test_env "${POMARCHY_ROOT}/src/cmd/setup/devtools.sh" --yes
    [ "$status" -eq 0 ]
    
    assert_command_called_with "go" "MOCK: go install golang.org/x/tools/gopls@latest"
    assert_command_called_with "micro" "MOCK: micro -plugin install fzf"
    assert_command_called_with "lpm" "MOCK: lpm install ide ide_javascript ide_typescript ide_lua lsp_go lsp_json lsp_yaml nonicons language_containerfile language_env language_go language_ini language_json language_make language_sh language_toml language_yaml --assume-yes"
}