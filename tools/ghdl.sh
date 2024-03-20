#!/bin/bash
set -e

PREFIX=/opt/ghdl

if [ -d "$PREFIX" ]
then
  sudo rm -rf $PREFIX
fi
sudo mkdir $PREFIX
sudo chown -R $USER:$USER $PREFIX/

sudo apt-get -y install git build-essential llvm-dev make gnat clang zlib1g-dev

if [ -d "ghdl" ]; then
  rm -rf ghdl
fi

git clone https://github.com/ghdl/ghdl.git

cd ghdl

git checkout tags/v3.0.0

./configure --with-llvm-config --prefix=$PREFIX

make -j$(nproc)
make install

if [ -d "OSVVM" ]; then
  rm -rf OSVVM
fi

git clone https://github.com/OSVVM/OSVVM.git

cd OSVVM

git checkout tags/2022.05

/opt/ghdl/lib/ghdl/vendors/compile-osvvm.sh --osvvm --source . --output /opt/ghdl/lib/ghdl --ghdl /opt/ghdl/bin/ghdl