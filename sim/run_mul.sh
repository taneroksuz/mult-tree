#!/bin/bash

if [ -d "sim/work" ]; then
  rm -rf sim/work
fi

ANALYS="$NVC --std=2008 -a"
ELABOR="$NVC --std=2008 -e"
SIMULA="$NVC --std=2008 -r"

mkdir sim/work

if [ "$TYPE_MUL" = 'dadda' ]
then
  TYP=0
elif [ "$TYPE_MUL" = 'wallace' ]
then
  TYP=1
fi

cd src/cpp
make clean
make

if [ $TYP = 0 ] || [ $TYP = 1 ]
then
  ./multiply_tree dadda $SIZE
  ./multiply_tree wallace $SIZE
  mv dadda.vhd ../../src/vhdl/
  mv wallace.vhd ../../src/vhdl/
fi

TIME=$(date +%s)

cd -

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
echo "  constant SEED : integer := "$TIME";" >> configure.vhd
echo "  constant TYP  : std_logic := '"$TYP"';" >> configure.vhd
echo "end package;" >> configure.vhd

mv configure.vhd ../../src/vhdl/

$ANALYS ../../src/vhdl/configure.vhd

$ANALYS ../../src/vhdl/wire.vhd
$ANALYS ../../src/vhdl/libs.vhd
$ANALYS ../../src/vhdl/multiplexer.vhd

$ANALYS ../../src/vhdl/ha.vhd
$ANALYS ../../src/vhdl/fa.vhd

$ANALYS ../../src/vhdl/dadda.vhd
$ANALYS ../../src/vhdl/wallace.vhd
$ANALYS ../../src/vhdl/mul.vhd

$ANALYS ../../src/tb/test_multiply.vhd

$ELABOR test_multiply
$SIMULA test_multiply --stop-time=${MAXTIME}ps --wave=output.ghw
