#!/bin/bash
set -e

PREFIX=/usr/local/

if [ -d "UVVM" ]; then
  rm -rf UVVM
fi

sudo apt-get install -y git make autoconf g++ flex bison libfl-dev help2man

git clone https://github.com/UVVM/UVVM.git

cd UVVM

sudo $PREFIX/lib/ghdl/vendors/compile-uvvm.sh --all --source . --output $PREFIX/lib/ghdl --ghdl $PREFIX/bin/ghdl