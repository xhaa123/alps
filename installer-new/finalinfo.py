#!/usr/bin/env python

import gi
gi.require_version('Gtk', '3.0')

from gi.repository import Gtk

from basecard import BaseCard

import misc
misc.apply_style()

label='''
<b>Please confirm the details you have given one last time.</b>
'''
sublabel = '''<i>If you want the installer to proceed with these details, click 'Install' and the installation would start.
<span foreground="red">Once the installation would start, it would not be possible to revert back.</span>
So if you want to change anything now, please go back to the previous screens and make changes.</i>
'''
class FinalInfo(BaseCard):
	def __init__(self, context):
		BaseCard.__init__(self, 'Step 7 of 7 : Confirmation', context)

		self.label = Gtk.Label(label, xalign=0)
		self.label.set_markup(label)
		self.theBox.pack_start(self.label, False, True, 0)
		self.sublabel = Gtk.Label(sublabel, xalign=0)
		self.sublabel.set_markup(sublabel)
		self.theBox.pack_start(self.sublabel, False, True, 0)

		self.installation_data_table = Gtk.TreeView()
		self.installation_data_table.set_rules_hint(True)
		self.installation_data = Gtk.ListStore(str, str)
		self.installation_data_table.set_model(self.installation_data)
		for i, heading in enumerate(['Property', 'Value']):
			renderer = Gtk.CellRendererText()
			column = Gtk.TreeViewColumn(heading, renderer, text=i)
			self.installation_data_table.append_column(column)
		self.installation_data_table.set_headers_visible(True)

		scrolled_window = Gtk.ScrolledWindow()
		scrolled_window.add(self.installation_data_table)
		scrolled_window.set_hexpand(True)
		scrolled_window.set_vexpand(True)

		self.theBox.pack_start(scrolled_window, True, True, 0)

		self.labels = [
			'Bootloader Device',
			'Root Partition',
			'Home Partition',
			'Boot Partition',
			'Swap Partition',
			'Timezone',
			'Locale',
			'Keymap',
			'Paper Size',
			'Full Name',
			'Computer Name',
			'Username',
			'User Password',
			'Root Password'
		]
		self.key_indices = {
			1: 'device',
			2: 'root_partition',
			3: 'home_partition',
			4: 'boot_partition',
			5: 'swap_partition',
			6: 'timezone',
			7: 'locale',
			8: 'keymap',
			9: 'paper_size',
			10: 'full_name',
			11: 'computer_name',
			12: 'username',
			13: 'password',
			14: 'root_password'
		}
		self.populate_data_in_grid()

	def populate_data_in_grid(self):
		for label in self.labels:
			self.installation_data.append([label, ''])

	def refresh_data(self):
		self.installation_data.clear()
		for i, label in enumerate(self.labels):
			if i in [1, 2, 3]:
				if ( i == 2 or i == 3 ) and self.key_indices[i + 1] not in self.context:
					continue
				self.installation_data.append([label, self.context[self.key_indices[i + 1]]])
			elif i == 12 or i == 13:
				self.installation_data.append([label, self.hide_password(self.context[self.key_indices[i + 1]])])
			else:
				self.installation_data.append([label, self.context[self.key_indices[i + 1]]])
				

	def enter_card(self):
		self.refresh_data()

	def hide_password(self, password):
		result = ''
		for p in password:
			result = result + '*'
		return result

