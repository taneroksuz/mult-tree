#!/bin/bash
set -e

PREFIX=/opt/nvc

if [ -d "$PREFIX" ]
then
  sudo rm -rf $PREFIX
fi
sudo mkdir $PREFIX
sudo chown -R $USER:$USER $PREFIX/

sudo apt-get install build-essential automake autoconf \
  flex check llvm-dev pkg-config zlib1g-dev libdw-dev \
  libffi-dev libzstd-dev

if [ -d "nvc" ]; then
  rm -rf nvc
fi

git clone https://github.com/nickg/nvc.git

cd nvc

./autogen.sh

mkdir build && cd build

../configure --prefix=$PREFIX

make -j$(nproc)
make install

export PATH=$PREFIX/bin:$PATH

nvc --install osvvm
nvc --install uvvm
