# =============================================================================
# Pomarchy Bash Configuration for Fedora
# =============================================================================

# -----------------------------------------------------------------------------
# History Control
# -----------------------------------------------------------------------------
shopt -s histappend
HISTCONTROL=ignoreboth
HISTSIZE=32768
HISTFILESIZE="${HISTSIZE}"

# -----------------------------------------------------------------------------
# Autocompletion
# -----------------------------------------------------------------------------
if [[ ! -v BASH_COMPLETION_VERSINFO && -f /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi

# Ensure command hashing is off for mise
set +h

# -----------------------------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------------------------
export EDITOR=nvim
export SUDO_EDITOR="$EDITOR"
export BAT_THEME=ansi

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# NPM global packages
if [[ $UID -ge 1000 && -d $HOME/.npm-global/bin && -z $(echo $PATH | grep -o $HOME/.npm-global/bin) ]]; then
  export PATH=$HOME/.npm-global/bin:${PATH}
fi

# -----------------------------------------------------------------------------
# Tool Initialization
# -----------------------------------------------------------------------------
# mise (polyglot runtime manager)
if command -v mise &> /dev/null; then
  eval "$(mise activate bash)"
fi

# Starship prompt
if command -v starship &> /dev/null; then
  eval "$(starship init bash)"
fi

# Zoxide (smart cd)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init bash)"
fi

# fzf (fuzzy finder)
if command -v fzf &> /dev/null; then
  if [[ -f /usr/share/fzf/shell/key-bindings.bash ]]; then
    source /usr/share/fzf/shell/key-bindings.bash
  fi
fi

# -----------------------------------------------------------------------------
# Aliases - File System
# -----------------------------------------------------------------------------
if command -v eza &> /dev/null; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

# Zoxide-powered cd
if command -v zoxide &> /dev/null; then
  alias cd="zd"
  zd() {
    if [ $# -eq 0 ]; then
      builtin cd ~ && return
    elif [ -d "$1" ]; then
      builtin cd "$1"
    else
      z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
    fi
  }
fi

open() {
  xdg-open "$@" >/dev/null 2>&1 &
}

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# -----------------------------------------------------------------------------
# Aliases - Tools
# -----------------------------------------------------------------------------
alias d='docker'
alias r='rails'
n() { if [ "$#" -eq 0 ]; then nvim .; else nvim "$@"; fi; }

# Git
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

# -----------------------------------------------------------------------------
# Functions - File Operations
# -----------------------------------------------------------------------------
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
  notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e 's/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//')"
}

tmuxp() {
  tmux -q has-session && exec tmux attach-session -d || exec tmux new-session -n$USER -s$USER@$HOSTNAME
}

# -----------------------------------------------------------------------------
# Functions - Compression & Media
# -----------------------------------------------------------------------------
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"

# Write ISO to USB drive
iso2sd() {
  if [ $# -ne 2 ]; then
    echo "Usage: iso2sd <input_file> <output_device>"
    echo "Example: iso2sd ~/Downloads/fedora.iso /dev/sda"
    echo -e "\nAvailable drives:"
    lsblk -d -o NAME,SIZE,MODEL | grep -E '^sd[a-z]'
  else
    sudo dd bs=4M status=progress oflag=sync if="$1" of="$2"
    sudo eject $2
  fi
}

# Format drive as exFAT
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

# Video transcoding
transcode-video-1080p() {
  ffmpeg -i $1 -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy ${1%.*}-1080p.mp4
}

transcode-video-4K() {
  ffmpeg -i $1 -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k ${1%.*}-optimized.mp4
}

# Image conversion
img2jpg() {
  img="$1"
  shift
  magick "$img" $@ -quality 95 -strip ${img%.*}-optimized.jpg
}

img2jpg-small() {
  img="$1"
  shift
  magick "$img" $@ -resize 1080x\> -quality 95 -strip ${img%.*}-optimized.jpg
}

img2png() {
  img="$1"
  shift
  magick "$img" $@ -strip -define png:compression-filter=5 \
    -define png:compression-level=9 \
    -define png:compression-strategy=1 \
    -define png:exclude-chunk=all \
    "${img%.*}-optimized.png"
}

# -----------------------------------------------------------------------------
# Pomarchy alias (auto-detected from stow symlink)
# -----------------------------------------------------------------------------
if [[ -z "$(command -v pomarchy 2>/dev/null)" && -L ~/.bashrc ]]; then
  _bashrc_target=$(readlink -f ~/.bashrc)
  _pomarchy_root=$(cd "$(dirname "$_bashrc_target")" && git rev-parse --show-toplevel 2>/dev/null)
  if [[ -n "$_pomarchy_root" && -x "$_pomarchy_root/pomarchy" ]]; then
    alias pomarchy="$_pomarchy_root/pomarchy"
  fi
  unset _bashrc_target _pomarchy_root
fi

# -----------------------------------------------------------------------------
# Readline configuration
# -----------------------------------------------------------------------------
if [[ $- == *i* && -f ~/.config/readline/inputrc ]]; then
  bind -f ~/.config/readline/inputrc
fi
