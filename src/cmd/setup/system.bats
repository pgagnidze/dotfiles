#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load ../../test_helper

create_sample_files() {
    cat > "${HOME}/.config/hypr/input.conf" << 'EOF'
input {
  kb_layout = us
  kb_options = grp:caps_toggle
}
EOF
    
    cat > "${HOME}/.config/waybar/config.jsonc" << 'EOF'
{
  "modules-right": ["clock", "tray"],
  "clock": {
    "format": "{:%A %H:%M}"
  }
}
EOF
    
    cat > "${HOME}/.bashrc" << 'EOF'
# Sample bashrc
export PATH=$PATH:$HOME/.local/bin
EOF
}

setup() {
    setup_test_environment
    mock_hyprctl
    mock_pkill
    mock_pgrep
    create_sample_files
}

teardown() {
    teardown_test_environment
}

@test "system command shows help" {
    run -0 "$POMARCHY_ROOT/src/cmd/setup/system.sh" --help
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "system" ]]
}

@test "configures keyboard layouts and input settings" {
    run_in_test_env "${POMARCHY_ROOT}/src/cmd/setup/system.sh" --yes
    [ "$status" -eq 0 ]
    
    local input_conf="${HOME}/.config/hypr/input.conf"
    [ -f "$input_conf" ]
    assert_file_contains "$input_conf" "kb_layout = us,de"
    assert_file_contains "$input_conf" "kb_options = compose:caps,grp:caps_toggle"
    assert_file_contains "$input_conf" "natural_scroll = true"
}

@test "configures monitor resolution and scaling" {
    run_in_test_env "${POMARCHY_ROOT}/src/cmd/setup/system.sh" --yes
    [ "$status" -eq 0 ]
    
    local monitor_conf="${HOME}/.config/hypr/monitors.conf"
    [ -f "$monitor_conf" ]
    assert_file_contains "$monitor_conf" "monitor = eDP-1, 1920x1080@60, auto, 1"
    assert_file_contains "$monitor_conf" "env = GDK_SCALE,1"
}

@test "configures waybar with language switching" {
    run_in_test_env "${POMARCHY_ROOT}/src/cmd/setup/system.sh" --yes
    [ "$status" -eq 0 ]
    
    local waybar_config="${HOME}/.config/waybar/config.jsonc"
    assert_file_contains "$waybar_config" '"hyprland/language"'
    assert_file_contains "$waybar_config" '"format-en": "US"'
    assert_file_contains "$waybar_config" '"format-de": "DE"'
}

@test "skips configuration when values are empty" {
    load_test_config "minimal"
    
    run_in_test_env "${POMARCHY_ROOT}/src/cmd/setup/system.sh" --yes
    [ "$status" -eq 0 ]
    
    [[ "$output" =~ "Skipping keyboard/input configuration" ]]
    [[ "$output" =~ "Skipping monitor configuration" ]]
}

@test "restarts waybar when running" {
    run_in_test_env "${POMARCHY_ROOT}/src/cmd/setup/system.sh" --yes
    [ "$status" -eq 0 ]
    
    assert_command_called "pkill"
    assert_command_called_with "hyprctl" "dispatch exec waybar"
}