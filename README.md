<div align="center">

# Pomarchy - Personal Omarchy Setup

**Opinionated customization tool for Omarchy Linux**  
*Omarchy is opinionated Arch/Hyprland setup. Pomarchy is opinionated Omarchy.*

<p align="center">
  <img src="demo/pomarchy-setup.gif" alt="Pomarchy Demo" width="600"/>
</p>

![License:MIT](https://img.shields.io/static/v1?label=License&message=MIT&color=green&style=flat-square)
![Shell](https://img.shields.io/badge/Shell-Bash-green?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Omarchy%20Linux-blue?style=flat-square)

</div>

## Features

- **Modular execution** - Run specific components (packages, dotfiles, devtools, system)
- **Automatic backups** - Creates timestamped backups before making changes
- **Development tools** - Installs Node.js, Go, VS Code extensions, and CLI tools
- **Omarchy integration** - Extends existing Omarchy Linux configuration
- **Command help** - Built-in help system for all commands and subcommands

## Installation

<details>
<summary>Quick Setup (Recommended)</summary>

```bash
git clone https://github.com/papungag/dotfiles.git
cd dotfiles
chmod +x pomarchy
./pomarchy
```

</details>

<details>
<summary>Modular Installation</summary>

```bash
# Install specific components
./pomarchy setup dotfiles    # Dotfiles only
./pomarchy setup packages    # Package management only  
./pomarchy setup system      # System configuration only
./pomarchy setup devtools    # Development tools only
```

</details>

## Usage

**After installation, use from anywhere:**

```bash
# Configure the pomarchy alias in your ~/.bashrc:
# alias pomarchy="/path/to/your/pomarchy/pomarchy"

pomarchy doctor              # Check system status
pomarchy setup packages -y   # Install packages without prompts
pomarchy update              # Update to latest version
pomarchy backups list        # Manage configuration backups
```

**Available commands:**

```bash
pomarchy [command] [options]

Setup Commands:
  setup dotfiles     Install dotfiles configurations
  setup packages     Manage system packages
  setup system       Configure Omarchy system settings
  setup devtools     Setup development environment
  setup all          Run full setup (default)

Utility Commands:
  doctor             Show system status
  backups            Manage system configuration backups
  update             Update Pomarchy to latest version

Options:
  --yes, -y          Skip confirmation prompts
  --help, -h         Show contextual help for any command
```

**Get help for any command:**

```bash
pomarchy --help                  # Show all commands
pomarchy setup --help            # Show setup options
pomarchy setup packages --help   # Show what packages installs
pomarchy backups --help          # Show backup commands
```

## What Pomarchy Installs

<table>
<tr>
<td width="50%">

### Package Management

- **Removes:** Unnecessary software (1password, kdenlive, obsidian, pinta, signal-desktop, typora, spotify)
- **Installs:** Essential tools (Firefox, VS Code, Lite-XL, Go, Node.js v20, atuin, micro, k6, AWS VPN client, Claude Code)
- **Sets:** Firefox as default browser

### Dotfiles

- **Terminal:** Alacritty with Omarchy theme integration, UbuntuMono Nerd Font
- **Editor:** Micro with plugins (fzf, LSP, snippets, bookmarks)
- **Shell:** Clean bash configuration extending Omarchy defaults
- **Stow-based:** Easy installation and management

</td>
<td width="50%">

### System Configuration  

- **Keyboard:** US/Georgian layouts with Alt+Space switching
- **Monitor:** X1 Carbon Gen 13 OLED optimization (2880x1800@120Hz, 2x scaling)
- **Input:** Natural scrolling, 12-hour clock format
- **Touchpad:** Enhanced settings with simultaneous typing support

### Development Environment

- **Node.js:** v20 via NVM with global packages (TypeScript, ESLint, Prettier, Claude Code)
- **Go:** Latest with development tools (gopls, delve, golangci-lint)
- **VS Code:** Extensions for Go, Python, Docker, Terraform, and more
- **Shell:** Enhanced bash with atuin history, custom aliases, improved prompts

</td>
</tr>
</table>

## Examples

```bash
# Full setup with confirmation
pomarchy

# Install specific components
pomarchy setup dotfiles         # Install dotfiles only
pomarchy setup packages --yes   # Install packages without prompts
pomarchy setup devtools         # Setup development environment
pomarchy setup system           # Configure system settings

# System management
pomarchy doctor                 # Check what's installed/configured
pomarchy update                 # Update to latest version

# Backup management
pomarchy backups list           # List available system config backups
pomarchy backups restore        # Restore from backup
pomarchy backups remove         # Remove old backup
```

## Configuration

### Safety Features

- **Automatic backups** with timestamps before making changes
- **Idempotent scripts** - safe to run multiple times
- **Modular execution** - run only what you need
- **Status checking** - verify installation state
- **Backup restoration** - rollback configurations if needed

### Requirements

- **Omarchy Linux** (installed from ISO)
- **yay** (AUR helper, pre-installed in Omarchy)
- **stow** (installed automatically if missing)

### Notes

> **Note:** System configuration changes (keyboard, monitor, Waybar) require Hyprland restart (`Super+Esc` → Relaunch)

- **Steam:** Install via Omarchy menu (`Super + Alt + Space` → Install → Steam) for GPU support
- **Discord/WhatsApp:** Pre-installed as web apps (`Super + Space`)
- **Fingerprint:** Setup via Omarchy menu (`Super + Alt + Space` → Setup → Fingerprint)
- **Micro plugins:** Installed automatically after micro editor setup
- **Claude Code:** Configured with powerline status line

## Troubleshooting

**Stow conflicts with existing dotfiles:**

```bash
# If you get "existing target is not owned by stow" errors
rm ~/.bashrc                    # Remove conflicting file (example)
./pomarchy dotfiles             # Then retry installation
```

Stow conflicts occur when files already exist that aren't managed by stow. Simply remove or backup the conflicting files mentioned in the error message.

## License

This project is licensed under the [MIT License](LICENSE)

<div align="center">

---

*Personal Omarchy customization - adapt for your own setup!*

</div>
