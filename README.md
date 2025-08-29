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

<table>
<tr>
<td width="50%">

### Package Management

- Removes unnecessary software (1password, kdenlive, obsidian)
- Installs essential tools (Firefox, VS Code, Go, Node.js, Claude Code)
- Manages both official and AUR packages seamlessly

### Development Environment

- Node.js v20 with TypeScript, ESLint, Prettier
- Go with language server and development tools  
- VS Code extensions for Go, Python, Docker, Terraform
- Enhanced shell with custom aliases

</td>
<td width="50%">

### System Configuration

- Keyboard layouts (US/Georgian) with Caps Lock switching
- Active keyboard layout display in Waybar with click-to-switch
- X1 Carbon Gen 13 OLED optimization (2880x1800@120Hz)
- Natural scrolling and enhanced touchpad settings
- 12-hour clock format and system theming

### Safety & Flexibility

- **Automatic rollback system** - Failed operations preserve backups for easy restoration
- **Pre-setup validation** - Checks disk space, connectivity, and permissions before changes
- **Targeted backups** - Only backs up files each operation will modify (not entire system)
- **Comprehensive restore** - Handles files, directories, and symlinks with `pomarchy backups restore`
- Modular execution - run only what you need
- Configurable via simple key=value files
- Idempotent - safe to run multiple times

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
./pomarchy setup dotfiles        # Terminal configs, micro editor, themes
./pomarchy setup packages        # System packages and applications
./pomarchy setup system          # Keyboard, monitor, input settings
./pomarchy setup devtools        # Node.js, Go, VS Code extensions
./pomarchy setup theme           # Install omarchy themes
```

## Usage

| Command | Description |
|---------|-------------|
| `pomarchy` | Full setup (dotfiles, packages, system, devtools, theme) |
| `pomarchy doctor` | Show system status and installed components |
| `pomarchy setup [component]` | Install specific component |
| `pomarchy backups list` | List available configuration backups |
| `pomarchy backups restore` | Restore from backup |
| `pomarchy update` | Update Pomarchy to latest version |

**Examples:**

```bash
# Install packages without confirmation prompts
pomarchy setup packages --yes

# Install custom theme from GitHub
pomarchy setup theme https://github.com/user/theme.git

# Check what's installed and configured
pomarchy doctor

# Restore previous configuration if needed
pomarchy backups restore
```

## Configuration

Pomarchy uses a simple configuration system with sensible defaults. The configuration is automatically installed when you include "pomarchy" in your DOTFILES setting.

**Default configuration:** `config/pomarchy/.config/pomarchy/pomarchy.conf`

**Customize your setup:**

```bash
# Edit user configuration (overrides defaults)
~/.config/pomarchy/pomarchy.conf
```

**Key configuration options:**

```bash
# Skip components by setting to empty
DOTFILES=""                      # Skip dotfiles installation
NODEJS_VERSION=""                # Skip Node.js setup

# Customize package lists  
PACKAGES_INSTALL="firefox code"  # Only install specific packages
THEME="https://github.com/user/custom-theme.git"  # Custom theme

# System settings
KEYBOARD_LAYOUTS="us,de"         # Different keyboard layouts
CLOCK_FORMAT="24h"               # Use 24-hour clock

# System paths (advanced)
NVM_INIT_PATH="/usr/share/nvm/init-nvm.sh"  # NVM initialization script path
BACKUP_BASE_PATH="$HOME/.config/omarchy-backups"  # Backup directory
TRASH_PATH="/tmp/.trash"         # Trash directory for del() function
```

**Configuration rules:**

- Empty values skip that component entirely
- User config overrides defaults  
- Command-line arguments override config values
- Space-separated lists for multiple items
- Config validation prevents invalid formats (monitor resolution, clock format, etc.)

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
- **Micro plugins:** Installed automatically after micro editor setup
- **Claude Code:** Configured with enhanced status line
- **Themes:** Default midnight theme, custom GitHub URLs supported
- **Configurable paths:** NVM, backup directory, and trash paths can be customized in config

## Troubleshooting

**Stow conflicts with existing files:**

```bash
# Remove conflicting files mentioned in error message
rm ~/.bashrc ~/.config/alacritty/alacritty.toml
pomarchy setup dotfiles
```

**Configuration not taking effect:**

```bash
# Ensure configuration is properly formatted
cat ~/.config/pomarchy/pomarchy.conf

# Check for bash syntax errors (no spaces around = in variable assignments)
PACKAGES_INSTALL="firefox code"    # Correct - no spaces around =
PACKAGES_INSTALL = "firefox code"  # Wrong - spaces make this a command, not assignment
```

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
make clean     # Clean test artifacts
```

### Testing

Tests use bats-core framework with isolated test environments. Coverage includes command help, basic functionality, and some error conditions.

### Contributing

1. Install dependencies: `make install`
2. Make your changes
3. Run lint and tests: `make lint && make test`
4. Ensure all checks pass

## License

This project is licensed under the [MIT License](LICENSE)

<div align="center">

---

*Personal Omarchy customization - adapt for your own setup!*

</div>
