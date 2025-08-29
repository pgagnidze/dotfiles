#!/usr/bin/env bash

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POMARCHY_ROOT="$(cd "${SRC_DIR}/.." && pwd)"
FIXTURES="${SRC_DIR}/fixtures"
TEST_TMP="${SRC_DIR}/test_tmp"

export POMARCHY_ROOT
export PATH="${POMARCHY_ROOT}:${PATH}"
export FIXTURES
export TEST_TMP
export TEST_CONFIG_DIR="${TEST_TMP}/config"
export HOME="${TEST_TMP}/home"
export SRC_DIR

create_mock() {
    local cmd="$1"
    local behavior="$2"
    cat >"${TEST_TMP}/bin/$cmd" <<EOF
#!/bin/bash
echo "MOCK: $cmd \$*" >> "${TEST_TMP}/${cmd}.log"
$behavior
EOF
    chmod +x "${TEST_TMP}/bin/$cmd"
}

setup_test_environment_minimal() {
    if [[ -d "${TEST_TMP}" ]]; then
        chmod -R +w "${TEST_TMP}" 2>/dev/null || true
        rm -rf "${TEST_TMP}" 2>/dev/null || true
    fi
    mkdir -p "${TEST_TMP}/bin"
    export PATH="${TEST_TMP}/bin:${PATH}"
}

setup_test_environment() {
    setup_test_environment_minimal

    mkdir -p "${TEST_CONFIG_DIR}/pomarchy"
    mkdir -p "${HOME}/.config/pomarchy"
    mkdir -p "${HOME}/.config/hypr"
    mkdir -p "${HOME}/.config/waybar"
    mkdir -p "${HOME}/.config/alacritty"
    mkdir -p "${HOME}/.config/micro"

    cp "${FIXTURES}/valid_pomarchy.conf" \
        "${HOME}/.config/pomarchy/pomarchy.conf"

    echo "ttf-ubuntu-mono-nerd" >"${TEST_TMP}/installed_packages.txt"
    echo "micro" >>"${TEST_TMP}/installed_packages.txt"
}

teardown_test_environment() {
    if [[ -d "${TEST_TMP}" ]]; then
        chmod -R +w "${TEST_TMP}" 2>/dev/null || true
        rm -rf "${TEST_TMP}" 2>/dev/null || true
    fi
}

mock_yay() {
    create_mock "yay" 'case "$1" in
        -Qi)
            pkg="$2"
            if grep -q "^$pkg$" "${TEST_TMP}/installed_packages.txt" 2>/dev/null; then
                echo "Name: $pkg"; echo "Version: 1.0.0-1"; exit 0
            fi
            exit 1 ;;
        -S)
            shift; for pkg in "$@"; do [[ "$pkg" =~ ^-- ]] && continue; echo "$pkg" >> "${TEST_TMP}/installed_packages.txt"; done
            echo "Installing packages: $*"; exit 0 ;;
        -Rns)
            shift; for pkg in "$@"; do [[ "$pkg" =~ ^-- ]] && continue; grep -v "^$pkg$" "${TEST_TMP}/installed_packages.txt" > "${TEST_TMP}/installed_packages.tmp" 2>/dev/null || true; mv "${TEST_TMP}/installed_packages.tmp" "${TEST_TMP}/installed_packages.txt" 2>/dev/null || true; done
            echo "Removing packages: $*"; exit 0 ;;
        *) echo "Mock yay: $*"; exit 0 ;;
    esac'
}

mock_npm() {
    create_mock "npm" 'case "$1" in
        install) echo "Installing npm packages: ${@:2}"; exit 0 ;;
        *) echo "Mock npm: $*"; exit 0 ;;
    esac'
}

mock_nvm() {
    mkdir -p "${TEST_TMP}/.nvm"
    mkdir -p "${TEST_TMP}/usr/share/nvm"

    echo '#!/bin/bash
export NVM_DIR="${TEST_TMP}/.nvm"' >"${TEST_TMP}/usr/share/nvm/init-nvm.sh"

    create_mock "nvm" 'case "$1" in
        install) echo "Installing Node.js $2"; exit 0 ;;
        alias) echo "Setting default alias"; exit 0 ;;
        use) echo "Using Node.js $2"; exit 0 ;;
        *) echo "Mock nvm: $*"; exit 0 ;;
    esac'

    create_mock "node" 'echo "v18.19.0"'
    mock_npm
}

mock_stow() {
    create_mock "stow" 'if [[ "$1" == "-v" && "$2" == "-d" ]]; then
        source_dir="$3"; target_dir="$5"; package="$6"
        echo "Stowing $package from $source_dir to $target_dir"
    fi
    exit 0'
}

mock_micro() {
    create_mock "micro" 'case "$1" in
        -plugin) [[ "$2" == "install" ]] && echo "Installing micro plugin: $3"; exit 0 ;;
        *) echo "Mock micro: $*"; exit 0 ;;
    esac'
}

mock_code() {
    create_mock "code" 'case "$1" in
        --install-extension) echo "Installing VS Code extension: $2"; exit 0 ;;
        *) echo "Mock code: $*"; exit 0 ;;
    esac'
}

mock_hyprctl() {
    create_mock "hyprctl" 'case "$1" in
        switchxkblayout) echo "Switching keyboard layout"; exit 0 ;;
        dispatch) echo "Dispatching command: ${@:2}"; exit 0 ;;
        *) echo "Mock hyprctl: $*"; exit 0 ;;
    esac'
}

mock_go() {
    create_mock "go" 'case "$1" in
        version) echo "go version go1.21.5 linux/amd64"; exit 0 ;;
        install) echo "Installing Go package: $2"; exit 0 ;;
        *) echo "Mock go: $*"; exit 0 ;;
    esac'
}

mock_pkill() {
    create_mock "pkill" 'exit 0'
}

mock_pgrep() {
    create_mock "pgrep" 'if [[ "$1" == "-x" && "$2" == "waybar" ]]; then
        echo "12345"; exit 0
    fi
    exit 1'
}

assert_file_contains() {
    local file="$1"
    local pattern="$2"
    local message="${3:-File $file should contain $pattern}"

    [[ ! -f "$file" ]] && {
        echo "File $file does not exist" >&2
        return 1
    }

    if ! grep -q "$pattern" "$file"; then
        echo "$message. File contents:" >&2
        cat "$file" >&2
        return 1
    fi
}

assert_file_not_contains() {
    local file="$1"
    local pattern="$2"
    local message="${3:-File $file should not contain $pattern}"

    [[ ! -f "$file" ]] && return 0

    if grep -q "$pattern" "$file"; then
        echo "$message. File contents:" >&2
        cat "$file" >&2
        return 1
    fi
}

assert_command_called() {
    local command="$1"
    local log_file="${TEST_TMP}/${command}.log"
    local message="${2:-Command $command should have been called}"

    if [[ ! -f "$log_file" ]] || [[ ! -s "$log_file" ]]; then
        echo "$message. Log file: $log_file" >&2
        return 1
    fi
}

assert_command_called_with() {
    local command="$1"
    local expected_args="$2"
    local log_file="${TEST_TMP}/${command}.log"
    local message="${3:-Command $command should have been called with args: $expected_args}"

    if [[ ! -f "$log_file" ]]; then
        echo "Command $command was not called. Log file: $log_file" >&2
        return 1
    fi

    if ! grep -qF "$expected_args" "$log_file"; then
        echo "$message. Log contents:" >&2
        cat "$log_file" >&2
        return 1
    fi
}

load_test_config() {
    local config_name="${1:-valid}"
    local config_file="${FIXTURES}/${config_name}_pomarchy.conf"

    if [[ -f "$config_file" ]]; then
        cp "$config_file" "${HOME}/.config/pomarchy/pomarchy.conf"
    else
        echo "Test config file not found: $config_file" >&2
        return 1
    fi
}

run_in_test_env() {
    run env HOME="${TEST_TMP}/home" PATH="${TEST_TMP}/bin:$PATH" "$@"
}
