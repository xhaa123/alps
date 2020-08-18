#!/usr/bin/env python

import gi
gi.require_version('Gtk', '3.0')

from gi.repository import Gtk

from basecard import BaseCard
from functions import preinstall_check_valid

import misc
misc.apply_style()

label = '''
<b>Please choose the Hard Disk where you would like to install AryaLinux.</b>
<i>You need to have at least a partition for root of size greater than 20GB in the Hard Disk.
Additionally you may have define a partition for /home and swap.</i>
'''
class Device(BaseCard):
	def __init__(self, context):
		BaseCard.__init__(self, 'Step 1 of 7 : Device Selection', context)

		self.label = Gtk.Label(label, xalign=0)
		self.label.set_markup(label)
		self.label.set_hexpand(True)
		self.theBox.pack_start(self.label, False, True, 0)

		self.device_combo = Gtk.ComboBox()
		self.device_combo.set_hexpand(True)
		self.theBox.pack_start(self.device_combo, False, True, 0)

		self.device_store = Gtk.ListStore(str)

		self.device_combo.set_model(self.device_store)
		self.renderer_text = Gtk.CellRendererText()
		self.device_combo.pack_start(self.renderer_text, True)
		self.device_combo.add_attribute(self.renderer_text, "text", 0)
		self.device_combo.set_active(0)

		#self.context['device'] = self.devices[self.device_combo.get_active()]
		self.context['device_screen'] = self

	def enter_card(self):
		self.devices = misc.get_device_list()
		self.device_store.clear()
		for device in self.devices:
			self.device_store.append([device])
		if len(self.devices) <= 1:
			misc.show_error(self.context['main_window'], 'Error', 'Could not read the devices in this system. Could you please check if there are any installable devices and they are partitioned? If not please click Partition Disk and partition the disk first and then restart the installer.')

	def get_data(self):
		return {'device': self.devices[self.device_combo.get_active()]}

	def validate(self):
		error_message = None
		device = self.devices[self.device_combo.get_active()]
		if device == '-':
			return [False, 'Error', 'Please select a device before proceeding.']
		if not preinstall_check_valid(device):
			return [False, 'Error', 'The device: ' + device + ' does not have an MSDOS partition table. Please reboot in UEFI mode and restart installer.']
		return [True, None, None]


