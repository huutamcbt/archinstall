#!/usr/bin/env bash

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
    echo "HOME partition: $DATA"
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

  pacstrap -K /mnt base linux linux-firmware linux-headers base-devel dosfstools grub efibootmgr gnome gnome-tweaks lvm2 mtools nano networkmanager openssh os-prober sudo man intel-ucode bluez bluez-utils sof-firmware git htop neofetch firefox-developer-edition libreoffice-fresh gnome-extra gnome-browser-connector

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
  # Install yay
  sudo pacman -S --needed git base-devel
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si

  yay -S google-chrome

  # Install vscode
  yay -S visual-studio-code-bin

  # Install microsoft fonts
  yay -S ttf-ms-win11-auto ttf-ms-win10-auto

  # Install flat-remix theme
  yay -S flat-remix

  # Install ulauncher
  git clone https://aur.archlinux.org/ulauncher.git && cd ulauncher && makepkg -is

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

  # Install lazyvim
  git clone https://github.com/LazyVim/starter ~/.config/nvim

  rm -rf ~/.config/nvim/.git

fi
