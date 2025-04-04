#!/bin/bash

apt-get update && \
  apt-get install -y \
    sudo \
    git \
    vim \
    curl \
    build-essential \
    lsb-release \
    apt-cacher-ng \
    procps \
    lsof \
    cpio \
    grub2 \
    grub-efi-arm64 \
    grub-efi-arm64-bin \
    netcat-openbsd

useradd -m -s /bin/bash vboxuser && \
    echo 'vboxuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vboxuser && \
    chmod 440 /etc/sudoers.d/vboxuser

git clone https://github.com/whonix/derivative-maker.git /home/vboxuser/derivative-maker

chown -R vboxuser:vboxuser /home/vboxuser/derivative-maker

CMD ["/bin/bash", "-c", "/usr/local/bin/entrypoint.sh"]
