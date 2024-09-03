#!/usr/bin/env bash
source ./utilities.sh

cp -r ./Apps_Icons/ ~/Documents/
mkdir ~/Documents/Program_Files/

curl -L https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.2_Linux_64bit.AppImage -o ~/Documents/Program_Files/arduino-ide_2.3.2_Linux_64bit.AppImage
sudo chmod +x ~/Documents/Program_Files/arduino-ide_2.3.2_Linux_64bit.AppImage
cp ./arduino_ide_v2.desktop ~/.local/share/applications/

sudo usermod -aG uucp $(whoami)
