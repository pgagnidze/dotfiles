# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

```bash
git clone https://github.com/pgagnidze/pomarchy.git ~/dotfiles
cd ~/dotfiles
./bin/install-dotfiles
```

## Setup

### 1. Packages

Install using your package manager:
- `stow`, `zoxide`, `fzf`, `neovim`, `lua`, `diff-so-fancy`, `ghostty`

Install Nerd Fonts:

```bash
./bin/install-nerd-fonts
```

### 2. Node

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc
nvm install 22
npm install -g typescript ts-node prettier eslint @anthropic-ai/claude-code
```

### 3. LazyVim

```bash
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

### 4. Git Setup

**SSH Key** (authentication):

```bash
./bin/setup-ssh your_email@example.com
```

Add to [GitHub SSH keys](https://github.com/settings/keys).

**GPG Key** (commit signing):

```bash
gpg --full-generate-key
gpg --list-secret-keys --keyid-format=long
```

Copy your key ID (hex string after `rsa4096/`), update `git/.gitconfig`:

```
[user]
    signingkey = YOUR_KEY_ID
```

Export and add to [GitHub GPG keys](https://github.com/settings/keys):

```bash
gpg --armor --export YOUR_KEY_ID
```

## System Settings

- Dark mode, darker colours
- Keyboard: US, Georgian
- Display: 2880x1800@120, scale 2
- Natural scroll, disable-while-typing off
- 12-hour clock, metric system
- Fingerprint, Gmail account

## License

[MIT](LICENSE)
