#!/usr/bin/env python

import gi
gi.require_version('Gtk', '3.0')

from gi.repository import Gtk
from gi.repository import Gdk

import subprocess
import json

devices_list_cmd = 'sudo lsblk -Jnipo NAME'

device_tree = None

def apply_style():
	with open('/opt/installer-new/style', 'r') as fp:
		css = fp.read()
		style_provider = Gtk.CssProvider()
		style_provider.load_from_data(css)
		Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)


def get_device_list():
	global device_tree
	devices = list()
	output = subprocess.check_output(devices_list_cmd.split())
	device_tree = json.loads(output)
	block_devices = device_tree['blockdevices']
	devices.append('-')
	for block_device in block_devices:
		if 'children' in block_device and len(block_device['children']) != 0:
			devices.append(block_device['name'])
	return devices

def get_partitions_for_device(selected_device):
	partitions = list()
	process = subprocess.Popen(('/opt/installer-new/shell-cmd.sh 1 ' + selected_device).split(), stdout=subprocess.PIPE)
	(output, return_code) = process.communicate()
	outlines = output.splitlines()[0:]
	for outline in outlines:
		parts = outline.split()
		partitions.append([parts[0], parts[1], parts[2], parts[3], parts[4], " ".join(parts[5:])])
	return partitions

def enter_card(card_name, stack):
	card = stack.get_child_by_name(card_name)
	card.enter_card()

def list_locales():
	process = subprocess.Popen('sudo localectl list-locales'.split(), stdout=subprocess.PIPE)
	(output, return_code) = process.communicate()
	return output.splitlines()

def list_keymaps():
	process = subprocess.Popen('sudo localectl list-keymaps'.split(), stdout=subprocess.PIPE)
	(output, return_code) = process.communicate()
	return output.splitlines()

def show_error(window, heading, message):
	dialog = Gtk.MessageDialog(window, 0, Gtk.MessageType.WARNING, Gtk.ButtonsType.CLOSE, heading)
	dialog.format_secondary_text(message)
	response = dialog.run()
	dialog.destroy()

