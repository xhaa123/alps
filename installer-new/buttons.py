#!/usr/bin/env python

import gi
gi.require_version('Gtk', '3.0')

from gi.repository import Gtk, GLib

import subprocess
import threading
import time
import os

prevButton = Gtk.Button(label='Back')
prevButton.set_size_request(100, -1)
nextButton = Gtk.Button('Next')
nextButton.set_size_request(100, -1)
cancelButton  = Gtk.Button('Close')
cancelButton.set_size_request(100, -1)
installButton  = Gtk.Button('Install')
installButton.set_size_request(100, -1)
gparted  = Gtk.Button('Partition Disk')
gparted.set_size_request(150, -1)

class Buttons(Gtk.HBox):
	def __init__(self, context):
		Gtk.HBox.__init__(self, spacing=5)
		self.context = context

		self.innerBox = Gtk.Grid()
		self.buttonBox = Gtk.HBox(spacing=5)

		self.buttonBox.pack_end(cancelButton, False, False, 0)
		self.buttonBox.pack_end(installButton, False, False, 0)
		self.buttonBox.pack_end(nextButton, False, False, 0)
		self.buttonBox.pack_end(prevButton, False, False, 0)

		self.innerBox.attach(self.buttonBox, 1, 0, 1, 1)
		self.buttonBox.set_hexpand(True)
		self.innerBox.attach(gparted, 0, 0, 1, 1)

		self.pack_start(self.innerBox, True, True, 0)

		gparted.connect('clicked', self.open_gparted)
		installButton.connect('clicked', self.start_installation)

	def open_gparted(self, btn):
		if os.path.exists('/usr/bin/partitionmanager'):
			process = subprocess.Popen('partitionmanager'.split())
		else:
			process = subprocess.Popen('sudo gparted'.split())
		process.communicate()
		self.context['device_screen'].enter_card()

	def start_installation(self, btn):
		self.context['install_started'] = True
		self.context['input_started'] = False
		self.create_install_properties_file()
		pty = self.context['pty']
		response = pty.spawn_async(
			None,
			self.context['installation_cmd'],
			['PATH=' + os.environ['PATH'], None],
			GLib.SpawnFlags.DO_NOT_REAP_CHILD,
			None,
			None,
			-1,
			None,
			self.on_process_end)
		btn.set_sensitive(False)
		self.context['the_stack'].set_visible_child_name('status_card')

	def on_process_end(self, pty, task):
		self.context['install_started'] = False

	def create_install_properties_file(self):
		print(self.context)
		persistent_items = ['full_name', 'username', 'boot_partition', 'paper_size', 'swap_partition', 'keymap', 'home_partition', 'computer_name', 'timezone', 'device', 'locale', 'password', 'root_password', 'root_partition']
		with open('/tmp/install-properties', 'w') as fp:
			for key, value in self.context.items():
				if key in persistent_items:
					fp.write(key + '="' + value + '"\n')

	def cancel_installation(self, btn):
		if len(self.context['buffer'].IO_WATCH_ID):
			for id_ in self.context['buffer'].IO_WATCH_ID:
				GObject.source_remove(id_)
			self.context['buffer'].IO_WATCH_ID = tuple()
			self.proc.terminate()
			return

