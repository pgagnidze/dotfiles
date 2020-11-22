### Introduction
Bits of these dots are collected from the arch linux community. I might have forgotten to mention someone I stole from in credits. If you recognize your or someone's handwriting, remind me to add on the list. For now, Backup your configs or create a new user to test before use.

### Installation
1. Clone this repository
   * ``` git clone https://github.com/papungag/dotfiles ```
2. Change directory to ```dotfiles```
   * ``` cd dotfiles ```
3. Install with stow
```bash
    $ stow bash        # Install bash configurations
    $ stow -D bash     # Uninstall bash configurations
```
Awesome WM theme is not maintained anymore, please refer to https://github.com/lcpz/awesome-copycats for up-to-date themes.

### Screenshot

![clean](https://u.teknik.io/E9W7x.png)

### Credits
[copycat-killer] for [rc.lua.template.afde62a] and [lain.133fe63]

[helmuthdu] for [.bashrc.0140a69]

[timss] for [.vimrc.06ade84]

[zanshin] for [.tmux.linux.5b3c864]

[copycat-killer]: https://github.com/lcpz
[rc.lua.template.afde62a]: https://raw.githubusercontent.com/lcpz/awesome-copycats/afde62ab4b548d1e5ed1c4ce2457333b2d8d3375/rc.lua.template
[lain.133fe63]: https://github.com/lcpz/lain/tree/133fe63b85978ac1f21658c5decd66e269261e60

[helmuthdu]: https://github.com/helmuthdu
[.bashrc.0140a69]: https://raw.githubusercontent.com/helmuthdu/dotfiles/0140a69c037092711d10a9d035eb435f273fcf80/.bashrc

[timss]: https://github.com/timss
[.vimrc.06ade84]: https://raw.githubusercontent.com/timss/vimconf/06ade840bdf7012966b7388015477c5f1c991dcb/.vimrc

[zanshin]: https://github.com/zanshin
[.tmux.linux.5b3c864]: https://raw.githubusercontent.com/zanshin/dotfiles/5b3c8640b5a2c895a7d5d16aa0162ceaee0db821/tmux/tmux.linux