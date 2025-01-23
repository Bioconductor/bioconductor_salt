#!/usr/bin/env bash

# Basic deps
apt update -qq
apt -y install curl git build-essential python3 python3-pip locales wget

# Set up saltstack

#https://docs.saltproject.io/salt/install-guide/en/latest/topics/install-by-operating-system/linux-deb.html

mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | tee /etc/apt/keyrings/salt-archive-keyring.pgp
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | tee /etc/apt/sources.list.d/salt.sources

apt-get -y update
apt-get -y install salt-minion
service salt-minion stop
systemctl disable salt-minion

# Assumes the repository has already been cloned to the working directory
# cd ~
# git clone -b standalone https://github.com/Bioconductor/bioconductor_salt

# Set up bioconductor's saltstack
cp -r bioconductor_salt/saltstack/salt /srv
cp -r bioconductor_salt/saltstack/pillar /srv
cp bioconductor_salt/saltstack/minion.d/minion.conf /etc/salt/minion

mv /srv/pillar/custom/devel_standalone.sls /srv/pillar/custom/init.sls

salt-call --local state.highstate || true

# Find R path and check that it works
if ! /home/biocbuild/bbs-*/R/bin/R --version > /tmp/rver; then exit 1; fi

RPATH="$(echo /home/biocbuild/bbs-*/R/bin)"

echo "export PATH='$PATH:$RPATH'" | tee -a /etc/profile
echo "export PATH='$PATH:$RPATH'" | tee -a /etc/bash.bashrc

echo "#!/bin/bash" | tee /bbs_r_start
echo "$RPATH/R \"\$@\"" | tee -a /bbs_r_start

chown biocbuild /bbs_r_start
chmod +x /bbs_r_start

ln -s /home/biocbuild/bbs-*-bioc/R/bin/R /usr/bin/R
ln -s /home/biocbuild/bbs-*-bioc/R/bin/Rscript /usr/bin/Rscript

# Cleanup
# rm -rf /srv /etc/salt
# apt-get -y purge salt-minion


