#!/usr/bin/env python

# This script runs some initialization routines out of the MARBL Fortran library
# This is accomplished with two intermediate layers:
# 1) marbl_interface_wrapper_mod.F90 is a Fortran module with a single marbl_interface_class object
#    and a simple Fortran interface to call methods from the class
# 2) marbl_interface.py provides a python interface to subroutines in the marbl_interface_wrapper_mod.F90 Fortran module

# We need to import the marbl_interface_wrapper_class from ../../marbl_interface.py
# Which requires adding ../../ to the python path
from sys import path
path.insert(0,'../..')
from marbl_interface import marbl_interface_wrapper_class

# To initialize MARBL, we need to provide it with information about the ocean column we want to set up
# The layer thicknesses, interface depths, and cell centers must be passed in
# delta_z: layer thickness
# zw:      MARBL assumes that the top layer interface is the surface (i.e. 0), and for each
#          level the user must provide the depth of the bottom interface
# zt:      The center of the cell
# For testing purposes, we tend to use 5 layers, each 1m thick
nlev = 5
delta_z = [1]
zw = [1]
zt = [0.5]
for n in range(1,nlev):
    delta_z.append(1)
    zw.append(zw[n-1]+delta_z[n])
    zt.append(0.5*(zw[n-1]+ zw[n]))

########################
# BEGIN CALLS TO MARBL #
########################

# (1) Initialize the class
marbl_instance = marbl_interface_wrapper_class()

# (2) Make any put statements / initialize the [Fortran] instance of marbl_interface_class
marbl_instance.put_setting('ciso_on = .true.')
marbl_instance.init(delta_z, zw, zt)

# (3) Print the status log, shutdown MARBL, and print performance timer information
marbl_instance.print_log()
marbl_instance.shutdown()
marbl_instance.print_timer_summary()
