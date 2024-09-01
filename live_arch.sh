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
  echo "SWAP AREA     : $SWAP"
}

print_lsblk

echo "Please enter EFI partition: (example /dev/sda1 or /dev/nvme0n1p1)"
read EFI
if [[ $DRIVE =~ 'nvme' ]]; then
  EFI=${DRIVE}p${EFI}
else
  EFI=${DRIVE}${EFI}
fi
echo "Please enter boot partition: (example /dev/sda1 or /dev/nvme0n1p1)"
read BOOT
if [[ $DRIVE =~ 'nvme' ]]; then
  BOOT=${DRIVE}p${BOOT}
else
  BOOT=${DRIVE}${BOOT}
fi
echo "Please enter swap partition: (example /dev/sda1 or /dev/nvme0n1p1)"
read SWAP
if [[ $DRIVE =~ 'nvme' ]]; then
  SWAP=${DRIVE}p${SWAP}
else
  SWAP=${DRIVE}${SWAP}
fi
ROOT=/dev/vg0/lv_root
HOME=/dev/vg0/lv_home
DATA=/dev/vg0/lv_data

# while [[ ! $EFI =~ $DRIVE ]]; do
#   echo "Please enter EFI partition: (example /dev/sda1 or /dev/nvme0n1p1)"
#   read EFI
#   #  echo "This partition is not in the selected drive"
# done
#
# while [[ ! $BOOT =~ $DRIVE ]]; do
#   echo "Please enter boot partition: (example /dev/sda1 or /dev/nvme0n1p1)"
#   read BOOT
#   #  echo "This partition is not in the selected drive"
# done
#
# while [[ ! $SWAP =~ $DRIVE ]]; do
#   echo "Please enter swap partition: (example /dev/sda1 or /dev/nvme0n1p1)"
#   read SWAP
#   # echo "This partition is not in the selected drive"
# done
#
# while [[ ! $ROOT =~ 'lv_root' ]]; do
#   echo "Please enter root partition: (example /dev/sda1 or /dev/nvme0n1p1)"
#   read ROOT
#   #echo "This partition is not in the selected drive"
# done
#
# while [[ ! $HOME =~ 'lv_home' ]]; do
#   echo "Please enter home partition: (example /dev/sda1 or /dev/nvme0n1p1)"
#   read HOME
#   #echo "This partition is not in the selected drive"
# done
#
# while [[ ! $DATA =~ 'lv_data' ]]; do
#   echo "Please enter data partition: (example /dev/sda1 or /dev/nvme0n1p1)"
#   read DATA
#   #echo "This partition is not in the selected drive"
# done

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

pacstrap -K /mnt base linux linux-firmware linux-headers base-devel dosfstools grub efibootmgr gnome gnome-tweaks gnome-themes-extra lvm2 mtools nano networkmanager openssh os-prober sudo man intel-ucode bluez bluez-utils sof-firmware git htop neofetch firefox-developer-edition libreoffice-fresh gnome-extra gnome-browser-connector timeshift ranger fzf networkmanager-openvpn network-manager-applet subversion xclip terminus-font

# linux-lts linux-lts-headers

# Generate the file system UUID file
echo "Generate the file system UUID file"
echo "Press Enter to continue"
read
genfstab -U /mnt >>/mnt/etc/fstab

echo "The detail fstab file"
cat "/mnt/etc/fstab"

# cp -r ../archinstall/ /mnt
# Change root into /mnt directory
echo "Run arch-chroot"
echo "Press Enter to continue ..."
read
