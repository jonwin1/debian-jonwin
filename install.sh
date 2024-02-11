#!/bin/bash
# See LICENSE file for copyright and license details.

username=$(id -u -n 1000)
builddir=$(pwd)

echo "Sudo privileges are required for some operations."
echo "Authenticate if this is okay."

sudo apt update
sudo apt install nala -y
#sudo nala fetch --auto # skip if exsists
sudo nala upgrade -y

sudo nala install -y \
    bluez \
    curl \
    dbus-x11 \
    dunst \
    feh \
    firefox-esr \
    fonts-firacode \
    gimp \
    light \
    network-manager \
    npm \
    picom \
    pipewire \
    pipx \
    texlive-full \
    unclutter-xfixes \
    unzip \
    wget \
    wireplumber \
    x11-xserver-utils \
    xclip \
    xdotool \
    zathura

pipx ensurepath
pipx install pywal

# virtual machines
# sudo nala install -y qemu-system libvirt-daemon-system virt-manager ovmf

function suckless() {
    sudo nala install -y \
        build-essential \
        libx11-dev \
        libxft-dev \
        libxinerama-dev \
        xorg

    cd dwm && sudo make clean install && cd ..
    cd st && sudo make clean install && cd ..
    cd dmenu && sudo make clean install && cd ..
    cd slstatus && sudo make clean install && cd ..
    cd wmname && sudo make clean install && cd ..
    cd $builddir
}

# copy_and_link src_dir dest_dir
# Copy the directory structure and create symbolic links to each file.
function copy_and_link() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 src_dir dest_dir"
        exit 1
    fi

    src_dir="$1"
    dest_dir="$2"

    if [ ! -d "$src_dir" ]; then
        echo "Source directory not found: $src_dir"
        exit 1
    fi

    mkdir -p "$dest_dir"

    find "$src_dir" -type f | while read -r file; do
        rel_path=$(realpath --relative-to="$src_dir" "$file")
        mkdir -p "$dest_dir/$(dirname "$rel_path")"
        ln -sf "$file" "$dest_dir/$rel_path"
        echo "Created symbolic link for $rel_path"
    done
}
copy_and_link "$builddir/dotconfig" "/home/$username/.config"
copy_and_link "$builddir/dotfiles" "/home/$username"

mkdir -p ~/pictures
cp -i bg.jpg ~/pictures/
# crontab background execution of battery alert.
echo "*/1 * * * * export DISPLAY=:0 && /usr/bin/dbus-launch /home/$username/.config/battery-alert.sh" | crontab -u $username -

# TODO
sudo cp -i -r slstatus-scripts/ /

function neovim() {
    sudo nala install -y \
        ninja-build \
        gettext \
        cmake \
        unzip \
        curl \
        python3.11-venv
            sudo nala purge -y nano
            rm -rf ~/.config/nvim
            rm -rf ~/.local/share/nvim
            rm -rf ~/.cache/nvim
            cd neovim 
            make CMAKE_BUILD_TYPE=RelWithDebInfo
            sudo make install
            cd $builddir
            git clone https://github.com/jonwin1/nvim-wincent ~/.config/nvim
}

function kmonad() {
    curl -sSL https://get.haskellstack.org/ | sh
    cd kmonad
    rm -rf .stack-work
    stack build
    sudo cp .stack-work/install/*/*/*/bin/kmonad /usr/local/bin/
    cd $builddir
    sudo groupadd -f uinput
    sudo usermod -aG input $username
    sudo usermod -aG uinput $username
    sudo cp -i configFiles/20-uinput.rules /etc/udev/rules.d/ 
    sudo modprobe uinput
}

echo "Reboot to complete the installation"

