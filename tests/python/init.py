#!/usr/bin/env python

from sys import path

path.insert(0,'../..')
from marbl_interface import marbl_interface_wrapper_class

marbl_instance = marbl_interface_wrapper_class()
marbl_instance.init()
marbl_instance.print_log()
marbl_instance.shutdown()
marbl_instance.print_timer_summary()