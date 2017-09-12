#!/usr/bin/env python

from ctypes import *

class marbl_interface_wrapper_class(object):

  def __init__(self):
    self._MARBL = cdll.LoadLibrary("marbl_lib/marbl_interface.so")

  def init(self):
    nt = c_int(0)
    if (_init_marbl(self._MARBL, byref(nt)) == 0):
      print "Initialized MARBL with %d tracers" % nt.value
    else:
      print "Error initializing MARBL"

  def shutdown(self): 
    if (_shutdown_marbl(self._MARBL) == 0):
      print "Successfully shutdown MARBL instance"
    else:
      print "Error shutting down MARBL"

  def print_log(self):
    _print_log(self._MARBL)

def _init_marbl(libmarbl, nt):
  stat = libmarbl.__marbl_interface_wrapper_mod_MOD_init_marbl(nt)
  return(stat)

def _shutdown_marbl(libmarbl):
  stat = libmarbl.__marbl_interface_wrapper_mod_MOD_shutdown_marbl()
  return(stat)

def _print_log(libmarbl):
  libmarbl.__marbl_interface_wrapper_mod_MOD_print_marbl_log()
