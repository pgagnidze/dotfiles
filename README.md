# Dotfiles

Personal dotfiles for Fedora, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
.
├── bash/           # Bash configuration + readline
├── git/            # Git configuration with GPG signing
├── ghostty/        # Ghostty terminal (Monokai Pro Ristretto)
└── assets/
    └── wallpapers/ # Ristretto theme wallpapers
```

## Quick Start

```bash
# Clone
git clone https://github.com/pgagnidze/pomarchy.git ~/dotfiles
cd ~/dotfiles

# Install dotfiles
stow bash git ghostty
```

## Fedora Setup

### 1. Enable RPM Fusion

```bash
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

### 2. Install Packages

```bash
sudo dnf install \
  git stow \
  zoxide eza bat fzf starship \
  neovim golang nodejs npm \
  ffmpeg ImageMagick tmux \
  gnupg2 diff-so-fancy \
  ghostty
```

### 3. Nerd Fonts

```bash
sudo dnf copr enable che/nerd-fonts
sudo dnf install nerd-fonts-cascadia-mono
```

### 4. NVM (Node Version Manager)

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc
nvm install 22
```

### 5. NPM Packages

```bash
npm install -g typescript ts-node prettier eslint @anthropic-ai/claude-code
```

### 6. Go Tools

```bash
go install golang.org/x/tools/gopls@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

### 7. LazyVim

```bash
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

## What's Included

### Bash
- History settings (32k lines, append mode)
- Zoxide integration (`z` for smart cd)
- Eza aliases (`ls`, `lt`, `lsa`)
- Git aliases (`g`, `gcm`, `gcam`)
- Utility functions: `del`, `buf`, `compress`, `iso2sd`, `format-drive`
- Media functions: `transcode-video-1080p`, `img2jpg`, `img2png`
- Starship prompt
- fzf integration

### Git
- GPG commit signing
- diff-so-fancy as pager
- Useful aliases (`graph`, `stat`)
- Auto-rebase on pull

### Ghostty
- Monokai Pro Ristretto theme
- CaskaydiaMono Nerd Font
- Block cursor, no blink

## Tools

| Tool | Purpose |
|------|---------|
| `zoxide` | Smart cd with frecency |
| `eza` | Modern ls replacement |
| `bat` | Cat with syntax highlighting |
| `fzf` | Fuzzy finder |
| `starship` | Cross-shell prompt |
| `diff-so-fancy` | Better git diffs |

## GPG Setup for Git Commit Signing

```bash
# Generate key
gpg --full-generate-key

# Get key ID
gpg --list-secret-keys --keyid-format=long

# Set signing key
git config --global user.signingkey YOUR_KEY_ID

# Export for GitHub
gpg --armor --export YOUR_KEY_ID
```

## License

[MIT](LICENSE)
