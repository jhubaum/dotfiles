# There probably is a better way to comment what each package is required for, but current me
# (past me when I'm reading this) doesn't want to spend any time on this.

EXTERNAL_CONFIG_PATH="$(dirname $0)/configs"

# window manager and dependencies
sudo apt install -y \
    i3 suckless-tools x-window-system scrot feh rofi xcompmgr imagemagick redshift \
    pulseaudio pavucontrol \
    ntfs-3g

# copy x configs to their correct places
echo "Copy X config files to the system"
sudo cp "$EXTERNAL_CONFIG_PATH/00-keyboard.conf" /etc/X11/xorg.conf.d


# restart pulseaudio for pavucontrol to work correctly
systemctl --user restart pulseaudio.service

# build systems and general utilities
sudo apt install -y \
    git curl build-essential cmake python3 libnotify-bin

# rust / cargo
# https://www.rust-lang.org/tools/install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# rust tools
rustup component add rls rust-analysis rust-src

# dependencies to build alacritty
sudo apt install -y \
	pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev

cargo install ripgrep # better grep
cargo install alacritty # terminal emulator

# setup zsh
sudo apt-get install zsh
curl -L git.io/antigen > antigen.zsh
echo "Changing default shell to zsh"
chsh -s $(which zsh)

# user-facing tools
sudo apt install -y \
    firefox-esr thunderbird flameshot taskwarrior vlc nextcloud-desktop \
    keepassxc telegram-desktop
