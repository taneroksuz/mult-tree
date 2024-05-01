#!/bin/bash
set -e

if [ -d "OsvvmLibraries" ]; then
  rm -rf OsvvmLibraries
fi

sudo apt-get install -y rlwrap

git clone --recursive https://github.com/osvvm/OsvvmLibraries

rlwrap tclsh
source OsvvmLibraries/Scripts/StartUp.tcl