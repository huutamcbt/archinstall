#!/usr/bin/env bash

echo "Enter your disk: "
read DISK
echo $'\nBecause root, home, data reside in LVM so the remaining space after partitioning for root and home partition is data partition\n'
echo "How much storage space do you need for your EFI partition?"
read EFI_SPACE
echo "How much storage space do you need for your BOOT partition?"
read BOOT_SPACE
echo "How much storage space do you need for your SWAP partition?"
read SWAP_SPACE
echo "How much storage space do you need for your General partition?"
read GENERAL_SPACE
echo "How much storage space do you need for your ROOT partition?"
read ROOT_SPACE
echo "How much storage space do you need for your HOME partition?"
read HOME_SPACE

fdisk -l $DISK

fdisk $DISK <<EOF
g
n


"+${EFI_SPACE}"
n


"+${BOOT_SPACE}"
n


"+${SWAP_SPACE}"
n


"+${GENERAL_SPACE}"
w
EOF

# fdisk $DISK <<EOF
#
# EOF
#
# fdisk $DISK <<EOF
# EOF
#
# fdisk $DISK <<EOF
#
# EOF
#
# fdisk $DISK <<EOF
#
# EOF

echo "Basic partitioning completed"
echo "Press Enter to encryption"
read

fdisk -l $DISK

cryptsetup luksFormat $GENERAL_SPACE
cryptsetup open --type luks $GENERAL_SPACE lvm

# Create physical volume in encrypt partition
pvcreate /dev/mapper/lvm

# Create volume group
vgcreate vg0 /dev/mapper/lvm

# Create logical volume
lvcreate -L $ROOT_SPACE -n lv_root

lvcreate -L $HOME_SPACE -n lv_home

lvcreate -l 100%FREE -n lv_data

lsblk $DISK
