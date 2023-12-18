#!/usr/bin/env bash

# Basic deps
sudo apt update -qq
sudo apt -y install curl git build-essential python3 python3-pip locales wget

# Set up saltstack

# https://docs.saltproject.io/salt/install-guide/en/latest/topics/install-by-operating-system/ubuntu.html

sudo curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring-2023.gpg https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/SALT-PROJECT-GPG-PUBKEY-2023.gpg
echo "deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/latest jammy main" | sudo tee /etc/apt/sources.list.d/salt.list

sudo apt-get -y update
sudo apt-get -y install salt-minion
sudo service salt-minion stop
sudo systemctl disable salt-minion

# Assumes the repository has already been cloned to the working directory
# cd ~
# git clone -b standalone https://github.com/Bioconductor/bioconductor_salt

# Set up bioconductor's saltstack
sudo cp -r bioconductor_salt/saltstack/salt /srv
sudo cp -r bioconductor_salt/saltstack/pillar /srv
sudo cp bioconductor_salt/saltstack/minion.d/minion.conf /etc/salt/minion

sudo mv /srv/pillar/custom/release_standalone.sls /srv/pillar/custom/init.sls

sudo salt-call --local state.highstate || true

# Find R path and check that it works
if ! /home/biocbuild/bbs-*/R/bin/R --version > /tmp/rver; then exit 1; fi

RPATH="$(echo /home/biocbuild/bbs-*/R/bin)"

echo "export PATH='$PATH:$RPATH'" | sudo tee -a /etc/profile
echo "export PATH='$PATH:$RPATH'" | sudo tee -a /etc/bash.bashrc

echo "#!/bin/bash" | sudo tee /bbs_r_start
echo "$RPATH/R \"\$@\"" | sudo tee -a /bbs_r_start

sudo chown biocbuild /bbs_r_start
sudo chmod +x /bbs_r_start

# Cleanup
# rm -rf /srv /etc/salt
# sudo apt-get -y purge salt-minion


