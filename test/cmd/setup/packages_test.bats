#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load ../../helpers/test_helper

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

@test "installs and removes packages as configured" {
    echo "test-package-to-remove" >> "${TEST_TMP}/installed_packages.txt"
    
    run_in_test_env "${POMARCHY_ROOT}/src/cmd/setup/packages.sh" --yes
    [ "$status" -eq 0 ]
    
    assert_command_called_with "yay" "MOCK: yay -Rns --noconfirm test-package-to-remove"
    assert_command_called_with "yay" "MOCK: yay -S --noconfirm test-package-to-install"
    assert_command_called_with "yay" "MOCK: yay -Qi ttf-ubuntu-mono-nerd"
}

@test "installs micro plugins when micro is available" {
    mock_micro
    echo "micro" >> "${TEST_TMP}/installed_packages.txt"
    
    run_in_test_env "${POMARCHY_ROOT}/src/cmd/setup/packages.sh" --yes
    [ "$status" -eq 0 ]
    
    assert_command_called_with "micro" "MOCK: micro -plugin install fzf"
    assert_command_called_with "micro" "MOCK: micro -plugin install editorconfig"
}

@test "skips operations when config values are empty" {
    load_test_config "minimal"
    
    run_in_test_env "${POMARCHY_ROOT}/src/cmd/setup/packages.sh" --yes
    [ "$status" -eq 0 ]
    
    local yay_log="${TEST_TMP}/yay.log"
    if [[ -f "$yay_log" ]]; then
        assert_file_not_contains "$yay_log" "test-package-to-install"
        assert_file_contains "$yay_log" "ttf-ubuntu-mono-nerd"
    fi
}

@test "confirmation prompt works correctly" {
    run_in_test_env "${POMARCHY_ROOT}/src/cmd/setup/packages.sh" --yes
    [ "$status" -eq 0 ]
}