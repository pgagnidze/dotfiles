<div align="center">

# Pomarchy - Personal Omarchy Setup

**Opinionated customization tool for Omarchy Linux**  
*Omarchy is opinionated Arch/Hyprland setup. Pomarchy is opinionated Omarchy.*

<p align="center">
  <img src="demo/demo.gif" alt="Pomarchy Demo" width="600"/>
</p>

![License:MIT](https://img.shields.io/static/v1?label=License&message=MIT&color=green&style=flat-square)
![Shell](https://img.shields.io/badge/Shell-Bash-green?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Omarchy%20Linux-blue?style=flat-square)

</div>

## Features

<table>
<tr>
<td width="50%">

**Package & Development Environment**

Removes unwanted software and installs essential tools (Firefox, Go, Node.js, Claude Code). Node.js v20 with TypeScript, ESLint, Prettier. Go with language server and development tools.

</td>
<td width="50%">

**System Configuration**

Multi-language keyboard layouts with Caps Lock switching. Active layout display in Waybar with click-to-switch. Monitor resolution and scaling optimization.

</td>
</tr>
<tr>
<td width="50%">

**Automatic Rollback System**

Failed operations preserve backups for easy restoration. Targeted backups only save files each operation modifies. Backup manifest tracks exactly what changed.

</td>
<td width="50%">

**Modular & Configurable**

Run only what you need via `pomarchy setup [component]`. Simple INI configuration with git config backend. Smart theme management from GitHub URLs.

</td>
</tr>
</table>

## Installation

**Quick Setup (Recommended):**

```bash
git clone https://github.com/papungag/dotfiles.git
cd dotfiles
chmod +x pomarchy
./pomarchy                       # Full setup with confirmation
```

**Modular Installation:**

```bash
./pomarchy setup dotfiles        # Terminal and shell configs
./pomarchy setup packages        # System packages and applications
./pomarchy setup system          # Keyboard, monitor, input settings
./pomarchy setup devtools        # Node.js, Go development tools
```

## Usage

| Command | Description |
|---------|-------------|
| `pomarchy` | Full setup (dotfiles, packages, system, devtools) |
| `pomarchy doctor` | Show system status and installed components |
| `pomarchy setup [component]` | Install specific component |
| `pomarchy theme list` | List installed themes |
| `pomarchy theme use <name\|url>` | Install or activate theme |
| `pomarchy backups list` | List available configuration backups |
| `pomarchy backups restore` | Restore from backup |
| `pomarchy update` | Update Pomarchy to latest version |

**Examples:**

```bash
# Install packages without confirmation prompts
pomarchy setup packages --yes

# List and manage themes
pomarchy theme list
pomarchy theme use gruvbox                    # Activate installed theme
pomarchy theme use https://github.com/user/theme.git  # Install from GitHub

# Check what's installed and configured
pomarchy doctor

# Restore previous configuration if needed
pomarchy backups restore
```

## Configuration

Pomarchy uses a simple configuration system with sensible defaults. The configuration is automatically installed when you include "pomarchy" in your DOTFILES setting.

**Default configuration:** `config/pomarchy/.config/pomarchy/pomarchy.ini`

**Customize your setup:**

```bash
# Edit user configuration (overrides defaults)
~/.config/pomarchy/pomarchy.ini
```

**Configuration format:**

Pomarchy uses a secure INI-style configuration organized by setup commands. Each section corresponds to a `pomarchy setup` command:

```ini
[theme]
 name = midnight

[dotfiles]
 enabled = bash alacritty pomarchy git

[packages]
 remove = 1password-beta 1password-cli kdenlive obsidian pinta signal-desktop typora spotify
 install = firefox lua go awsvpnclient k6-bin

[system]
 keyboard-layouts = us,ge
 monitor-resolution = 2880x1800@120
 monitor-scale = 2
 natural-scroll = true
 disable-while-typing = false
 clock-format = 12h
 default-browser = firefox

[devtools]
 nodejs-version = 20
 npm-packages = typescript ts-node prettier eslint @anthropic-ai/claude-code
 go-tools = golang.org/x/tools/gopls@latest github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

**Section mapping:**

- `[theme]` → `pomarchy theme` commands
- `[dotfiles]` → `pomarchy setup dotfiles`
- `[packages]` → `pomarchy setup packages`
- `[system]` → `pomarchy setup system`
- `[devtools]` → `pomarchy setup devtools`

**Configuration features:**

- **Secure**: Git config backend prevents code execution vulnerabilities
- **Organized**: Sections match setup commands for easy navigation
- **Override hierarchy**: User config → Default config
- **Empty values**: Skip components by setting empty values (`key =`)
- **Space-separated lists**: Multiple items separated by spaces
- **Built-in validation**: Monitor resolution, clock format, etc.

**Additional features:**

- **Automatic pomarchy alias:** Detects installation path and creates global alias
- **Config validation:** Validates monitor resolution, scale, and clock format on startup
- **Enhanced error handling:** Comprehensive error trapping with automatic backup preservation on failure
- **Backup manifest system:** Tracks exactly which files were backed up for precise restoration

## Requirements

- **Omarchy Linux** (installed from ISO)
- **yay** (AUR helper, pre-installed in Omarchy)  
- **stow** (installed automatically if missing)

## Notes

> **System changes require Hyprland restart:** `Super+Esc` → Relaunch

- **Steam:** Install via Omarchy menu for GPU support
- **Neovim:** Pre-installed with Omarchy - configure as needed
- **Claude Code:** Configured with enhanced status line
- **Themes:** Smart theme management - install from URLs or activate installed themes

<details>
<summary><strong>GPG Setup for Git Commit Signing</strong></summary>

Pomarchy includes a comprehensive Git configuration with commit signing enabled. To set up GPG for signed commits:

### Generate a GPG Key

```bash
# Generate a new GPG key
gpg --full-generate-key

# Follow the prompts and use default settings unless you have specific requirements
# Enter your name and email (must match your Git config)
```

### Configure Git with Your GPG Key

```bash
# List your GPG keys to get the key ID
gpg --list-secret-keys --keyid-format=long

# Copy the long key ID (between sec and uid sections)

# Set your signing key in Git
git config --global user.signingkey YOUR_KEY_ID

# Enable commit signing (already enabled in Pomarchy's .gitconfig)
git config --global commit.gpgsign true
```

### Add GPG Key to GitHub

```bash
# Export your public key
gpg --armor --export YOUR_KEY_ID

# Copy the output and add it to GitHub:
# Settings → SSH and GPG keys → New GPG key
```

</details>

## Troubleshooting

**Stow conflicts with existing files:**

```bash
# Remove conflicting files mentioned in error message
rm ~/.bashrc ~/.config/alacritty/alacritty.toml
pomarchy setup dotfiles
```

**Configuration not taking effect:**

```bash
# Check your configuration file
cat ~/.config/pomarchy/pomarchy.ini

# Edit configuration with any text editor
nano ~/.config/pomarchy/pomarchy.ini

# Or use git config command for individual settings
git config -f ~/.config/pomarchy/pomarchy.ini packages.install "firefox code vim"
git config -f ~/.config/pomarchy/pomarchy.ini system.clock-format "24h"
```

**Configuration troubleshooting:**

- Ensure INI format with `[sections]` and `key = value` pairs
- Use tabs or spaces for indentation (git config handles both)
- Empty values should be `key =` (space after equals)
- Check syntax with `git config -f ~/.config/pomarchy/pomarchy.ini --list`

## Local Development

### Prerequisites

```bash
make install
```

### Commands

```bash
make help      # Show available commands
make lint      # Run shellcheck on all scripts
make test      # Run all tests
make format    # Format bash scripts with shfmt
make clean     # Clean test artifacts
```

### Testing

Tests use bats-core framework with isolated test environments. Coverage includes command help, basic functionality, and some error conditions.

### Contributing

1. Install dependencies: `make install`
2. Make your changes
3. Run format, lint and tests: `make format && make lint && make test`
4. Ensure all checks pass

## Acknowledgments

Git configuration inspired by [micahkepe](https://github.com/micahkepe)'s dotfiles.

## License

This project is licensed under the [MIT License](LICENSE)

<div align="center">

---

*Personal Omarchy customization - adapt for your own setup!*

</div>
