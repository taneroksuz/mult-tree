default: none

GHDL ?= /opt/ghdl/bin/ghdl
TYPE_MUL ?= wallace # dadda
TYPE_ADD ?= add # sub
SIZE ?= 32
CYCLE ?= 1000

osvvm:
	cd tools; ./osvvm.sh

run_mul:
	sim/run_mul.sh ${GHDL} ${TYPE_MUL} ${SIZE} ${CYCLE}

run_add:
	sim/run_add.sh ${GHDL} ${TYPE_ADD} ${SIZE} ${CYCLE}

all: osvvm run_mul run_add
