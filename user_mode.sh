source ./utilities.sh
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
  sudo pacman -S --noconfirm --needed git base-devel
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si

  # Update with yay
  yay -Syu

  # Install fonts
  sudo pacman -S --noconfirm --needed nerd-fonts
  sudo pacman -S --needed --noconfirm noto-fonts ttf-roboto adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts
  sudo pacman -S --needed --noconfirm noto-fonts-cjk noto-fonts-emoji
  sudo pacman -S --needed --noconfirm ttf-ubuntu-font-family
  yay -S --needed --noconfirm ttf-google-fonts-git
  sudo pacman -S --needed --noconfirm gnu-free-fonts gsfonts tex-gyre-fonts
  sudo pacman -S --needed --noconfirm ttf-dejavu
  sudo pacman -S --needed --noconfirm ttf-droid ttf-opensans
  sudo pacman -S --needed --noconfirm ttf-liberation ttf-croscore
  # libreoffice fonts
  sudo pacman -S --needed --noconfirm ttf-caladea ttf-carlito ttf-dejavu ttf-liberation ttf-linux-libertine-g adobe-source-code-pro-fonts adobe-source-sans-fonts adobe-source-serif-fonts
  yay -S --needed --noconfirm ttf-gentium-basic
  yay -S --needed --noconfirm ttf-google-fonts-git
  sudo pacman -S --needed --noconfirm xorg-fonts-encodings xorg-fonts-misc xorg-fonts-type1 xorg-font-util

  # Install antivirus
  sudo pacman -S --needed --noconfirm clamav

  # Install image editor
  sudo pacman -S --needed --noconfirm gimp

  yay -S --needed --noconfirm apple-fonts

  # Install web browser
  yay -S --needed --noconfirm google-chrome
  yay -S --needed --noconfirm opera

  # Install vscode
  yay -S --needed --noconfirm visual-studio-code-bin

  # Install microsoft fonts
  yay -S --needed --noconfirm ttf-ms-win11-auto ttf-ms-win10-auto

  # Install flat-remix theme
  yay -S --needed --noconfirm flat-remix

  sudo pacman -S --needed --noconfirm papirus-icon-theme
  yay -S --needed --noconfirm fluent-icon-theme-git
  yay -S --needed --noconfirm kora-icon-theme

  # Install ulauncher
  git clone https://aur.archlinux.org/ulauncher.git && cd ulauncher && makepkg -is

  # Install obs-studio
  sudo pacman -S --needed --noconfirm obs-studio

  # Install flatpak
  sudo pacman -S --needed --noconfirm flatpak

  flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo

  # Install docker
  sudo pacman -S --needed --noconfirm docker docker-compose docker-buildx
  sudo systemctl enable docker.service
  sudo usermod -aG docker $(whoami)

  # Install neovim
  sudo pacman -S --needed --noconfirm base-devel cmake unzip ninja curl
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
  sudo pacman -S --needed --noconfirm virtualbox virtualbox-guest-iso

  yay -S --needed --noconfirm virtualbox-ext-oracle

  sudo usermod -aG vboxusers $(whoami)

  # Install ibus-bamboo
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/BambooEngine/ibus-bamboo/master/archlinux/install.sh)"

  # Install arduino ide
  cp -r ./Apps_Icons/ ~/Documents/
  cp ~/Documents/Program_Files/

  curl -L https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.2_Linux_64bit.AppImage -o ~/Documents/Program_Files/arduino-ide_2.3.2_Linux_64bit.AppImage
  sudo chmod +x arduino-ide_2.3.2_Linux_64bit.AppImage
  cp ./arduino_ide_v2.desktop ~/.local/share/applications/

  sudo usermod -aG uucp $(whoami)

  # Install Lavanda theme
  # Install Colloid icon
  git clone https://github.com/vinceliuice/Colloid-icon-theme.git
  cd Colloid-icon-theme
  ./install.sh

  git clone https://github.com/vinceliuice/Lavanda-gtk-theme.git
  sudo pacman -S --needed --noconfirm gtk-engine-murrine sassc

  cd wallpaper
  sudo ./install-gnome-backgrounds.sh
  cd ..
  ./install.sh

  # Install GNOME EXTENSIONS

  # # Install blur my shell
  # git clone https://github.com/aunetx/blur-my-shell
  # cd blur-my-shell
  # make install
  # gnome-extensions enable blur-my-shell@aunetx
  #
  # # Install Burn my windows
  # git clone https://github.com/Schneegans/Burn-My-Windows.git
  # cd Burn-My-Windows
  # make install
  # gnome-extensions enable burn-my-windows@schneegans.github.com
  # # Install Caffeine
  # git clone https://github.com/eonpatapon/gnome-shell-extension-caffeine.git
  # cd gnome-shell-extension-caffeine
  # make build
  # make install
  # gnome-extensions enable caffeine@patapon.info
  # # Install Clipboard Indicator
  # git clone https://github.com/Tudmotu/gnome-shell-extension-clipboard-indicator.git ~/.local/share/gnome-shell/extensions/clipboard-indicator@tudmotu.com
  # gnome-extensions enable clipboard-indicator@tudmotu.com
  # # Install color picker
  # git clone --recurse-submodules https://github.com/tuberry/color-picker.git && cd color-picker
  # meson setup build && meson install -C build
  # gnome-extensions enable color-picker@tuberry
  # # meson setup build -Dtarget=system && meson install -C build # system-wide, default --prefix=/usr/local
  # # Install compact top bar
  # git clone https://aur.archlinux.org/gnome-shell-extension-compact-top-bar && cd gnome-shell-extension-compact-top-bar && makepkg -sfri
  # gnome-extensions enable gnome-compact-top-bar@metehan-arslan.github.io

  # Install firmware
  yay -S --needed --noconfirm ast-firmware aic94xx-firmware wd719x-firmware upd72020x-fw
  sudo mkinitcpio -P

  custom_reboot

elif [[ $CHOICE = 2 ]]; then
  # Install zsh
  sudo pacman -S --needed --noconfirm zsh
  zsh --version
  chsh -s $(which zsh)

  # Reboot
  custom_reboot

elif [[ $CHOICE = 3 ]]; then
  # Install oh-my-zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  # Install zsh plugins
  # Install fzf plugin
  sudo pacman -S --needed --noconfirm fzf

  # Install zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

  # Install zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

  # Install you-should-use
  git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use

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

  # Reboot
  custom_reboot

else
  echo "Nothing to do"

fi
