#!/bin/bash

if [ -d "sim/work" ]; then
  rm -rf sim/work
fi

ANALYS="$NVC --std=2008 -a"
ELABOR="$NVC --std=2008 -e"
SIMULA="$NVC --std=2008 -r"

mkdir sim/work

if [ "$TYPE_ADD" = 'add' ]
then
  TYP=0
elif [ "$TYPE_ADD" = 'sub' ]
then
  TYP=1
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
echo "  constant XLEN : integer := "$SIZE";" >> configure.vhd
echo "  constant TYP  : std_logic := '"$TYP"';" >> configure.vhd
echo "end package;" >> configure.vhd

mv configure.vhd ../../src/vhdl/

$ANALYS ../../src/vhdl/configure.vhd

$ANALYS ../../src/vhdl/wire.vhd
$ANALYS ../../src/vhdl/libs.vhd
$ANALYS ../../src/vhdl/multiplexer.vhd

$ANALYS ../../src/vhdl/ha.vhd
$ANALYS ../../src/vhdl/fa.vhd
$ANALYS ../../src/vhdl/cla.vhd
$ANALYS ../../src/vhdl/cra.vhd
$ANALYS ../../src/vhdl/csa.vhd
$ANALYS ../../src/vhdl/add.vhd

$ANALYS ../../src/tb/test_adder.vhd

$ELABOR test_adder
$SIMULA test_adder --stop-time=${MAXTIME}ps --wave=output.ghw
