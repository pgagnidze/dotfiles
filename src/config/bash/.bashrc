[ -f ~/.local/share/omarchy/default/bash/rc ] && source ~/.local/share/omarchy/default/bash/rc
set -h

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

if [[ -z "$(command -v pomarchy 2>/dev/null)" && -L ~/.bashrc ]]; then
    _bashrc_target=$(readlink -f ~/.bashrc)
    _pomarchy_root=$(cd "$(dirname "$_bashrc_target")" && git rev-parse --show-toplevel 2>/dev/null)
    if [[ -n "$_pomarchy_root" && -x "$_pomarchy_root/pomarchy" ]]; then
        alias pomarchy="$_pomarchy_root/pomarchy"
    fi
    unset _bashrc_target _pomarchy_root
fi

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
    local trash_path="/tmp/.trash"
    mkdir -p "$trash_path" && mv "$@" "$trash_path"
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
