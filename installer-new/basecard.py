#!/usr/bin/env python3

import gi
gi.require_version('Gtk', '3.0')

from gi.repository import Gtk

import misc

class BaseCard(Gtk.VBox):
	def __init__(self, title, context):
		Gtk.VBox.__init__(self)
		self.context = context

		self.headerLabel = Gtk.Label(title, xalign=0)
		self.headerLabel.set_name('header_label')
		self.headerLabel.set_hexpand(True)
		self.pack_start(self.headerLabel, False, False, 0)

		self.theBox = Gtk.VBox()
		self.theBox.set_name('the-box')
		self.theBox.set_hexpand(True)
		self.theBox.set_vexpand(True)
		self.pack_start(self.theBox, False, True, 0)

	def enter_card(self):
		pass

	def exit_card(self):
		validation_result = self.validate()
		if not validation_result[0]:
			misc.show_error(self.context['main_window'], validation_result[1], validation_result[2])
			return validation_result[0]
		else:
			self.update_context()
			return True

	def get_data(self):
		return dict()

	def validate(self):
		return [True, '', '']

	def update_context(self):
		data = self.get_data()
		for key, value in data.iteritems():
			self.context[key] = value

