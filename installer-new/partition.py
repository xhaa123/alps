#!/usr/bin/env python

import gi
gi.require_version('Gtk', '3.0')

from gi.repository import Gtk

from basecard import BaseCard

import misc
misc.apply_style()

label = '''
<b>Select the partition to be used as root (/)</b>
<i>You may optionally select the home partition which would be used as /home.
A swap partition can also be chosed if the system's RAM is less than 4GB.</i>
If unsure then select a partition for root only, whose size is 20GB or more.
'''

class Partition(BaseCard):
	def __init__(self, context):
		BaseCard.__init__(self, 'Step 2 of 7 : Partition selection', context)

		self.label = Gtk.Label(label, xalign=0)
		self.label.set_markup(label)
		self.label.set_hexpand(True)
		self.theBox.pack_start(self.label, False, True, 5)

		self.selected_partition = None

		self.partition_store = Gtk.ListStore(str)

		self.root_part_combo = self.create_combo(self.partition_store)
		self.home_part_combo = self.create_combo(self.partition_store)
		self.boot_part_combo = self.create_combo(self.partition_store)
		self.swap_part_combo = self.create_combo(self.partition_store)

		self.combos = [self.root_part_combo, self.home_part_combo, self.boot_part_combo, self.swap_part_combo]

		self.theBox.pack_start(Gtk.Label('Root (/) *', xalign=0), False, True, 0)
		self.theBox.pack_start(self.root_part_combo, False, True, 0)
		self.theBox.pack_start(Gtk.Label('Home (/home)', xalign=0), False, True, 0)
		self.theBox.pack_start(self.home_part_combo, False, True, 0)
		self.theBox.pack_start(Gtk.Label('Boot (/boot)', xalign=0), False, True, 0)
		self.theBox.pack_start(self.boot_part_combo, False, True, 0)
		self.theBox.pack_start(Gtk.Label('Swap', xalign=0), False, True, 0)
		self.theBox.pack_start(self.swap_part_combo, False, True, 0)

	def on_toggle(self, cell, path, model):
		pass

	def on_combo_changed(self, widget, path, text):
		pass

	def enter_card(self):
		device = self.context['device_screen'].get_data()['device']
		if self.selected_partition != device:
			self.selected_partition = device
			self.partition_store.clear()
			self.partitions = misc.get_partitions_for_device(device)
			self.partition_store.append(['-'])
			for partition in self.partitions:
				self.partition_store.append([self.string_from_part_info(partition)])
			for combo in self.combos:
				combo.set_active(0)
			self.partitions.insert(0, '-')

	def string_from_part_info(self, part_info):
		return part_info[0] + ', Size: ' + part_info[1] + ', Start : ' + part_info[2] + ' End: ' + part_info[3] + ' Sectors: ' + part_info[4] + ', Type: ' + part_info[5]

	def get_data(self):
		return {
			'root_partition': self.partitions[self.root_part_combo.get_active()][0],
			'home_partition': self.partitions[self.home_part_combo.get_active()][0],
			'boot_partition': self.partitions[self.boot_part_combo.get_active()][0],
			'swap_partition': self.partitions[self.swap_part_combo.get_active()][0]
		}

	def validate(self):
		error_message = None
		if self.root_part_combo.get_active() == 0:
			return [False, 'Error', 'Please select a partition for Root(/)']
		return [True, None, None]

	def create_combo(self, list_store):
		combo = Gtk.ComboBox()
		renderer_text = Gtk.CellRendererText()
		combo.pack_start(renderer_text, True)
		combo.add_attribute(renderer_text, "text", 0)
		combo.set_model(list_store)
		return combo

