#!/usr/bin/env bash
set -euo pipefail

readonly POMARCHY_ROOT="${POMARCHY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "${POMARCHY_ROOT}/lib/common.sh"
load_config

show_help() {
    echo "Usage: pomarchy setup devtools [OPTIONS]"
    echo ""
    echo "Setup development environment with modern tools and extensions."
    echo ""
    echo "What this command does:"
    echo "  • Installs Node.js v20 via NVM with global packages"
    echo "  • Sets up Go development tools (gopls, delve, golangci-lint)"
    echo "  • Installs VS Code extensions for Go, Python, Docker, Terraform"
    echo "  • Configures Claude Code with powerline status line"
    echo "  • Installs essential npm packages (TypeScript, ESLint, Prettier)"
    echo ""
    echo "Options:"
    echo "  --yes, -y    Skip confirmation prompts"
    echo "  --help, -h   Show this help message"
    echo ""
    echo "Examples:"
    echo "  pomarchy setup devtools         # Setup development tools with confirmation"
    echo "  pomarchy setup devtools --yes   # Setup development tools without prompts"
}

for arg in "$@"; do
    case "$arg" in
        --help|-h|help)
            show_help
            exit 0
            ;;
    esac
done

ensure_command yay

log STEP "Development Tools Setup"

setup_node() {
    if [[ -z "$NODEJS_VERSION" && -z "$NPM_PACKAGES" ]]; then
        return
    fi
    
    log STEP "Setting up Node.js environment..."
    
    if [[ -s "${NVM_INIT_PATH}" ]] || yay -Qi nvm &> /dev/null; then
        log INFO "NVM is already installed"
    else
        log INFO "Installing NVM..."
        yay -S --noconfirm nvm || log ERROR "Failed to install NVM"
    fi
    
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    [[ -s "${NVM_INIT_PATH}" ]] && source "${NVM_INIT_PATH}"
    
    if command -v nvm &> /dev/null; then
        if [[ -n "$NODEJS_VERSION" ]]; then
            log INFO "Installing Node.js v$NODEJS_VERSION..."
            nvm install "$NODEJS_VERSION"
            nvm alias default "$NODEJS_VERSION" > /dev/null
            nvm use "$NODEJS_VERSION" > /dev/null
            
            node_version=$(node --version 2>/dev/null || echo "not installed")
            log INFO "Node.js version: $node_version"
        fi
        
        if [[ -n "$NPM_PACKAGES" ]]; then
            log STEP "Installing global npm packages..."
            IFS=' ' read -ra PACKAGES <<< "$NPM_PACKAGES"
            npm install -g "${PACKAGES[@]}"
            log INFO "Global npm packages installed"
        fi
    else
        log ERROR "NVM not available. Please install manually."
    fi
}

setup_go() {
    if [[ -z "$GO_TOOLS" ]]; then
        return
    fi
    
    log STEP "Setting up Go environment..."
    
    if command -v go &> /dev/null; then
        go_version=$(go version)
        log INFO "Go is installed: $go_version"
        
        if [[ -z "${GOPATH:-}" ]] && ! grep -q "GOPATH.*go" "$HOME/.bashrc" 2>/dev/null; then
            echo 'export GOPATH=$HOME/go' >> "$HOME/.bashrc"
            echo 'export PATH=$PATH:$GOPATH/bin' >> "$HOME/.bashrc"
            export GOPATH=$HOME/go
            export PATH=$PATH:$GOPATH/bin
            log INFO "GOPATH set to $HOME/go"
        fi
        
        if [[ -n "$GO_TOOLS" ]]; then
            log STEP "Installing Go tools..."
            IFS=' ' read -ra TOOLS <<< "$GO_TOOLS"
            for tool in "${TOOLS[@]}"; do
                go install "$tool"
            done
            log INFO "Go development tools installed"
        fi
    else
        log ERROR "Go is not installed. Please run package-management.sh first."
    fi
}

setup_vscode() {
    if [[ -z "$VSCODE_EXTENSIONS" ]]; then
        return
    fi
    
    log STEP "Setting up VS Code extensions..."
    
    if command -v code &> /dev/null; then
        if [[ -n "$VSCODE_EXTENSIONS" ]]; then
            IFS=' ' read -ra EXTENSIONS <<< "$VSCODE_EXTENSIONS"
        else
            return
        fi
        
        for ext in "${EXTENSIONS[@]}"; do
            log INFO "Installing VS Code extension: $ext"
            code --install-extension "$ext" --force || log WARN "Failed to install $ext"
        done
        
        log INFO "VS Code extensions installed"
    else
        log WARN "VS Code is not installed. Skipping extension setup."
    fi
}

setup_claude_code() {
    log STEP "Setting up Claude Code configuration..."
    
    local claude_config_dir="$HOME/.claude"
    local settings_file="$claude_config_dir/settings.json"
    
    mkdir -p "$claude_config_dir"
    
    if [[ ! -f "$settings_file" ]]; then
        cat > "$settings_file" << 'EOF'
{
  "statusLine": {
    "type": "command", 
    "command": "npx -y @owloops/claude-powerline@latest --style=powerline"
  }
}
EOF
        log INFO "Claude Code settings.json created with powerline status line"
    else
        log INFO "Claude Code settings.json already exists"
    fi
}

setup_shell() {
    log STEP "Setting up shell enhancements..."
    
    readonly ALIAS_FILE="$HOME/.bash_aliases"
    if [[ ! -f "$ALIAS_FILE" ]]; then
        cat > "$ALIAS_FILE" << 'EOF'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias docker-clean='docker system prune -a'
alias k='kubectl'
alias tf='terraform'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
EOF
        log INFO "Bash aliases created"
        
        if ! grep -q "bash_aliases" "$HOME/.bashrc" 2>/dev/null; then
            echo '[ -f ~/.bash_aliases ] && source ~/.bash_aliases' >> "$HOME/.bashrc"
        fi
    else
        log INFO "Bash aliases already exist"
    fi
}


setup_node
setup_go
setup_vscode
setup_claude_code
setup_shell

log INFO "Development tools setup complete!"
echo ""
echo "Please restart your shell or run: source ~/.bashrc"