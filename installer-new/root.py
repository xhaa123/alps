#!/usr/bin/env python

import gi
gi.require_version('Gtk', '3.0')

from gi.repository import Gtk

from basecard import BaseCard

import misc
misc.apply_style()


label = '''
<b>Enter the password for root user(Administrator). This account would have super user privileges.</b>
'''
class Root(BaseCard):
	def __init__(self, context):
		BaseCard.__init__(self, 'Step 6 of 7 : Root password details', context)

		self.label = Gtk.Label(label='', xalign=0)
		self.label.set_markup(label)
		self.theBox.pack_start(self.label, False, True, 0)

		self.label1 = Gtk.Label('Enter the root password:', xalign=0)
		self.label2 = Gtk.Label('Re-Enter the root password:', xalign=0)

		self.password = Gtk.Entry()
		self.password.set_hexpand(True)
		self.password.set_visibility(False)
		self.retype_password = Gtk.Entry()
		self.retype_password.set_hexpand(True)
		self.retype_password.set_visibility(False)

		self.theBox.pack_start(self.label1, False, True, 0)
		self.theBox.pack_start(self.password, False, True, 0)
		self.theBox.pack_start(self.label2, False, True, 0)
		self.theBox.pack_start(self.retype_password, False, True, 0)

	def validate(self):
		validation_result = True
		invalid_fields = list()
		if self.password.get_text() == None or self.password.get_text() == '':
			validation_result = False
			invalid_fields.append('Password')
		if self.retype_password.get_text() == None or self.retype_password.get_text() == '':
			validation_result = False
			invalid_fields.append('Re-Entered password ')
		if self.retype_password.get_text() != self.password.get_text():
			validation_result = False
			invalid_fields.append('The two passwords that you have entered do not match')
		return [validation_result, "Please provide valid data for these fields:", ', '.join(invalid_fields)]

	def get_data(self):
		return {
			'root_password': self.password.get_text(),
			'root_password_again': self.retype_password.get_text()
		}


