# Introduction

Please backup configurations or use a testing user before applying these changes to your main user.

## Installation

1. Clone this repository
   * ``` git clone https://github.com/papungag/dotfiles ```
2. Change directory to ```dotfiles```
   * ``` cd dotfiles ```
3. Install with stow

```bash
    stow -S bash        # Install bash configurations
    stow -D bash        # Uninstall bash configurations
```

### Micro

Install required dependencies:

```bash
brew install fzf
```

After installing micro configuration, run the plugin installer:

```bash
~/.config/micro/plugins.sh
```

### Alacritty Terminal Setup

Install the required Nerd Font:

```bash
brew install --cask font-ubuntu-mono-nerd-font
```

## Credits

[copycat-killer](https://github.com/lcpz)

[helmuthdu](https://github.com/helmuthdu)

[zanshin](https://github.com/zanshin)

[gpakosz](https://github.com/gpakosz)
