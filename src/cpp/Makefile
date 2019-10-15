CXX = g++
OBJ = multiply_tree
SRC = multiply_tree.cpp
CFLAGS = -O3

all:
	$(CXX) $(CFLAGS) -o $(OBJ) $(SRC)

debug:
	$(CXX) -g -DDEBUG $(CFLAGS) -o $(OBJ) $(SRC)

clean:
	rm -rf $(OBJ) *.vhd
