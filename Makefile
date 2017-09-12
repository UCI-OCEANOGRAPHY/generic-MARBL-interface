# This Makefile uses gfortran to build the MARBL library with the -fPIC flag
# The mex target then uses these object files when building the marbl interface
# for use with mex / Matlab
#
# Currently assumes that ./marbl_src is a soft-link to $MARBL/src
# Eventually this may be included as a subtree or submodule

MARBL_LIB=marbl_lib/libmarbl.a
INTERFACE_SRC=marbl_interface_wrapper_mod.F90
MEX_INTERFACE=$(INTERFACE_SRC:.F90=.mexa64)
MEX_DRIVER_SRC=mex_marbl_driver.F90
MEX_DRIVER=$(MEX_DRIVER_SRC:.F90=.mexa64)

all: $(MEX_DRIVER)

$(MEX_DRIVER): $(MEX_INTERFACE) $(MEX_DRIVER_SRC)
	mex -Imarbl_include $(MEX_DRIVER_SRC) $(INTERFACE_SRC) marbl_include/*.o

$(MEX_INTERFACE): $(MARBL_LIB) $(INTERFACE_SRC)
	mex -Imarbl_include $(INTERFACE_SRC)

.PHONY: lib
lib: $(MARBL_LIB)

$(MARBL_LIB):
	cd marbl_include ; $(MAKE) -f ../marbl_src/Makefile FC=gfortran FCFLAGS="-fPIC" USE_DEPS=TRUE OBJ_DIR=. INC_DIR=. LIB_DIR=../marbl_lib ../$(MARBL_LIB) ; cd ..

.PHONY: clean
clean:
	rm -f *.mod *.mexa64 *.o

.PHONY: allclean
allclean: clean
	rm -f marbl_include/*.mod marbl_include/*.o marbl_include/*.d marbl_lib/libmarbl.*
