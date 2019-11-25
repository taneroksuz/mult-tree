#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
then
  echo "1. option: ghdl"
  echo "2. option: add, sub"
  echo "3. option: * <bits (for N bits type only N)>"
  echo "4. option: * <cycles (default value is 1000)>"
  exit
fi

if [ -d "sim/work" ]; then
  rm -rf sim/work
fi

ghdl=$1

SYNTAX="${ghdl} -s --std=08 --ieee=synopsys"
ANALYS="${ghdl} -a --std=08 --ieee=synopsys"
ELABOR="${ghdl} -e --std=08 --ieee=synopsys"
SIMULA="${ghdl} -r --std=08 --ieee=synopsys"

mkdir sim/work

if [ "$2" = 'add' ]
then
  TYP=0
elif [ "$2" = 'sub' ]
then
  TYP=1
fi

if [ -z "$4" ]
then
  CYCLES=1000
else
  CYCLES="$4"
fi

cd sim/work

if [ -e 'configure.vhd' ]
then
  rm configure.vhd
fi

echo "library ieee;" >> configure.vhd
echo "use ieee.std_logic_1164.all;" >> configure.vhd
echo "use ieee.numeric_std.all;" >> configure.vhd
echo "" >> configure.vhd
echo "package configure is" >> configure.vhd
echo "  constant XLEN : integer := "$3";" >> configure.vhd
echo "  constant TYP  : std_logic := '"$TYP"';" >> configure.vhd
echo "end package;" >> configure.vhd

mv configure.vhd ../../src/vhdl/

$SYNTAX ../../tools/OSVVM/NamePkg.vhd
$ANALYS ../../tools/OSVVM/NamePkg.vhd
$SYNTAX ../../tools/OSVVM/OsvvmGlobalPkg.vhd
$ANALYS ../../tools/OSVVM/OsvvmGlobalPkg.vhd
$SYNTAX ../../tools/OSVVM/VendorCovApiPkg.vhd
$ANALYS ../../tools/OSVVM/VendorCovApiPkg.vhd
$SYNTAX ../../tools/OSVVM/TranscriptPkg.vhd
$ANALYS ../../tools/OSVVM/TranscriptPkg.vhd
$SYNTAX ../../tools/OSVVM/TextUtilPkg.vhd
$ANALYS ../../tools/OSVVM/TextUtilPkg.vhd
$SYNTAX ../../tools/OSVVM/AlertLogPkg.vhd
$ANALYS ../../tools/OSVVM/AlertLogPkg.vhd
$SYNTAX ../../tools/OSVVM/MessagePkg.vhd
$ANALYS ../../tools/OSVVM/MessagePkg.vhd
$SYNTAX ../../tools/OSVVM/SortListPkg_int.vhd
$ANALYS ../../tools/OSVVM/SortListPkg_int.vhd
$SYNTAX ../../tools/OSVVM/RandomBasePkg.vhd
$ANALYS ../../tools/OSVVM/RandomBasePkg.vhd
$SYNTAX ../../tools/OSVVM/RandomPkg.vhd
$ANALYS ../../tools/OSVVM/RandomPkg.vhd

$SYNTAX ../../src/vhdl/configure.vhd
$ANALYS ../../src/vhdl/configure.vhd

$SYNTAX ../../src/vhdl/wire.vhd
$ANALYS ../../src/vhdl/wire.vhd
$SYNTAX ../../src/vhdl/libs.vhd
$ANALYS ../../src/vhdl/libs.vhd
$SYNTAX ../../src/vhdl/multiplexer.vhd
$ANALYS ../../src/vhdl/multiplexer.vhd

$SYNTAX ../../src/vhdl/ha.vhd
$ANALYS ../../src/vhdl/ha.vhd
$SYNTAX ../../src/vhdl/fa.vhd
$ANALYS ../../src/vhdl/fa.vhd
$SYNTAX ../../src/vhdl/cla.vhd
$ANALYS ../../src/vhdl/cla.vhd
$SYNTAX ../../src/vhdl/cra.vhd
$ANALYS ../../src/vhdl/cra.vhd
$SYNTAX ../../src/vhdl/csa.vhd
$ANALYS ../../src/vhdl/csa.vhd
$SYNTAX ../../src/vhdl/add.vhd
$ANALYS ../../src/vhdl/add.vhd

$SYNTAX ../../src/tb/test_adder.vhd
$ANALYS ../../src/tb/test_adder.vhd

$ELABOR test_adder
$SIMULA test_adder --stop-time=${CYCLES}ps --wave=output.ghw
