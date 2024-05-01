#!/bin/bash

if [ -d "$BASEDIR/sim/work" ]; then
  rm -rf $BASEDIR/sim/work
fi

mkdir $BASEDIR/sim/work

if [ "$VHDL" = "1" ]
then

  ANALYS="$GHDL -a --std=08"
  ELABOR="$GHDL -e --std=08"
  SIMULA="$GHDL -r --std=08"

  TIME=$(date +%s)

  if [ "$ADD" = "1" ]
  then

    cd $BASEDIR/sim/work

    if [ -e "configure.vhd" ]
    then
      rm configure.vhd
    fi

    echo "library ieee;" >> configure.vhd
    echo "use ieee.std_logic_1164.all;" >> configure.vhd
    echo "use ieee.numeric_std.all;" >> configure.vhd
    echo "" >> configure.vhd
    echo "package configure is" >> configure.vhd
    echo "  constant XLEN : integer := "$N";" >> configure.vhd
    echo "  constant SEED : integer := "$TIME";" >> configure.vhd
    echo "  constant TYP  : std_logic := '"0"';" >> configure.vhd
    echo "end package;" >> configure.vhd

    mv configure.vhd $BASEDIR/src/vhdl/

    $ANALYS $BASEDIR/src/vhdl/configure.vhd

    $ANALYS $BASEDIR/src/vhdl/wire.vhd
    $ANALYS $BASEDIR/src/vhdl/libs.vhd
    $ANALYS $BASEDIR/src/vhdl/mutex.vhd

    $ANALYS $BASEDIR/src/vhdl/ha.vhd
    $ANALYS $BASEDIR/src/vhdl/fa.vhd
    $ANALYS $BASEDIR/src/vhdl/cla.vhd
    $ANALYS $BASEDIR/src/vhdl/cra.vhd
    $ANALYS $BASEDIR/src/vhdl/csa.vhd
    $ANALYS $BASEDIR/src/vhdl/add.vhd

    $ANALYS $BASEDIR/src/tb/vhdl/test_adder.vhd

    $ELABOR test_adder
    $SIMULA test_adder --stop-time=${MAXTIME}ps --wave=add.ghw

  fi

  if [ "$SUB" = "1" ]
  then

    cd $BASEDIR/sim/work

    if [ -e "configure.vhd" ]
    then
      rm configure.vhd
    fi

    echo "library ieee;" >> configure.vhd
    echo "use ieee.std_logic_1164.all;" >> configure.vhd
    echo "use ieee.numeric_std.all;" >> configure.vhd
    echo "" >> configure.vhd
    echo "package configure is" >> configure.vhd
    echo "  constant XLEN : integer := "$N";" >> configure.vhd
    echo "  constant SEED : integer := "$TIME";" >> configure.vhd
    echo "  constant TYP  : std_logic := '"1"';" >> configure.vhd
    echo "end package;" >> configure.vhd

    mv configure.vhd $BASEDIR/src/vhdl/

    $ANALYS $BASEDIR/src/vhdl/configure.vhd

    $ANALYS $BASEDIR/src/vhdl/wire.vhd
    $ANALYS $BASEDIR/src/vhdl/libs.vhd
    $ANALYS $BASEDIR/src/vhdl/mutex.vhd

    $ANALYS $BASEDIR/src/vhdl/ha.vhd
    $ANALYS $BASEDIR/src/vhdl/fa.vhd
    $ANALYS $BASEDIR/src/vhdl/cla.vhd
    $ANALYS $BASEDIR/src/vhdl/cra.vhd
    $ANALYS $BASEDIR/src/vhdl/csa.vhd
    $ANALYS $BASEDIR/src/vhdl/add.vhd

    $ANALYS $BASEDIR/src/tb/vhdl/test_adder.vhd

    $ELABOR test_adder
    $SIMULA test_adder --stop-time=${MAXTIME}ps --wave=sub.ghw
  
  fi

fi

cd $BASEDIR/src/cpp

if [ "$VERILOG" = "1" ]
then

  TIME=$(date +%s)

  if [ "$ADD" = "1" ]
  then

    cd $BASEDIR/sim/work

    if [ -e "configure.sv" ]
    then
      rm configure.sv
    fi

    echo "package configure;" >> configure.sv
    echo "  timeunit 1ps;" >> configure.sv
    echo "  timeprecision 1ps;" >> configure.sv
    echo "" >> configure.sv
    echo "  parameter XLEN = "$N";" >> configure.sv
    echo "  integer MAXTIME = "$MAXTIME";" >> configure.sv
    echo "  integer SEED = "$TIME";" >> configure.sv
    echo "  logic TYP = "0";" >> configure.sv
    echo "endpackage" >> configure.sv

    mv configure.sv $BASEDIR/src/verilog/

    $VERILATOR --binary --trace --trace-structs --top-module test_adder \
                                  $BASEDIR/src/verilog/configure.sv \
                                  $BASEDIR/src/verilog/mutex.sv \
                                  $BASEDIR/src/verilog/ha.sv \
                                  $BASEDIR/src/verilog/fa.sv \
                                  $BASEDIR/src/verilog/cla.sv \
                                  $BASEDIR/src/verilog/add.sv \
                                  $BASEDIR/src/tb/verilog/test_adder.sv 2>&1 > /dev/null

    make -s -j -C obj_dir/ -f Vtest_adder.mk Vtest_adder

    obj_dir/Vtest_adder
  
  fi

  if [ "$SUB" = "1" ]
  then

    cd $BASEDIR/sim/work

    if [ -e "configure.sv" ]
    then
      rm configure.sv
    fi

    echo "package configure;" >> configure.sv
    echo "  timeunit 1ps;" >> configure.sv
    echo "  timeprecision 1ps;" >> configure.sv
    echo "" >> configure.sv
    echo "  parameter XLEN = "$N";" >> configure.sv
    echo "  integer MAXTIME = "$MAXTIME";" >> configure.sv
    echo "  integer SEED = "$TIME";" >> configure.sv
    echo "  logic TYP = "1";" >> configure.sv
    echo "endpackage" >> configure.sv

    mv configure.sv $BASEDIR/src/verilog/

    $VERILATOR --binary --trace --trace-structs --top-module test_adder \
                                  $BASEDIR/src/verilog/configure.sv \
                                  $BASEDIR/src/verilog/mutex.sv \
                                  $BASEDIR/src/verilog/ha.sv \
                                  $BASEDIR/src/verilog/fa.sv \
                                  $BASEDIR/src/verilog/cla.sv \
                                  $BASEDIR/src/verilog/add.sv \
                                  $BASEDIR/src/tb/verilog/test_adder.sv 2>&1 > /dev/null

    make -s -j -C obj_dir/ -f Vtest_adder.mk Vtest_adder

    obj_dir/Vtest_adder

  fi

fi