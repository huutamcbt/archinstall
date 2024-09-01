#!/usr/bin/env bash

function custom_reboot() {
  echo "Do you want to reboot now? [y/n]"
  read REBOOT
  if [[ $REBOOT = 'y' ]]; then
    reboot
  fi
}
