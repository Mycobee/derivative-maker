#!/bin/bash

# Default values for flags
RAM=2048        # Default RAM in MB
DISK=20000      # Default disk size in MB
BRANCH=""
PACKAGE_LIST_FILE=""

set -e

main() {
  __check_virtualbox
  __create_vm
  __install_packages
  __add_vbox_user_sudo
  __clone_repository
  __run_derivative_maker
}

__check_virtualbox() {
    if ! command -v VBoxManage &> /dev/null; then
       echo TODO INSTALL VBOX
        # echo "VirtualBox is not installed. Installing..."
        # brew install --cask virtualbox
    else
        echo "VirtualBox is already installed."
    fi
}

# Function to create the VM
__create_vm() {
    VM_NAME="debian-arm64-vm"
    VBoxManage createvm --name "$VM_NAME" --ostype "Debian_64" --register
    VBoxManage modifyvm "$VM_NAME" --memory "$RAM" --vram 16 --cpus 2 --ioapic on --firmware bios
    VBoxManage createhd --filename "$HOME/$VM_NAME.vdi" --size "$DISK"
    VBoxManage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAhci
    VBoxManage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$HOME/$VM_NAME.vdi"
    VBoxManage storagectl "$VM_NAME" --name "IDE Controller" --add ide
    VBoxManage storageattach "$VM_NAME" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium emptydrive
}

# Function to install packages from a provided file
__install_packages() {
    if [ -f "$PACKAGE_LIST_FILE" ]; then
        echo "Installing packages from $PACKAGE_LIST_FILE..."
        while IFS= read -r package; do
            sudo apt-get install -y "$package"
        done < "$PACKAGE_LIST_FILE"
    else
        echo "Package list file not found."
    fi
}

# Function to add vboxuser to sudoers with no password
__add_vbox_user_sudo() {
    echo "Adding vboxuser to passwordless sudoers..."
    echo "vboxuser ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers > /dev/null
}

# Function to clone the repository
__clone_repository() {
    echo "Cloning repository..."
    git clone https://github.com/Mycobee/derivative-maker.git "$HOME/derivative-maker"
    if [ -n "$BRANCH" ]; then
        cd "$HOME/derivative-maker" || exit
        git checkout "$BRANCH"
    fi
}

# Function to run the derivative-maker command
__run_derivative_maker() {
    echo "Running derivative-maker..."
    cd "$HOME/derivative-maker" || exit
    /home/vboxuser/derivative-maker/derivative-maker --flavor whonix-gateway-xfce --target raw --type vm --arch arm64 --repo true --tb open --vmsize 5G --allow-untagged true
}

# Parse command-line options
while getopts "r:d:p:b:" opt; do
    case $opt in
        r) RAM=$OPTARG ;;
        d) DISK=$OPTARG ;;
        p) PACKAGE_LIST_FILE=$OPTARG ;;
        b) BRANCH=$OPTARG ;;
        \?) echo "Usage: $0 [-r RAM] [-d DISK] [-p PACKAGE_LIST_FILE] [-b BRANCH]"; exit 1 ;;
    esac
done

# Main script execution
main

echo "Script execution completed."



#!/bin/bash

# apt-get update && \
#   apt-get install -y \
#     sudo \
#     git \
#     vim \
#     curl \
#     build-essential \
#     lsb-release \
#     apt-cacher-ng \
#     procps \
#     lsof \
#     cpio \
#     grub2 \
#     grub-efi-arm64 \
#     grub-efi-arm64-bin \
#     netcat-openbsd
#
# useradd -m -s /bin/bash vboxuser && \
#     echo 'vboxuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vboxuser && \
#     chmod 440 /etc/sudoers.d/vboxuser
#
# git clone https://github.com/whonix/derivative-maker.git /home/vboxuser/derivative-maker
#
# chown -R vboxuser:vboxuser /home/vboxuser/derivative-maker
#
# CMD ["/bin/bash", "-c", "/usr/local/bin/entrypoint.sh"]
