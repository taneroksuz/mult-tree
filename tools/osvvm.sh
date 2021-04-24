#!/bin/bash

if [ -d "OSVVM" ]; then
  rm -rf OSVVM
fi

git clone https://github.com/OSVVM/OSVVM.git
