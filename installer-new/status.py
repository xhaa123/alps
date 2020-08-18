#!/usr/bin/env python

import gi
gi.require_version('Gtk', '3.0')
gi.require_version('Vte', '2.91')

from gi.repository import Gtk, GObject, Vte

import fcntl
import os

from basecard import BaseCard
from functions import preinstall_check_valid
from streamtextbuffer import StreamTextBuffer

import misc
misc.apply_style()

label = 'Installation is in progress. Please wait.'

class Status(BaseCard):
	def __init__(self, context):
		BaseCard.__init__(self, 'Installation in progress', context)

		self.label = Gtk.Label(label, xalign=0)
		self.label.set_markup(label)
		self.label.set_hexpand(True)
		self.theBox.pack_start(self.label, False, True, 0)

		self.terminal = Vte.Terminal()
		self.pty = Vte.Pty.new_sync(Vte.PtyFlags.DEFAULT)
		self.terminal.set_pty(self.pty)
		self.theBox.pack_start(self.terminal, True, True, 0)
		self.context['pty'] = self.pty

		self.context = context

	def get_data(self):
		return {}

	def validate(self):
		return [True, None, None]


