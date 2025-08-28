#!/usr/bin/env bash

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POMARCHY_ROOT="$(cd "${SRC_DIR}/.." && pwd)"
TEST_DIR="$SRC_DIR"

export POMARCHY_ROOT
export PATH="${POMARCHY_ROOT}:${PATH}"
export TEST_CONFIG_DIR="${SRC_DIR}/fixtures/config"
export HOME="${SRC_DIR}/fixtures/home"
export TEST_DIR
export SRC_DIR

setup_test_environment() {
    mkdir -p "${TEST_CONFIG_DIR}/pomarchy"
    mkdir -p "${HOME}/.config/pomarchy"
    cp "${POMARCHY_ROOT}/src/config/pomarchy/.config/pomarchy/pomarchy.conf" \
       "${HOME}/.config/pomarchy/pomarchy.conf"
}

teardown_test_environment() {
    rm -rf "${SRC_DIR}/fixtures"
}

mock_yay() {
    mkdir -p "${SRC_DIR}/fixtures/bin"
    cat > "${SRC_DIR}/fixtures/bin/yay" << 'EOF'
#!/bin/bash
case "$1" in
    -Qi) exit 1 ;;
    -S) echo "Mock: Installing $@"; exit 0 ;;
    -Rns) echo "Mock: Removing $@"; exit 0 ;;
    *) echo "Mock yay: $@"; exit 0 ;;
esac
EOF
    chmod +x "${SRC_DIR}/fixtures/bin/yay"
    export PATH="${SRC_DIR}/fixtures/bin:${PATH}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

skip_if_missing() {
    local cmd="$1"
    if ! command_exists "$cmd"; then
        skip "Command '$cmd' not available"
    fi
}