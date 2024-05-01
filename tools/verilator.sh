#!/bin/bash
set -e

PREFIX=/usr/local/

sudo apt-get -y install git make autoconf g++ flex bison libfl-dev help2man

if [ -d "verilator" ]; then
  rm -rf verilator
fi

git clone http://git.veripool.org/git/verilator

unset VERILATOR_ROOT

cd verilator

git pull
git checkout stable

autoconf
./configure --prefix=$PREFIX

make -j$(nproc)
sudo make install
