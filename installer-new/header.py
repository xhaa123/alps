#!/usr/bin/env python

import gi
gi.require_version('Gtk', '3.0')

from gi.repository import Gtk

import misc
misc.apply_style()

class Header(Gtk.Image):
	def __init__(self):
		Gtk.Image.__init__(self)
		self.set_from_file("/opt/installer-new/header.jpg")

