#!/usr/bin/env bash

clear

echo "(1) Live Arch Linux Kernel"
echo "(2) Chroot mode"
echo "(3) GUI Mode (After install basic arch linux"

STEP=1

echo "Enter your step: "
read STEP

if [[ $STEP = 1 ]]; then
  source ./live_arch.sh
  source ./chroot_mode.sh

elif [[ $STEP = 2 ]]; then

elif [[ $STEP = 3 ]]; then
  source ./user_mode.sh

  # After install above essential packages. You have to install Lavanda-Sea and Lavanda-Sea-Light theme
  # Config git ssh
  # Install Arduino IDE (make dir contain icons such as ~/Documents/Apps_Icons/arduino_ide.png and a dir contain program bin file ~/Documents/Program_Files/arduino-ide_2.3.2_Linux_64bit.AppImage)
  # Install Gnome Extensions
  # Change gnome extension properties: burn my windows, dash to dock, ddterm, logo menu, wiggle
  # Change icons and themes

else
  echo "Nothing to do"

fi
