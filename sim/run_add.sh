#!/bin/bash

if [ -d "sim/work" ]; then
  rm -rf sim/work
fi

mkdir sim/work

if [ "$TYPE_ADD" = 'add' ]
then
  TYP=0
elif [ "$TYPE_ADD" = 'sub' ]
then
  TYP=1
fi

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
  $ANALYS ../../src/vhdl/cla.vhd
  $ANALYS ../../src/vhdl/cra.vhd
  $ANALYS ../../src/vhdl/csa.vhd
  $ANALYS ../../src/vhdl/add.vhd

  $ANALYS ../../src/tb/vhdl/test_adder.vhd

  $ELABOR test_adder
  $SIMULA test_adder --stop-time=${MAXTIME}ps --wave=output.ghw

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
  echo "  integer MAXTIME = "$MAXTIME";" >> configure.sv
  echo "  integer SEED = "$TIME";" >> configure.sv
  echo "  logic TYP = "$TYP";" >> configure.sv
  echo "endpackage" >> configure.sv

  mv configure.sv ../../src/verilog/

  $VERILATOR --binary --trace --trace-structs --top-module test_adder \
                                 ../../src/verilog/configure.sv \
                                 ../../src/verilog/mutex.sv \
                                 ../../src/verilog/ha.sv \
                                 ../../src/verilog/fa.sv \
                                 ../../src/verilog/cla.sv \
                                 ../../src/verilog/add.sv \
                                 ../../src/tb/verilog/test_adder.sv 2>&1 > /dev/null

  make -s -j -C obj_dir/ -f Vtest_adder.mk Vtest_adder

  obj_dir/Vtest_adder

fi