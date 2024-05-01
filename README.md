# Tree Multiplier Generator for VHDL and SystemVerilog

This tool generates **Wallace** and **Dadda** tree multiplier in hardware description language **VHDL** and **SystemVerilog**.

## Tools

The installation scripts of necessary tools are located in directory **tools**. These scripts need **root** permission in order to install packages and tools for simulation. Please run these scripts in directory **tools** locally.

## Design Files

After running one of below commands the automatically generated design files are located in **src/verilog** and **src/vhdl**.

## Options

**N**, **M** are for dimension of input vectors and **MAXTIME** is for number of iterations.

## Multiplication

### Dadda Tree

#### SystemVerilog

```console
make run_mul DADDA=1 VERILOG=1 N=32 M=64 MAXTIME=1000
```

#### VHDL

```console
make run_mul DADDA=1 VHDL=1 N=32 M=64 MAXTIME=1000
```

### Wallace Tree

#### SystemVerilog

```console
make run_mul WALLACE=1 VERILOG=1 N=32 M=64 MAXTIME=1000
```

#### VHDL

```console
make run_mul WALLACE=1 VHDL=1 N=32 M=64 MAXTIME=1000
```

## Addition

#### SystemVerilog

```console
make run_add ADD=1 VERILOG=1 N=32 MAXTIME=1000
```

#### VHDL

```console
make run_add ADD=1 VHDL=1 N=32 MAXTIME=1000
```

## Subtruction

#### SystemVerilog

```console
make run_add SUB=1 VERILOG=1 N=32 MAXTIME=1000
```

#### VHDL

```console
make run_add SUB=1 VHDL=1 N=32 MAXTIME=1000
```
