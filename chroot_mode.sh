# Setup root password
arch-chroot /mnt echo "Enter root password: "
arch-chroot /mnt passwd

echo "Add your user: "
read USER
arch-chroot /mnt useradd -m -g users -G wheel $USER
echo "Enter your user password"
arch-chroot /mnt passwd $USER

# Set timezone
arch-chroot /mnt echo "Set the timezone: "

arch-chroot /mnt ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime

arch-chroot /mnt hwclock --systohc

# Edit your locale.gen file
arch-chroot /mnt echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen
arch-chroot /mnt locale-gen

arch-chroot /mnt echo LANG=en_US.UTF-8 >>/etc/locale.conf
# Set hostname
arch-chroot /mnt echo arch >>/etc/hostname

# Install GPU driver
arch-chroot /mnt pacman -Syu --needed --noconfirm mesa intel-media-driver dkms nvidia-dkms xorg xorg-apps xorg-server xorg-xinit nvidia-utils nvidia-settings

# Edit mkinitcpio.conf file
echo "Edit the mkinitcpio.conf file, add some hooks into file such as encrypt, lvm2,..."
echo "Press Enter to continue..."
read

arch-chroot /mnt nano /etc/mkinitcpio.conf

echo "Compile mkinitcpio.conf file for linux and linux-lts kernel"

arch-chroot /mnt mkinitcpio -p linux

# mkinitcpio -p linux-lts

# Install GRUB and config it

echo "Edit grub file (/etc/default/grub), set some kernel parameter such as cryptdevice, root"

blkid | grep -e "crypto_LUKS" -e "/vg0-lv_root" >>/mnt/etc/default/grub

echo "Edit /etc/default/grub"
echo "Press Enter to continue..."
read

# Edit grub file
arch-chroot /mnt nano /etc/default/grub

arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=grub_uefi --recheck

arch-chroot /mnt cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo

# Grub config
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

arch-chroot /mnt systemctl enable sshd gdm NetworkManager bluetooth

# Edit sudoer file

echo "Edit sudoer file (wheel group)"
echo "Press Enter to continue..."
read

arch-chroot /mnt nano /etc/sudoers

arch-chroot /mnt sudo chgrp -R wheel /data
arch-chroot /mnt sudo chmod -R g+rwx /data

#echo "file:///data Data" >>/home/tam/.config/gtk-3.0/bookmarks

arch-chroot /mnt echo 'ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp wheel $sys$devpath/brightness", RUN+="/bin/chmod g+w $sys$devpath/brightness"' >>/etc/udev/rules.d/backlight.rules

echo "Do you want reboot now? [y/n]"
read REBOOT
