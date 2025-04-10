#!/bin/bash

set -e

REPO_URL="https://github.com/derivative-maker/derivative-maker.git"
REPO_DIR="/home/vboxuser/derivative-maker"
REPO_TAG="17.2.0.7-stable"

# Check if we're running as root
if [ "$(id -u)" -ne 1000 ]; then
  echo "This script must be run as vboxuser."
  exit 1
fi

main() {
  __clone_derivative_maker
  __build_derivative
}

__clone_derivative_maker() {
  git clone $REPO_URL $REPO_DIR
  cd $REPO_DIR
  git clean -f
  git fetch --tags
  git checkout tags/$REPO_TAG
}

__build_derivative() {
  /home/vboxuser/derivative-maker/derivative-maker --flavor whonix-gateway-xfce --target raw --type vm --arch arm64 --repo true --tb open --vmsize 5G
  /home/vboxuser/derivative-maker/derivative-maker --flavor whonix-workstation-xfce --target raw --type vm --arch arm64 --repo true --tb open --vmsize 5G
}

main

