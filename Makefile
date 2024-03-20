default: all

export GHDL ?= /opt/ghdl/bin/ghdl
export VERILATOR ?= /opt/verilator/bin/verilator
export BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

export MAXTIME ?= 1000# duration of simulation

export SIZE ?= 32# number of bits

export VHDL ?= 0# 1 -> enable, 0 -> disable
export VERILOG ?= 0# 1 -> enable, 0 -> disable

export DADDA ?= 0# 1 -> enable, 0 -> disable
export WALLACE ?= 0# 1 -> enable, 0 -> disable

export ADD ?= 0# 1 -> enable, 0 -> disable
export SUB ?= 0# 1 -> enable, 0 -> disable

run_mul:
	sim/run_mul.sh

run_add:
	sim/run_add.sh

all: run_mul run_add
