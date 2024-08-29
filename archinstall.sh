#!/usr/bin/env bash

clear

echo "(1) Live Arch Linux Kernel"
echo "(2) Chroot mode"
echo "(3) GUI Mode (After install basic arch linux"

STEP=1

echo "Enter your step: "
read STEP

if [[ $STEP = 1 ]]; then

  DRIVE=""
  while [[ ! $(blkid | grep $DRIVE) || ! $(fdisk -l $DRIVE) ]]; do
    clear
    echo "Please enter your drive: "
    read DRIVE
  done

  function print_drive() {
    echo "---------------------------------------------------------"
    echo $'\n           THIS IS THE DRIVE DETAIL \n'
    fdisk -l $DRIVE
    echo $'\n---------------------------------------------------------'
  }

  function print_lsblk() {
    echo "---------------------------------------------------------"
    echo $'\n           THIS IS THE DRIVE DETAIL \n'
    lsblk $DRIVE
    echo $'\n---------------------------------------------------------'
  }

  function print_esp() {
    echo "EFI: partition: $EFI"
  }

  function print_boot() {
    echo "BOOT partition: $BOOT"
  }

  function print_root() {
    echo "ROOT partition: $ROOT"
  }

  function print_home() {
    echo "HOME partition: $HOME"
  }

  function print_data() {
    echo "DATA partition: $DATA"
  }

  function print_swap() {
    echo "SWAP AREA: $SWAP"
  }

  print_lsblk

  while [[ ! $EFI =~ $DRIVE ]]; do
    echo "Please enter EFI partition: (example /dev/sda1 or /dev/nvme0n1p1)"
    read EFI
    #  echo "This partition is not in the selected drive"
  done

  while [[ ! $BOOT =~ $DRIVE ]]; do
    echo "Please enter boot partition: (example /dev/sda1 or /dev/nvme0n1p1)"
    read BOOT
    #  echo "This partition is not in the selected drive"
  done

  while [[ ! $SWAP =~ $DRIVE ]]; do
    echo "Please enter swap partition: (example /dev/sda1 or /dev/nvme0n1p1)"
    read SWAP
    # echo "This partition is not in the selected drive"
  done

  while [[ ! $ROOT =~ 'lv_root' ]]; do
    echo "Please enter root partition: (example /dev/sda1 or /dev/nvme0n1p1)"
    read ROOT
    #echo "This partition is not in the selected drive"
  done

  while [[ ! $HOME =~ 'lv_home' ]]; do
    echo "Please enter home partition: (example /dev/sda1 or /dev/nvme0n1p1)"
    read HOME
    #echo "This partition is not in the selected drive"
  done

  while [[ ! $DATA =~ 'lv_data' ]]; do
    echo "Please enter data partition: (example /dev/sda1 or /dev/nvme0n1p1)"
    read DATA
    #echo "This partition is not in the selected drive"
  done

  # Summary the partition table
  clear
  echo $'THE SELECTED PARTITIONS\n\n'
  print_drive
  print_esp
  print_boot
  print_swap
  print_root
  print_home
  print_data

  echo $'\n\n-------------------------------------------------------------------'

  echo "Press Enter to continue..."
  read

  echo "Do you want to format /data partition? [y/n]"
  read FORMAT_DATA

  # Format partition for installation
  mkfs.fat -F32 $EFI
  mkfs.ext4 $BOOT
  mkswap $SWAP
  mkfs.ext4 $ROOT
  mkfs.ext4 $HOME

  if [[ $FORMAT_DATA = 'y' ]]; then
    mkfs.ext4 $DATA
  fi

  # Mount the partition into /mnt directory
  mount $ROOT /mnt
  mkdir /mnt/efi
  mkdir /mnt/boot
  mkdir /mnt/home
  mkdir /mnt/data

  mount $EFI /mnt/efi
  mount $BOOT /mnt/boot
  mount $HOME /mnt/home
  mount $DATA /mnt/data
  swapon $SWAP

  clear
  echo "This is a partition table"
  print_lsblk
  echo "Press Enter to continue"
  read

  # Initialation and install essential packages

  pacstrap -K /mnt base linux linux-firmware linux-headers base-devel dosfstools grub efibootmgr gnome gnome-tweaks lvm2 mtools nano networkmanager openssh os-prober sudo man intel-ucode bluez bluez-utils sof-firmware git htop neofetch firefox-developer-edition libreoffice-fresh gnome-extra gnome-browser-connector timeshift ranger fzf networkmanager-openvpn network-manager-applet subversion xclip terminus-font

  # linux-lts linux-lts-headers

  # Generate the file system UUID file
  echo "Generate the file system UUID file"
  echo "Press Enter to continue"
  read
  genfstab -U /mnt >>/mnt/etc/fstab

  echo "The detail fstab file"
  cat "/mnt/etc/fstab"

  cp archinstall.sh /mnt
  # Change root into /mnt directory
  echo "Run arch-chroot"
  echo "Press Enter to continue ..."
  read
  arch-chroot /mnt

elif [[ $STEP = 2 ]]; then

  # Setup root password
  echo "Enter root password: "
  passwd

  echo "Add your user: "
  read USER
  useradd -m -g users -G wheel $USER
  echo "Enter your user password"
  passwd $USER

  # Set timezone
  echo "Set the timezone: "

  ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime

  hwclock --systohc

  # Edit your locale.gen file
  echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen
  locale-gen

  echo LANG=en_US.UTF-8 >>/etc/locale.conf
  # Set hostname
  echo arch >>/etc/hostname

  # Install GPU driver
  pacman -Syu --needed mesa intel-media-driver dkms nvidia-dkms xorg xorg-apps xorg-server xorg-xinit nvidia-utils nvidia-settings

  # Edit mkinitcpio.conf file
  echo "Edit the mkinitcpio.conf file, add some hooks into file such as encrypt, lvm2,..."
  echo "Press Enter to continue..."
  read

  nano /etc/mkinitcpio.conf

  echo "Compile mkinitcpio.conf file for linux and linux-lts kernel"

  mkinitcpio -p linux

  # mkinitcpio -p linux-lts

  # Install GRUB and config it

  echo "Edit grub file (/etc/default/grub), set some kernel parameter such as cryptdevice, root"

  blkid | grep -e "crypto_LUKS" -e "/vg0-lv_root" >>/etc/default/grub

  echo "Edit /etc/default/grub"
  echo "Press Enter to continue..."
  read

  # Edit grub file
  nano /etc/default/grub

  grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=grub_uefi --recheck

  cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo

  # Grub config
  grub-mkconfig -o /boot/grub/grub.cfg

  systemctl enable sshd gdm NetworkManager bluetooth

  # Edit sudoer file

  echo "Edit sudoer file (wheel group)"
  echo "Press Enter to continue..."
  read

  nano /etc/sudoers

  sudo chgrp -R wheel /data
  sudo chmod -R g+rwx /data

  #echo "file:///data Data" >>/home/tam/.config/gtk-3.0/bookmarks

  echo 'ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp wheel $sys$devpath/brightness", RUN+="/bin/chmod g+w $sys$devpath/brightness"' >>/etc/udev/rules.d/backlight.rules

  echo "Do you want reboot now? [y/n]"
  read REBOOT
  if [[ $REBOOT = 'y' ]]; then
    exit
    umount -a
    reboot
  fi

else
  clear

  echo "You must copy this installation file into ~/ directory before run it"
  if [[ $(whoami) = 'root' ]]; then
    RED='\033[0;31m'
    echo -e "${RED}You can't run this section as root!"
    exit
  fi

  echo "(1) Install normal packages"
  echo "(2) Install zsh"
  echo "(3) Install oh-my-zsh"
  echo "Enter your choice"
  read CHOICE
  # Move to /tmp directory
  cd /tmp

  if [[ $CHOICE = 1 ]]; then
    # Install yay
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si

    # Install fonts
    sudo pacman -S --needed nerd-fonts
    sudo pacman -S --needed noto-fonts ttf-roboto adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts
    sudo pacman -S --needed noto-fonts-cjk noto-fonts-emoji
    sudo pacman -S --needed ttf-ubuntu-font-family
    yay -S ttf-google-fonts-git
    sudo pacman -S --needed gnu-free-fonts gsfonts tex-gyre-fonts
    sudo pacman -S --needed ttf-dejavu
    sudo pacman -S --needed ttf-droid ttf-opensans
    sudo pacman -S --needed ttf-liberation ttf-croscore
    # libreoffice fonts
    sudo pacman -S --needed ttf-caladea ttf-carlito ttf-dejavu ttf-liberation ttf-linux-libertine-g adobe-source-code-pro-fonts adobe-source-sans-fonts adobe-source-serif-fonts
    yay -S ttf-gentium-basic
    yay -S ttf-google-fonts-git
    sudo pacman -S --needed xorg-fonts-encodings xorg-fonts-misc xorg-fonts-type1 xorg-font-util

    yay -S apple-fonts

    # Install web browser
    yay -S google-chrome
    yay -S opera

    # Install vscode
    yay -S visual-studio-code-bin

    # Install microsoft fonts
    yay -S ttf-ms-win11-auto ttf-ms-win10-auto

    # Install flat-remix theme
    yay -S flat-remix

    # Install ulauncher
    git clone https://aur.archlinux.org/ulauncher.git && cd ulauncher && makepkg -is

    # Install obs-studio
    sudo pacman -S obs-studio

    # Install flatpak
    sudo pacman -S flatpak

    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    # Install docker
    sudo pacman -S docker docker-compose docker-buildx
    sudo systemctl enable docker.service
    sudo usermod -aG docker $(whoami)

    # Install neovim
    sudo pacman -S --needed base-devel cmake unzip ninja curl
    cd /tmp
    git clone https://github.com/neovim/neovim
    cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make install

    # Install LazyVim
    git clone https://github.com/LazyVim/starter ~/.config/nvim

    rm -rf ~/.config/nvim/.git

    # Add /data partition into File Manager (nautilus) category
    echo "file:///data Data" >>/home/tam/.config/gtk-3.0/bookmarks

    # Install Node Version Manager
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

    # Install VirtualBox
    sudo pacman -S virtualbox virtualbox-guest-iso

    yay -S virtualbox-ext-oracle

    sudo usermod -aG vboxusers $(whoami)

    # Install ibus-bamboo
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/BambooEngine/ibus-bamboo/master/archlinux/install.sh)"

  # Install GNOME EXTENSIONS
  elif [[ $CHOICE = 2 ]]; then
    # Install zsh
    sudo pacman -S zsh
    zsh --version
    chsh -s $(which zsh)
  else
    # Install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # Install zsh plugins
    # Install fzf plugin
    sudo pacman -S --needed fzf

    # Install zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    # Install zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    # Install you-should-use
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git $ZSH_CUSTOM/plugins/you-should-use

    echo "Add these plugins into ~/.zshrc file command-not-found 
  fzf zsh-autosuggestions zsh-syntax-highlighting you-should-use"
    echo "Press Enter to continue..."
    read

    echo "command-not-found
  fzf
  zsh-autosuggestions
  zsh-syntax-highlighting
  you-should-use" >>~/.zshrc
    nano ~/.zshrc

  fi

  # After install above essential packages. You have to install Lavanda-Sea and Lavanda-Sea-Light theme
  # Config git ssh
  # Install Arduino IDE (make dir contain icons such as ~/Documents/Apps_Icons/arduino_ide.png and a dir contain program bin file ~/Documents/Program_Files/arduino-ide_2.3.2_Linux_64bit.AppImage)
  # Install Gnome Extensions
  # Change gnome extension properties: burn my windows, dash to dock, ddterm, logo menu, wiggle
  # Change icons and themes

fi
