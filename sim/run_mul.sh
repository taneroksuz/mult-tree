#!/bin/bash

if [ -d "sim/work" ]; then
  rm -rf sim/work
fi

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
  mv dadda.sv ../../src/verilog/
  mv wallace.sv ../../src/verilog/
fi

cd -

if [ "$LANGUAGE" = 'vhdl' ]
then

  ANALYS="$GHDL -a --std=08"
  ELABOR="$GHDL -e --std=08"
  SIMULA="$GHDL -r --std=08"

  TIME=$(date +%s)

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
  $ANALYS ../../src/vhdl/mutex.vhd

  $ANALYS ../../src/vhdl/ha.vhd
  $ANALYS ../../src/vhdl/fa.vhd

  $ANALYS ../../src/vhdl/dadda.vhd
  $ANALYS ../../src/vhdl/wallace.vhd
  $ANALYS ../../src/vhdl/mul.vhd

  $ANALYS ../../src/tb/vhdl/test_multiply.vhd

  $ELABOR test_multiply
  $SIMULA test_multiply --stop-time=${MAXTIME}ps --wave=output.ghw

elif [ "$LANGUAGE" = 'verilog' ]
then

  TIME=$(date +%s)

  cd sim/work

  if [ -e 'configure.sv' ]
  then
    rm configure.sv
  fi

  echo "package configure;" >> configure.sv
  echo "  timeunit 1ps;" >> configure.sv
  echo "  timeprecision 1ps;" >> configure.sv
  echo "" >> configure.sv
  echo "  parameter XLEN = "$SIZE";" >> configure.sv
  echo "  parameter TYP = "$TYP";" >> configure.sv
  echo "  integer MAXTIME = "$MAXTIME";" >> configure.sv
  echo "  integer SEED = "$TIME";" >> configure.sv
  echo "endpackage" >> configure.sv

  mv configure.sv ../../src/verilog/

  $VERILATOR --binary --trace --trace-structs --top-module test_multiply \
                                 ../../src/verilog/configure.sv \
                                 ../../src/verilog/mutex.sv \
                                 ../../src/verilog/ha.sv \
                                 ../../src/verilog/fa.sv \
                                 ../../src/verilog/dadda.sv \
                                 ../../src/verilog/wallace.sv \
                                 ../../src/verilog/mul.sv \
                                 ../../src/tb/verilog/test_multiply.sv 2>&1 > /dev/null

  make -s -j -C obj_dir/ -f Vtest_multiply.mk Vtest_multiply

  obj_dir/Vtest_multiply

fi
