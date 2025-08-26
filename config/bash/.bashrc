source ~/.local/share/omarchy/default/bash/rc
set -h

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

eval "$(atuin init bash)"

[ -f ~/.bash_aliases ] && source ~/.bash_aliases

# Add pomarchy alias - update path to match your installation location
# alias pomarchy="/path/to/your/pomarchy/pomarchy"

cd() { 
    builtin cd -- "$@" && { 
        [ "$PS1" = "" ] || (command -v eza >/dev/null 2>&1 && eza -lh --group-directories-first --icons=auto || ls)
    }
}

lsgrep() {
    if command -v eza >/dev/null 2>&1; then
        eza -hal | grep "$*"
    else
        ls -hal | grep "$*"
    fi
}

del() {
    mkdir -p /tmp/.trash && mv "$@" /tmp/.trash
}

buf() {
    local filename=$1
    local filetime=$(date +%Y%m%d_%H%M%S)
    cp -a "${filename}" "${filename}_${filetime}"
}

alert() {
    notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e 's/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//')"
}

tmuxp() {
    tmux -q has-session && exec tmux attach-session -d || exec tmux new-session -n$USER -s$USER@$HOSTNAME
}

if [[ $UID -ge 1000 && -d $HOME/.npm-global/bin && -z $(echo $PATH | grep -o $HOME/.npm-global/bin) ]]; then
    export PATH=$HOME/.npm-global/bin:${PATH}
fi
