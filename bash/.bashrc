#
# ~/.bashrc
#

## Prompt

export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;34m\]\w$(__git_ps1) \$\[\033[00m\] '

## General

# Prevent file overwrite on stdout redirection
# Use `>|` to force redirection to an existing file
set -o noclobber

# Update window size after every command
shopt -s checkwinsize

# Automatically trim long paths in the prompt
PROMPT_DIRTRIM=2

# Enable history expansion with space
# E.g. typing !!<space> will replace the !! with your last command
bind Space:magic-space

# Turn on recursive globbing (enables ** to recurse all directories)
shopt -s globstar 2> /dev/null

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Enable extended globs, which have the expressive power of regular expressions
shopt -s extglob

# Disable completion when the input buffer is empty
shopt -s no_empty_cmd_completion

# Colored manual pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

## Sane history defaults

# Append to the history file, don't overwrite it
shopt -s histappend

# Save multi-line commands as one command
shopt -s cmdhist

# Record each line as it gets issued
PROMPT_COMMAND='history -a'

# bash history will save N commands
HISTSIZE=1000

# bash will remember N commands
HISTFILESIZE=${HISTSIZE}

# Avoid duplicate entries
HISTCONTROL="erasedups:ignoreboth"

# Don't record some commands
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"

# Use standard ISO 8601 timestamp
# %F equivalent to %Y-%m-%d
# %T equivalent to %H:%M:%S (24-hours format)
HISTTIMEFORMAT='%F %T '

## Better directory navigations

# Prepend cd to directory names automatically
shopt -s autocd 2> /dev/null
# Correct spelling errors during tab-completion
shopt -s dirspell 2> /dev/null
# Correct spelling errors in arguments supplied to cd
shopt -s cdspell 2> /dev/null

# This defines where cd looks for targets
# Add the directories you want to have fast access to, separated by colon
# Ex: CDPATH=".:~:~/projects" will look for targets in the current working directory, in home and in the ~/projects folder
CDPATH="."

# This allows you to bookmark your favorite places across the file system
# Define a variable containing a path and you will be able to cd into it regardless of the directory you're in
shopt -s cdable_vars

# Examples:
export dotfiles="$HOME/dotfiles"
# export projects="$HOME/projects"

## Bindings

# Moving between words with Ctrl+Left and Ctrl+Right
bind '"\eOd": backward-word'
bind '"\eOc": forward-word'

# Enable non-incremental search with up/down arrows
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\e[C": forward-char'
bind '"\e[D": backward-char'

# Bound Alt+R and Alt+F for incremental search
bind '"\er": reverse-search-history'
bind '"\ef": forward-search-history'

# Display matches for ambiguous patterns at first tab press
bind 'set show-all-if-ambiguous on'

# Disable control echo
bind 'set echo-control-characters off'

# Perform file completion in a case insensitive fashion
bind 'set completion-ignore-case on'

# Treat hyphens and underscores as equivalent
bind 'set completion-map-case on'

# Immediately add a trailing slash when autocompleting symlinks to directories
bind 'set mark-symlinked-directories on'

# Invoke the manual for the command preceding the cursor by pressing Alt+E
bind '"\ee": "\C-a\eb\ed\C-y\e#man \C-y\C-m\C-p\C-p\C-a\C-d\C-e"'

# Prefixes the line with sudo, if Alt+X is pressed
bind '"\ex":"\C-asudo \C-e"'

## Sources

# Automatically search the official repositories when entering an unrecognized command (Fedora)
if [ -f /usr/libexec/pk-command-not-found ]; then
    command_not_found_handle() {
        local pkgs=$(PATH="$PATH:/sbin" /usr/libexec/pk-command-not-found "$1" 2>/dev/null)
        if [ -n "$pkgs" ]; then
            echo -n "The program '$1' is not currently installed. You can install it by typing: "
            echo "sudo dnf install $pkgs"
        else
            echo "bash: $1: command not found"
        fi
        return 127
    }
fi
# Allows seeing repository status in your prompt (Fedora)
[[ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]] && . /usr/share/git-core/contrib/completion/git-prompt.sh

# Automatically search the official repositories when entering an unrecognized command (Arch)
[[ -f /usr/share/doc/pkgfile/command-not-found.bash ]] && . /usr/share/doc/pkgfile/command-not-found.bash

# Allows seeing repository status in your prompt (Arch)
[[ -f /usr/share/git/git-prompt.sh ]] && . /usr/share/git/git-prompt.sh

# Allows seeing repository status in your prompt (Ubuntu)
[[ -f /etc/bash_completion.d/git-prompt ]] && . /etc/bash_completion.d/git-prompt

## Ubuntu related

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

## Functions

# Archive and compress a wide range of file types
compress() {
  if [[ -n "$1" ]]; then
    FILE=$1
    case $FILE in
    *.tar ) shift && tar cf $FILE $* ;;
    *.tar.bz2 ) shift && tar cjf $FILE $* ;;
    *.tar.gz ) shift && tar czf $FILE $* ;;
    *.tgz ) shift && tar czf $FILE $* ;;
    *.zip ) shift && zip $FILE $* ;;
    *.rar ) shift && rar $FILE $* ;;
    esac
  else
    echo "usage: compress <foo.tar.gz> ./foo ./bar"
  fi
}

# Extract a wide range of compressed file types
extract() {
    local c e i

    (($#)) || return

    for i; do
        c=''
        e=1

        if [[ ! -r $i ]]; then
            echo "$0: file is unreadable: \`$i'" >&2
            continue
        fi

        case $i in
            *.t@(gz|lz|xz|b@(2|z?(2))|a@(z|r?(.@(Z|bz?(2)|gz|lzma|xz)))))
                   c=(bsdtar xvf);;
            *.7z)  c=(7z x);;
            *.Z)   c=(uncompress);;
            *.bz2) c=(bunzip2);;
            *.exe) c=(cabextract);;
            *.gz)  c=(gunzip);;
            *.rar) c=(unrar x);;
            *.xz)  c=(unxz);;
            *.zip) c=(unzip);;
            *)     echo "$0: unrecognized file extension: \`$i'" >&2
                   continue;;
        esac

        command "${c[@]}" "$i"
        ((e = e || $?))
    done
    return "$e"
}

# Enter and list directory
function cd() { builtin cd -- "$@" && { [ "$PS1" = "" ] || ls; }; }

# Find directory sizes and list them for the current directory
dirsize () {
  du -shx * .[a-zA-Z0-9_]* 2> /dev/null | egrep '^ *[0-9.]*[MG]' | sort -n > /tmp/list
  egrep '^ *[0-9.]*M' /tmp/list
  egrep '^ *[0-9.]*G' /tmp/list
  rm -rf /tmp/list
}

# Move filenames to lowercase
lowercase() {
  for file ; do
    filename=${file##*/}
    case "$filename" in
    */* ) dirname==${file%/*} ;;
      * ) dirname=.;;
    esac
    nf=$(echo $filename | tr A-Z a-z)
    newname="${dirname}/${nf}"
    if [[ "$nf" != "$filename" ]]; then
      mv "$file" "$newname"
      echo "lowercase: $file --> $newname"
    else
      echo "lowercase: $file not changed."
    fi
  done
}

# Systemd support
if which systemctl &>/dev/null; then
  start() {
    sudo systemctl start $1.service
  }
  restart() {
    sudo systemctl restart $1.service
  }
  stop() {
    sudo systemctl stop $1.service
  }
  enable() {
    sudo systemctl enable $1.service
  }
  status() {
    sudo systemctl status $1.service
  }
  disable() {
    sudo systemctl disable $1.service
  }
fi

# Search through directory contents with grep
function lsgrep ()
{
    ls -hal | grep "$*"
}

# Detailed information on an IP address or hostname
ipif() {
    if grep -P "(([1-9]\d{0,2})\.){3}(?2)" <<< "$1"; then
	curl ipinfo.io/"$1"
    else
	ipawk=($(host "$1" | awk '/address/ { print $NF }'))
	curl ipinfo.io/${ipawk[1]}
    fi
    echo
}

# Move files to hidden folder in tmp, that gets cleared on each reboot
function del() {
    mkdir -p /tmp/.trash && mv "$@" /tmp/.trash;
}

# Back up file with timestamp
function buf ()
{
    local filename=$1
    local filetime=$(date +%Y%m%d_%H%M%S)
    cp -a "${filename}" "${filename}_${filetime}"
}

# Copy and cd into directory
cpcd (){
  if [ -d "$2" ];then
    cp -iv $1 $2 && cd $2
  else
    cp -iv $1 $2
  fi
}

# Move and cd into directory
mvcd (){
  if [ -d "$2" ];then
    mv -iv $1 $2 && cd $2
  else
    mv -iv $1 $2
  fi
}

# Make a directory and cd into it
mkcd (){
    mkdir -p $1 && cd $1
}

## Aliases

# pacman
alias pacun='pacaur -Rcsn'            # Remove the specified package(s), its configuration(s) and unneeded dependencies
alias pacorph='pacaur -Qdtq'          # Query the orphaned package(s) database
alias pacind='pacaur -S --asdeps'     # Install given package(s) as dependencies of another package
alias pacclean='pacaur -Sc'           # Delete all not currently installed package files
alias pacmake='makepkg -fcsi'         # Make package from PKGBUILD file in current directory

# ls
alias ls='ls --color=auto'
alias la='ls -a --color=auto'
alias lr='ls -R --color=auto'
alias ll='ls -hal --color=auto'

# DNF aliases for Fedora
alias dnfup='sudo dnf update'            # Update all packages
alias dnfins='sudo dnf install'          # Install specified package(s)
alias dnfrm='sudo dnf remove'            # Remove specified package(s)
alias dnfsearch='dnf search'             # Search package(s)

# Add an "alert" alias for long running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Start urxvt with a started tmux session
alias tmuxp='tmux -q has-session && exec tmux attach-session -d || exec tmux new-session -n$USER -s$USER@$HOSTNAME'

## Misc

# Autostart X at login
if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
    exec startx
fi

# Set PATH so it includes user's private bin directories
if [[ $UID -ge 1000 && -d $HOME/.local/bin && -z $(echo $PATH | grep -o $HOME/.local/bin) ]]
then
    export PATH=$HOME/.local/bin:${PATH}
fi

# Set PATH so it includes user's npm global directories
if [[ $UID -ge 1000 && -d $HOME/.npm-global/bin && -z $(echo $PATH | grep -o $HOME/.npm-global/bin) ]]
then
    export PATH=$HOME/.npm-global/bin:${PATH}    
fi

