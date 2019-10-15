default: none

GHDL ?= /opt/ghdl/bin/ghdl
TYPE ?= wallace # dadda
SIZE ?= 32
CYCLE ?= 1000

osvvm:
	cd tools; ./osvvm.sh

run:
	sim/run.sh ${GHDL} ${TYPE} ${SIZE} ${CYCLE}

all:
	osvvm run
