#!/bin/bash

# currently this needs to be run as root

cd /home/vboxuser/derivative-maker

apt-get install --yes \
    sudo \
    git \
    vim \
    curl

useradd -m -s /bin/bash vboxuser && \
    echo 'vboxuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vboxuser && \
    chmod 440 /etc/sudoers.d/vboxuser


/home/vboxuser/derivative-maker/derivative-maker --flavor whonix-gateway-xfce --target raw --arch arm64 --repo true --tb open --vmsize 5G --allow-untagged true
