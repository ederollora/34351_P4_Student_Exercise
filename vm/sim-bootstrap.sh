#!/bin/bash
set -xe

cp /etc/skel/.bashrc ~/
cp /etc/skel/.profile ~/
cp /etc/skel/.bash_logout ~/

# Mininet
git clone git://github.com/mininet/mininet mininet
cd mininet
sudo ./util/install.sh -nwv
