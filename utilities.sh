#!/usr/bin/env bash

function custom_reboot() {
  echo "Do you want to reboot now? [y/n]"
  read REBOOT
  if [[ $REBOOT = 'y' ]]; then
    reboot
  fi
}

function custom_umount() {
  echo "Do you want to umount now? [y/n]"
  read UMOUNT
  if [[ $UMOUNT = 'y' ]]; then
    umount -a
  fi
}
