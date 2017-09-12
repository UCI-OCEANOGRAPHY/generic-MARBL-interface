#!/usr/bin/env python

from marbl_interface import marbl_interface_wrapper_class

marbl_instance = marbl_interface_wrapper_class()
marbl_instance.init()
marbl_instance.print_log()
marbl_instance.shutdown()
