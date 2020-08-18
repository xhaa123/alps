#!/usr/bin/env python

import gi
gi.require_version('Gtk', '3.0')

from gi.repository import Gtk

from basecard import BaseCard

import misc
misc.apply_style()

label = '''
<b>Please select the locale, keyboard layout and paper size</b>
'''

class Locale(BaseCard):
	def __init__(self, context):
		BaseCard.__init__(self, 'Step 4 of 7 : Locale selection', context)

		self.selected_locale = None

		self.locale_store = []
		locales = misc.list_locales()
		for locale in locales:
			self.locale_store.append(locale)
		self.keymap_store = []
		keymaps = misc.list_keymaps()
		for keymap in keymaps:
			self.keymap_store.append(keymap)

		self.label = Gtk.Label(label='', xalign=0)
		self.label.set_markup(label)
		self.label.set_hexpand(True)
		self.theBox.pack_start(self.label, False, True, 0)

		self.label1 = Gtk.Label('Choose Locale:', xalign=0)
		self.label2 = Gtk.Label('Choose Keyboard Layout:', xalign=0)
		self.label3 = Gtk.Label('Paper Size', xalign=0)

		self.locale_list = self.create_list(self.locale_store)
		scrolledwindow1 = Gtk.ScrolledWindow()
		scrolledwindow1.set_hexpand(True)
		scrolledwindow1.set_vexpand(True)
		scrolledwindow1.add(self.locale_list)

		self.keymaps = self.create_list(self.keymap_store)
		scrolledwindow2 = Gtk.ScrolledWindow()
		scrolledwindow2.set_hexpand(True)
		scrolledwindow2.set_vexpand(True)
		scrolledwindow2.add(self.keymaps)

		self.paper_size_store = Gtk.ListStore(str)
		self.paper_sizes = list()
		self.more_paper_sizes = ['DL', 'letter', 'legal', 'tabloid', 'ledger', 'statement', 'executive', 'com10', 'monarch']
		for char in ['A', 'B', 'C', 'D']:
			for i in range(0,7):
				self.paper_sizes.append(char + str(i))
		self.paper_sizes.extend(self.more_paper_sizes)

		for paper_size in self.paper_sizes:
			self.paper_size_store.append([paper_size])

		self.paper_size = Gtk.ComboBox.new_with_model(self.paper_size_store)
		self.paper_size.set_entry_text_column(0)
		renderer_text = Gtk.CellRendererText()
		self.paper_size.pack_start(renderer_text, True)
		self.paper_size.add_attribute(renderer_text, "text", 0)
		self.paper_size.set_active(4)

		self.grid = Gtk.Grid()
		self.grid.set_row_spacing(5)
		self.grid.set_column_spacing(5)
		self.grid.set_hexpand(True)
		self.grid.set_vexpand(True)

		self.grid.attach(self.label1, 0, 0, 1, 1)
		self.grid.attach(self.label2, 1, 0, 1, 1)
		self.grid.attach(scrolledwindow1, 0, 1, 1, 1)
		self.grid.attach(scrolledwindow2, 1, 1, 1, 1)
		self.grid.attach(self.label3, 0, 2, 2, 1)
		self.grid.attach(self.paper_size, 0, 3, 2, 1)

		self.theBox.pack_start(self.grid, True, True, 0)

	def create_list(self, data_list):
		listbox = Gtk.ListBox()
		listbox.set_selection_mode(Gtk.SelectionMode.SINGLE)

		for data in data_list:
			row = Gtk.ListBoxRow()
			row.data = data
			row.add(Gtk.Label(row.data, xalign=0))
			listbox.add(row)
		return listbox

	def get_data(self):
		return {
			'locale': self.locale_list.get_selected_row().data,
			'keymap': self.keymaps.get_selected_row().data,
			'paper_size': self.paper_size_store[self.paper_size.get_active()][0]
		}

	def validate(self):
		error_message = None
		if self.locale_list.get_selected_row() == None:
			error_message = 'Please select a locale'
		if self.keymaps.get_selected_row() == None:
			error_message = 'Please select a keymap'
		if self.paper_size.get_active() == None:
			error_message = 'Please select a paper size'
		if error_message != None:
			return [False, 'Error', error_message]
		else:
			return [True, None, None]


