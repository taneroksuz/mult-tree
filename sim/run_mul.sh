#!/bin/bash

if [ -d "$BASEDIR/sim/work" ]; then
  rm -rf $BASEDIR/sim/work
fi

mkdir $BASEDIR/sim/work

cd $BASEDIR/src/cpp
make clean
make

if [ "$VHDL" = "1" ]
then

  TIME=$(date +%s)

  ./multiply_tree dadda $SIZE
  ./multiply_tree wallace $SIZE
  mv dadda.vhd $BASEDIR/src/vhdl/
  mv wallace.vhd $BASEDIR/src/vhdl/

  ANALYS="$GHDL -a --std=08"
  ELABOR="$GHDL -e --std=08"
  SIMULA="$GHDL -r --std=08"

  if [ "$DADDA" = "1" ]
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
    echo "  constant XLEN : integer := "$SIZE";" >> configure.vhd
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

    $ANALYS $BASEDIR/src/vhdl/dadda.vhd
    $ANALYS $BASEDIR/src/vhdl/wallace.vhd
    $ANALYS $BASEDIR/src/vhdl/mul.vhd

    $ANALYS $BASEDIR/src/tb/vhdl/test_multiply.vhd

    $ELABOR test_multiply
    $SIMULA test_multiply --stop-time=${MAXTIME}ps --wave=dadda.ghw

  fi
  
  if [ "$WALLACE" = "1" ]
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
    echo "  constant XLEN : integer := "$SIZE";" >> configure.vhd
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

    $ANALYS $BASEDIR/src/vhdl/dadda.vhd
    $ANALYS $BASEDIR/src/vhdl/wallace.vhd
    $ANALYS $BASEDIR/src/vhdl/mul.vhd

    $ANALYS $BASEDIR/src/tb/vhdl/test_multiply.vhd

    $ELABOR test_multiply
    $SIMULA test_multiply --stop-time=${MAXTIME}ps --wave=wallace.ghw

  fi

fi

cd $BASEDIR/src/cpp

if [ "$VERILOG" = "1" ]
then

  TIME=$(date +%s)

  ./multiply_tree dadda $SIZE
  ./multiply_tree wallace $SIZE
  mv dadda.sv $BASEDIR/src/verilog/
  mv wallace.sv $BASEDIR/src/verilog/

  if [ "$DADDA" = "1" ]
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
    echo "  parameter XLEN = "$SIZE";" >> configure.sv
    echo "  parameter TYP = "0";" >> configure.sv
    echo "  integer MAXTIME = "$MAXTIME";" >> configure.sv
    echo "  integer SEED = "$TIME";" >> configure.sv
    echo "endpackage" >> configure.sv

    mv configure.sv $BASEDIR/src/verilog/

    $VERILATOR --binary --trace --trace-structs --top-module test_multiply \
                                  $BASEDIR/src/verilog/configure.sv \
                                  $BASEDIR/src/verilog/mutex.sv \
                                  $BASEDIR/src/verilog/ha.sv \
                                  $BASEDIR/src/verilog/fa.sv \
                                  $BASEDIR/src/verilog/dadda.sv \
                                  $BASEDIR/src/verilog/wallace.sv \
                                  $BASEDIR/src/verilog/mul.sv \
                                  $BASEDIR/src/tb/verilog/test_multiply.sv 2>&1 > /dev/null

    make -s -j -C obj_dir/ -f Vtest_multiply.mk Vtest_multiply

    obj_dir/Vtest_multiply
  
  fi
  
  if [ "$WALLACE" = "1" ]
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
    echo "  parameter XLEN = "$SIZE";" >> configure.sv
    echo "  parameter TYP = "1";" >> configure.sv
    echo "  integer MAXTIME = "$MAXTIME";" >> configure.sv
    echo "  integer SEED = "$TIME";" >> configure.sv
    echo "endpackage" >> configure.sv

    mv configure.sv $BASEDIR/src/verilog/

    $VERILATOR --binary --trace --trace-structs --top-module test_multiply \
                                  $BASEDIR/src/verilog/configure.sv \
                                  $BASEDIR/src/verilog/mutex.sv \
                                  $BASEDIR/src/verilog/ha.sv \
                                  $BASEDIR/src/verilog/fa.sv \
                                  $BASEDIR/src/verilog/dadda.sv \
                                  $BASEDIR/src/verilog/wallace.sv \
                                  $BASEDIR/src/verilog/mul.sv \
                                  $BASEDIR/src/tb/verilog/test_multiply.sv 2>&1 > /dev/null

    make -s -j -C obj_dir/ -f Vtest_multiply.mk Vtest_multiply

    obj_dir/Vtest_multiply
  
  fi

fi
