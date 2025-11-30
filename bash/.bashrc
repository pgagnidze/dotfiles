# =============================================================================
# Bash Configuration
# =============================================================================

# -----------------------------------------------------------------------------
# Shell Options
# -----------------------------------------------------------------------------
# Prevent file overwrite on stdout redirection (use >| to force)
set -o noclobber

# Update window size after every command
shopt -s checkwinsize

# Turn on recursive globbing (** recurses directories)
shopt -s globstar 2>/dev/null

# Case-insensitive globbing
shopt -s nocaseglob

# Extended globs (regex-like patterns)
shopt -s extglob

# Don't complete on empty input
shopt -s no_empty_cmd_completion

# Prepend cd to directory names automatically
shopt -s autocd 2>/dev/null

# Correct spelling errors in cd arguments
shopt -s cdspell 2>/dev/null

# Correct spelling errors during tab-completion
shopt -s dirspell 2>/dev/null

# Bookmark directories with variables (cd $dotfiles)
shopt -s cdable_vars

# Ensure command hashing is off for mise
set +h

# -----------------------------------------------------------------------------
# History
# -----------------------------------------------------------------------------
shopt -s histappend # Append, don't overwrite
shopt -s cmdhist    # Save multi-line commands as one

HISTCONTROL="erasedups:ignoreboth"
HISTSIZE=32768
HISTFILESIZE="${HISTSIZE}"
HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear:cd"
HISTTIMEFORMAT='%F %T '

# Record each line as it gets issued
PROMPT_COMMAND='history -a'

# -----------------------------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------------------------
export EDITOR=nvim
export SUDO_EDITOR="$EDITOR"

# Colored manual pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

# Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# NPM global packages
[[ $UID -ge 1000 && -d $HOME/.npm-global/bin ]] && export PATH=$HOME/.npm-global/bin:${PATH}

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# -----------------------------------------------------------------------------
# Autocompletion
# -----------------------------------------------------------------------------
if [[ ! -v BASH_COMPLETION_VERSINFO ]]; then
  for completion in /usr/share/bash-completion/bash_completion /etc/bash_completion; do
    [[ -f "$completion" ]] && source "$completion" && break
  done
fi

# -----------------------------------------------------------------------------
# Readline Configuration
# -----------------------------------------------------------------------------
if [[ $- == *i* ]]; then
  # Unicode support
  bind 'set meta-flag on'
  bind 'set input-meta on'
  bind 'set output-meta on'
  bind 'set convert-meta off'

  # Completion settings
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

  # Key bindings
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

# -----------------------------------------------------------------------------
# Tool Initialization
# -----------------------------------------------------------------------------
command -v mise &>/dev/null && eval "$(mise activate bash)"

command -v starship &>/dev/null && eval "$(starship init bash)"

command -v zoxide &>/dev/null && eval "$(zoxide init bash)"

if command -v fzf &>/dev/null; then
  for fzf_bindings in \
    /usr/share/fzf/shell/key-bindings.bash \
    /usr/share/fzf/key-bindings.bash \
    /usr/share/doc/fzf/examples/key-bindings.bash; do
    [[ -f "$fzf_bindings" ]] && source "$fzf_bindings" && break
  done
fi

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
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
      builtin cd ~ && return
    elif [ -d "$1" ]; then
      builtin cd "$1"
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

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------
mkcd() { mkdir -p "$1" && cd "$1"; }
cpcd() { [[ -d "$2" ]] && cp -iv "$1" "$2" && cd "$2" || cp -iv "$1" "$2"; }
mvcd() { [[ -d "$2" ]] && mv -iv "$1" "$2" && cd "$2" || mv -iv "$1" "$2"; }

dirsize() {
  du -shx * .[a-zA-Z0-9_]* 2>/dev/null | grep -E '^\s*[0-9.]+[MG]' | sort -h
}

lsgrep() {
  if command -v eza &>/dev/null; then
    eza -hal | grep "$*"
  else
    ls -hal | grep "$*"
  fi
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

lowercase() {
  local file filename dirname nf newname
  for file; do
    filename=${file##*/}
    dirname=${file%/*}
    [[ "$dirname" == "$file" ]] && dirname="."
    nf=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
    newname="${dirname}/${nf}"
    if [[ "$nf" != "$filename" ]]; then
      mv "$file" "$newname"
      echo "lowercase: $file --> $newname"
    else
      echo "lowercase: $file not changed."
    fi
  done
}

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

format-drive() {
  if [ $# -ne 2 ]; then
    echo "Usage: format-drive <device> <name>"
    echo "Example: format-drive /dev/sda 'My Stuff'"
    echo -e "\nAvailable drives:"
    lsblk -d -o NAME -n | awk '{print "/dev/"$1}'
  else
    echo "WARNING: This will completely erase all data on $1 and label it '$2'."
    read -rp "Are you sure you want to continue? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      sudo wipefs -a "$1"
      sudo dd if=/dev/zero of="$1" bs=1M count=100 status=progress
      sudo parted -s "$1" mklabel gpt
      sudo parted -s "$1" mkpart primary 1MiB 100%
      partition="$([[ $1 == *"nvme"* ]] && echo "${1}p1" || echo "${1}1")"
      sudo partprobe "$1" || true
      sudo udevadm settle || true
      sudo mkfs.exfat -n "$2" "$partition"
      echo "Drive $1 formatted as exFAT and labeled '$2'."
    fi
  fi
}

transcode-video-1080p() {
  ffmpeg -i "$1" -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy "${1%.*}-1080p.mp4"
}

transcode-video-4K() {
  ffmpeg -i "$1" -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k "${1%.*}-optimized.mp4"
}

img2jpg() {
  local img="$1"
  shift
  magick "$img" "$@" -quality 95 -strip "${img%.*}-optimized.jpg"
}

img2jpg-small() {
  local img="$1"
  shift
  magick "$img" "$@" -resize '1080x>' -quality 95 -strip "${img%.*}-optimized.jpg"
}

img2png() {
  local img="$1"
  shift
  magick "$img" "$@" -strip \
    -define png:compression-filter=5 \
    -define png:compression-level=9 \
    -define png:compression-strategy=1 \
    -define png:exclude-chunk=all \
    "${img%.*}-optimized.png"
}

ipif() {
  if [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    curl -s "ipinfo.io/$1"
  else
    local ip=$(host "$1" 2>/dev/null | awk '/has address/ { print $NF; exit }')
    [[ -n "$ip" ]] && curl -s "ipinfo.io/$ip" || echo "Could not resolve: $1"
  fi
  echo
}

alert() {
  notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" \
    "$(history | tail -n1 | sed -e 's/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//')"
}
