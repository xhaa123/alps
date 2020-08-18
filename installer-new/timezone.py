#!/usr/bin/env python

import gi
gi.require_version('Gtk', '3.0')

from gi.repository import Gtk

from basecard import BaseCard

import misc
import csv
misc.apply_style()


label = '''
<b>Select your timezone</b>
'''
class Timezone(BaseCard):
	def __init__(self, context):
		BaseCard.__init__(self, 'Step 3 of 7 : Timezone', context)

		self.label = Gtk.Label(label='', xalign=0)
		self.label.set_markup(label)
		self.label.set_hexpand(True)
		self.theBox.pack_start(self.label, False, True, 0)

		with open('/opt/installer-new/zone.csv') as zonefile:
			self.timezones = list(csv.reader(zonefile))

		self.timezone_list = list()
		for timezone in self.timezones:
			self.timezone_list.append(timezone[2])

		self.timezone_list.sort()

		self.timezone = Gtk.ListBox()
		self.timezone.set_selection_mode(Gtk.SelectionMode.SINGLE)
		for tzdata in self.timezone_list:
			listbox_row = Gtk.ListBoxRow()
			listbox_row.data = tzdata
			listbox_row.add(Gtk.Label(tzdata, xalign=0))
			self.timezone.add(listbox_row)

		scrolled_window = Gtk.ScrolledWindow()
		scrolled_window.set_hexpand(True)
		scrolled_window.set_vexpand(True)
		scrolled_window.add(self.timezone)

		self.theBox.pack_start(scrolled_window, True, True, 0)

	def get_data(self):
		return {
			'timezone': self.timezone.get_selected_row().data
		}

	def validate(self):
		if self.timezone.get_selected_row() == None:
			return [False, 'Error', 'Please select a timezone.']
		else:
			return [True, None, None]


