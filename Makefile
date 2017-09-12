# This Makefile uses gfortran to build the MARBL library with the -fPIC flag
# The mex target then uses these object files when building the marbl interface
# for use with mex / Matlab
#
# Currently assumes that ./marbl_src is a soft-link to $MARBL/src
# Eventually this may be included as a subtree or submodule

all: mex
.PHONY: mex
mex: marbl_lib

.PHONY: marbl_lib
marbl_lib:
	cd marbl_include ; $(MAKE) -f ../marbl_src/Makefile FC=gfortran FCFLAGS="-fPIC" USE_DEPS=TRUE OBJ_DIR=. INC_DIR=. LIB_DIR=../marbl_lib ../marbl_lib/libmarbl.a ; cd ..

.PHONY: clean
clean:
	rm -f *.mod *.mexa64 *.o
	rm -f marbl_include/*.mod marbl_include/*.o marbl_include/*.d marbl_lib/libmarbl.*
