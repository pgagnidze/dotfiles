#!/usr/bin/env bash
set -euo pipefail

readonly POMARCHY_ROOT="${POMARCHY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "${POMARCHY_ROOT}/lib/common.sh"
load_config

show_status() {
    log STEP "Checking system status..."
    
    echo ""
    echo "▶ Package Status"
    if [[ -n "$PACKAGES_INSTALL" ]]; then
        IFS=' ' read -ra packages <<< "$PACKAGES_INSTALL"
        for pkg in "${packages[@]}"; do
            if yay -Qi "$pkg" &> /dev/null; then
                echo "▣ $pkg - installed"
            else
                echo "▢ $pkg - not installed"
            fi
        done
    else
        echo "▢ No packages configured for installation"
    fi
    
    echo ""
    echo "▶ Dotfiles Status"
    
    local config_dir="${POMARCHY_ROOT}/config"
    
    if [[ -L "$HOME/.bashrc" ]]; then
        local bashrc_target
        bashrc_target=$(readlink -f "$HOME/.bashrc" 2>/dev/null)
        if [[ "$bashrc_target" == "$config_dir/bash/.bashrc" ]]; then
            echo "▣ bash - stowed"
        else
            echo "▢ bash - not stowed (points elsewhere)"
        fi
    else
        echo "▢ bash - not stowed"
    fi
    
    if [[ -L "$HOME/.config/micro/bindings.json" ]]; then
        local micro_target
        micro_target=$(readlink -f "$HOME/.config/micro/bindings.json" 2>/dev/null)
        if [[ "$micro_target" == "$config_dir/micro/.config/micro/bindings.json" ]]; then
            echo "▣ micro - stowed"
        else
            echo "▢ micro - not stowed (points elsewhere)"
        fi
    else
        echo "▢ micro - not stowed"  
    fi
    
    if [[ -L "$HOME/.config/alacritty/alacritty.toml" ]]; then
        local alacritty_target
        alacritty_target=$(readlink -f "$HOME/.config/alacritty/alacritty.toml" 2>/dev/null)
        if [[ "$alacritty_target" == "$config_dir/alacritty/.config/alacritty/alacritty.toml" ]]; then
            echo "▣ alacritty - stowed"
        else
            echo "▢ alacritty - not stowed (points elsewhere)"
        fi
    else
        echo "▢ alacritty - not stowed"
    fi
    
    echo ""
    echo "▶ Configuration Status"
    if [[ -f "$HOME/.config/hypr/input.conf" ]]; then
        echo "▣ Hyprland input configured"
    else
        echo "▢ Hyprland input not configured"
    fi
    
    if [[ -f "$HOME/.config/hypr/monitors.conf" ]]; then
        echo "▣ Hyprland monitors configured"  
    else
        echo "▢ Hyprland monitors not configured"
    fi
    
    echo ""
    echo "▶ Development Environment"
    if command -v node &> /dev/null; then
        echo "▣ Node.js - $(node --version)"
    else
        echo "▢ Node.js - not installed"
    fi
    
    if command -v go &> /dev/null; then
        echo "▣ Go - $(go version | cut -d' ' -f3)"
    else
        echo "▢ Go - not installed"
    fi
    
    if command -v claude &> /dev/null; then
        echo "▣ Claude Code - installed"
    else
        echo "▢ Claude Code - not installed"
    fi
    
    echo ""
    echo "▶ Additional Configuration"
    if [[ -f "$HOME/.claude/settings.json" ]]; then
        echo "▣ Claude Code settings - configured"
    else
        echo "▢ Claude Code settings - not configured"
    fi
    
    if [[ -f "$HOME/.bash_aliases" ]]; then
        echo "▣ Bash aliases - configured"
    else
        echo "▢ Bash aliases - not configured"
    fi
    
    if grep -q "atuin init bash" "$HOME/.bashrc" 2>/dev/null; then
        echo "▣ Atuin - configured"
    else
        echo "▢ Atuin - not configured"
    fi
    
    if xdg-settings get default-web-browser 2>/dev/null | grep -q firefox; then
        echo "▣ Firefox - default browser"
    else
        echo "▢ Firefox - not default browser"
    fi
    
    echo ""
    echo "▶ Global Tools"
    if [[ -n "$NPM_PACKAGES" ]]; then
        IFS=' ' read -ra npm_packages <<< "$NPM_PACKAGES"
        for pkg in "${npm_packages[@]}"; do
            if npm list -g "$pkg" &>/dev/null; then
                echo "▣ npm: $pkg - installed"
            else
                echo "▢ npm: $pkg - not installed"
            fi
        done
    fi
    
    if [[ -n "$GO_TOOLS" ]]; then
        IFS=' ' read -ra go_tools <<< "$GO_TOOLS"
        for tool in "${go_tools[@]}"; do
            tool_name=$(basename "$tool" | cut -d'@' -f1)
            if command -v "$tool_name" &>/dev/null; then
                echo "▣ go: $tool_name - installed"
            else
                echo "▢ go: $tool_name - not installed"
            fi
        done
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_status
fi