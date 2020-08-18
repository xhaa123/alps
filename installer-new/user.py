#!/usr/bin/env python

import gi
gi.require_version('Gtk', '3.0')

from gi.repository import Gtk

from basecard import BaseCard

import misc
misc.apply_style()


label = '''
<b>Enter the following details so that AryaLinux can be configured for your usage:</b>
'''
class User(BaseCard):
	def __init__(self, context):
		BaseCard.__init__(self, 'Step 5 of 7 : User details', context)

		self.label = Gtk.Label(label='', xalign=0)
		self.label.set_markup(label)
		self.theBox.pack_start(self.label, False, True, 0)

		self.label1 = Gtk.Label('Enter your full name:', xalign=0)
		self.label2 = Gtk.Label('Enter a name for the computer:', xalign=0)
		self.label3 = Gtk.Label('Enter username:', xalign=0)
		self.label4 = Gtk.Label('Enter password:', xalign=0)
		self.label5 = Gtk.Label('Re-Enter the password:', xalign=0)

		self.full_name = Gtk.Entry()
		self.full_name.set_hexpand(True)
		self.computer_name = Gtk.Entry()
		self.computer_name.set_hexpand(True)
		self.username = Gtk.Entry()
		self.username.set_hexpand(True)
		self.password = Gtk.Entry()
		self.password.set_hexpand(True)
		self.password.set_visibility(False)
		self.retype_password = Gtk.Entry()
		self.retype_password.set_hexpand(True)
		self.retype_password.set_visibility(False)

		self.theBox.pack_start(self.label1, False, True, 0)
		self.theBox.pack_start(self.full_name, False, True, 0)
		self.theBox.pack_start(self.label2, False, True, 0)
		self.theBox.pack_start(self.computer_name, False, True, 0)
		self.theBox.pack_start(self.label3, False, True, 0)
		self.theBox.pack_start(self.username, False, True, 0)
		self.theBox.pack_start(self.label4, False, True, 0)
		self.theBox.pack_start(self.password, False, True, 0)
		self.theBox.pack_start(self.label5, False, True, 0)
		self.theBox.pack_start(self.retype_password, False, True, 0)

	def validate(self):
		validation_result = True
		invalid_fields = list()
		if self.full_name.get_text() == None or self.full_name.get_text() == '':
			validation_result = False
			invalid_fields.append('Full Name')
		if self.computer_name.get_text() == None or self.computer_name.get_text() == '':
			validation_result = False
			invalid_fields.append('Computer Name')
		if self.username.get_text() == None or self.username.get_text() == '':
			validation_result = False
			invalid_fields.append('Username')
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
			'full_name': self.full_name.get_text(),
			'computer_name': self.computer_name.get_text(),
			'username': self.username.get_text(),
			'password': self.password.get_text(),
			'password_again': self.retype_password.get_text()
		}


