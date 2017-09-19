#!/usr/bin/env python

# This file provides a python interface to subroutines in the marbl_interface_wrapper_mod.F90 Fortran module
# Create a marbl_interface_wrapper_class instance, and use the methods provided
# by the class to call the Fortran subroutines

from ctypes import *
import os

#################################
# marbl_interface_wrapper_class #
#################################

class marbl_interface_wrapper_class(object):

  def __init__(self):
    # Want to load library from path relative to this file
    libname = "marbl_lib/marbl_interface.so"
    dirname = os.path.dirname(__file__)
    if len(dirname) > 0:
      libname = "%s/%s" % (dirname, libname)
    self._MARBL = cdll.LoadLibrary(libname)

  def init(self, delta_z, zw, zt):
    nt, stat = _init_marbl(self._MARBL, delta_z, zw, zt)
    if (stat == 0):
      print "Initialized MARBL with %d tracers" % nt
    else:
      print "Error initializing MARBL"
    return _get_log(self._MARBL)

  def shutdown(self):
    if (_shutdown_marbl(self._MARBL) == 0):
      print "Successfully shutdown MARBL instance"
    else:
      print "Error shutting down MARBL"

  def print_timer_summary(self):
    _print_timer_summary(self._MARBL)

  def put_setting(self, line_in):
    if (_put_setting(self._MARBL, line_in) != 0):
      print "Error calling put_setting"

#####################################################################
# Calls into marbl_interface.so are made from the subroutines below #
# (They are all called from the marbl_interface_wrapper_class       #
# and should not ever be called directly from anywhere else)        #
#####################################################################

def _init_marbl(libmarbl, delta_z, zw, zt):
  # convert marbl_domain values to ctype
  nlev = len(delta_z)
  c_array = c_double * nlev

  # arguments to MARBL must use ctypes
  c_delta_z = c_array(*delta_z)
  c_zw = c_array(*zw)
  c_zt = c_array(*zt)
  c_nlev = c_int(nlev)
  c_nt = c_int(0)

  stat = libmarbl.__marbl_interface_wrapper_mod_MOD_init_marbl(c_delta_z, c_zw, c_zt, byref(c_nlev), byref(c_nt))
  return(c_nt.value, stat)

#####################################################################

def _shutdown_marbl(libmarbl):
  stat = libmarbl.__marbl_interface_wrapper_mod_MOD_shutdown_marbl()
  return(stat)

#####################################################################

def _get_log(libmarbl):
  log_ptr = ((c_char_p*384)*600)()
  c_cnt = c_int(0)
  log = []
  libmarbl.__marbl_interface_wrapper_mod_MOD_get_marbl_log(byref(log_ptr), byref(c_cnt))
  log_as_str = log_ptr[0][0]
  for n in range(0,c_cnt.value):
    first=n*384
    last=(n+1)*384-1
    log.append(log_as_str[first:last].strip())
  return log

#####################################################################

def _print_timer_summary(libmarbl):
  libmarbl.__marbl_interface_wrapper_mod_MOD_print_timer_summary()

#####################################################################

def _put_setting(libmarbl, line_in):
  line_len = c_int(len(line_in))
  stat = libmarbl.__marbl_interface_wrapper_mod_MOD_put_setting_with_line_len(c_char_p(line_in), byref(line_len))
  return(stat)

#####################################################################

def print_log(log):
  for entry in log:
    print entry
