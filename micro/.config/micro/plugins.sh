#!/bin/bash
PLUGINS_DIR="$HOME/.config/micro/plug"

if [ ! -d "$PLUGINS_DIR" ] || [ -z "$(ls -A "$PLUGINS_DIR" 2>/dev/null)" ]; then
    echo "Installing micro plugins..."
    micro -plugin install fzf
    micro -plugin install editorconfig
    micro -plugin install detectindent
    micro -plugin install snippets
    micro -plugin install bookmark
    micro -plugin install lsp
    micro -plugin install wc
    echo "Plugin installation complete"
else
    echo "Plugins already installed"
fi