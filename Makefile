default: all

export GHDL ?= /opt/ghdl/bin/ghdl
export VERILATOR ?= /opt/verilator/bin/verilator
export BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

export MAXTIME ?= 1000# duration of simulation

export VHDL ?= 1# 1 -> enable, 0 -> disable
export VERILOG ?= 1# 1 -> enable, 0 -> disable

export DADDA ?= 1# 1 -> enable, 0 -> disable
export WALLACE ?= 1# 1 -> enable, 0 -> disable

export ADD ?= 1# 1 -> enable, 0 -> disable
export SUB ?= 1# 1 -> enable, 0 -> disable

export SIZE ?= 32# number of bits

run_mul:
	sim/run_mul.sh

run_add:
	sim/run_add.sh

all: run_mul run_add
