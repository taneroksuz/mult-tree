#!/bin/bash
set -e

PREFIX=/opt/iverilog

if [ -d "$PREFIX" ]
then
  sudo rm -rf $PREFIX
fi
sudo mkdir $PREFIX
sudo chown -R $USER:$USER $PREFIX/

sudo apt-get -y install build-essential libboost-dev iverilog

if [ -d "iverilog" ]; then
  rm -rf iverilog
fi

git clone https://github.com/steveicarus/iverilog.git

cd iverilog

git checkout --track -b v11-branch origin/v11-branch

git pull
sh autoconf.sh

./configure --prefix=$PREFIX

make -j$(nproc)
make install
