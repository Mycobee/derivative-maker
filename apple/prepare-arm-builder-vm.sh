#!/bin/bash

set -e

PACKAGES=("sudo" "vim" "git" "curl")

# Check if we're running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

main() {
  __install_packages
  __check_passwordless_sudo
}

__install_packages() {
  apt-get update -y

  for package in "${PACKAGES[@]}"; do
    apt-get install -y "$package"
  done
}

__check_passwordless_sudo() {
  if id "vboxuser" &>/dev/null; then
    echo "vboxuser exists."
  else
    echo "vboxuser does not exist. Exiting script."
    exit 1
  fi

  if ! sudo -lU vboxuser | grep -q "(ALL) NOPASSWD: ALL"; then
    echo "Configuring passwordless sudo for vboxuser..."
    echo "vboxuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vboxuser
  fi

  if ! sudo -lU vboxuser | grep -q "(ALL) NOPASSWD: ALL"; then
    echo "Configuring passwordless sudo for vboxuser..."
    echo "vboxuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vboxuser
  fi
}

main

echo "Script completed successfully."
