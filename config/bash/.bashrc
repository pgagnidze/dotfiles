# shellcheck shell=bash

set -o noclobber

shopt -s checkwinsize
shopt -s globstar 2>/dev/null
shopt -s nocaseglob
shopt -s extglob
shopt -s no_empty_cmd_completion
shopt -s autocd 2>/dev/null
shopt -s cdspell 2>/dev/null
shopt -s dirspell 2>/dev/null
shopt -s cdable_vars

shopt -s histappend
shopt -s cmdhist
HISTCONTROL="erasedups:ignoreboth"
HISTSIZE=32768
HISTFILESIZE="${HISTSIZE}"
HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear:cd"
HISTTIMEFORMAT='%F %T '
PROMPT_COMMAND='history -a'

export EDITOR=nvim
export SUDO_EDITOR="$EDITOR"

[[ -d $HOME/.local/bin ]] && export PATH=$HOME/.local/bin:${PATH}

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

[[ $UID -ge 1000 && -d $HOME/.npm-global/bin ]] && export PATH=$HOME/.npm-global/bin:${PATH}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

if [[ ! -v BASH_COMPLETION_VERSINFO ]]; then
    for completion in /usr/share/bash-completion/bash_completion /etc/bash_completion; do
        [[ -f "$completion" ]] && source "$completion" && break
    done
fi

if [[ $- == *i* ]]; then
    bind 'set meta-flag on'
    bind 'set input-meta on'
    bind 'set output-meta on'
    bind 'set convert-meta off'

    bind 'set completion-ignore-case on'
    bind 'set completion-map-case on'
    bind 'set show-all-if-ambiguous on'
    bind 'set show-all-if-unmodified on'
    bind 'set mark-symlinked-directories on'
    bind 'set match-hidden-files off'
    bind 'set page-completions off'
    bind 'set completion-query-items 200'
    bind 'set visible-stats on'
    bind 'set skip-completed-text on'
    bind 'set colored-stats on'
    bind 'set colored-completion-prefix on'
    bind 'set echo-control-characters off'

    bind '"\e[A": history-search-backward'
    bind '"\e[B": history-search-forward'
    bind '"\e[C": forward-char'
    bind '"\e[D": backward-char'
    bind '"\e[1;5D": backward-word'
    bind '"\e[1;5C": forward-word'
    bind '"\er": reverse-search-history'
    bind '"\ef": forward-search-history'
    bind '"\ex": "\C-asudo \C-e"'
    bind Space:magic-space
fi

[[ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]] && \
    source /usr/share/git-core/contrib/completion/git-prompt.sh

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWCOLORHINTS=1

__prompt_command() {
    local exit_code=$?
    history -a
    local arrow
    if [[ $exit_code -eq 0 ]]; then
        arrow='\[\e[32m\]>\[\e[0m\]'
    else
        arrow='\[\e[31m\]>\[\e[0m\]'
    fi
    PS1="${arrow} \[\e[01;34m\]\W\[\e[0m\]\$(__git_ps1 ' (%s)') "
}

PROMPT_COMMAND='__prompt_command'

command -v zoxide &>/dev/null && eval "$(zoxide init bash)"

if command -v fzf &>/dev/null; then
    for fzf_bindings in \
        /usr/share/fzf/shell/key-bindings.bash \
        /usr/share/fzf/key-bindings.bash \
        /usr/share/doc/fzf/examples/key-bindings.bash; do
        [[ -f "$fzf_bindings" ]] && source "$fzf_bindings" && break
    done
fi

if command -v eza &>/dev/null; then
    alias ls='eza -lh --group-directories-first --icons=auto'
    alias lsa='ls -a'
    alias lt='eza --tree --level=2 --long --icons --git'
    alias lta='lt -a'
else
    alias ls='ls --color=auto'
    alias la='ls -a'
    alias ll='ls -hal'
fi

alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

if command -v zoxide &>/dev/null; then
    alias cd="zd"
    zd() {
        if [ $# -eq 0 ]; then
            builtin cd ~ || return
        elif [ -d "$1" ]; then
            builtin cd "$1" || return
        else
            z "$@" || echo "Error: Directory not found"
        fi
    }
fi

open() { xdg-open "$@" >/dev/null 2>&1 & }

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias d='docker'
n() { if [ "$#" -eq 0 ]; then nvim .; else nvim "$@"; fi; }

alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

mkcd() { mkdir -p "$1" && cd "$1" || return; }

cpcd() {
    if [[ -d "$2" ]]; then
        cp -iv "$1" "$2" && cd "$2" || return
    else
        cp -iv "$1" "$2"
    fi
}

mvcd() {
    if [[ -d "$2" ]]; then
        mv -iv "$1" "$2" && cd "$2" || return
    else
        mv -iv "$1" "$2"
    fi
}

dirsize() {
    du -shx ./* ./.[a-zA-Z0-9_]* 2>/dev/null | grep -E '^\s*[0-9.]+[MG]' | sort -h
}

del() { mkdir -p /tmp/.trash && mv "$@" /tmp/.trash; }
buf() { cp -a "$1" "${1}_$(date +%Y%m%d_%H%M%S)"; }

extract() {
    local file
    for file; do
        [[ ! -r "$file" ]] && echo "extract: unreadable: '$file'" >&2 && continue
        case "$file" in
            *.tar.bz2 | *.tbz2) tar xjf "$file" ;;
            *.tar.gz | *.tgz) tar xzf "$file" ;;
            *.tar.xz | *.txz) tar xJf "$file" ;;
            *.tar.zst) tar --zstd -xf "$file" ;;
            *.tar) tar xf "$file" ;;
            *.bz2) bunzip2 "$file" ;;
            *.gz) gunzip "$file" ;;
            *.xz) unxz "$file" ;;
            *.zst) unzstd "$file" ;;
            *.zip) unzip "$file" ;;
            *.rar) unrar x "$file" ;;
            *.7z) 7z x "$file" ;;
            *.Z) uncompress "$file" ;;
            *) echo "extract: unknown format: '$file'" >&2 ;;
        esac
    done
}

compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }

iso2sd() {
    if [ $# -ne 2 ]; then
        echo "Usage: iso2sd <input_file> <output_device>"
        echo "Example: iso2sd ~/Downloads/fedora.iso /dev/sda"
        echo -e "\nAvailable drives:"
        lsblk -d -o NAME,SIZE,MODEL | grep -E '^sd[a-z]'
    else
        sudo dd bs=4M status=progress oflag=sync if="$1" of="$2"
        sudo eject "$2"
    fi
}
