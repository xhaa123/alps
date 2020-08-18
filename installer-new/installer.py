#!/usr/bin/env python

import gi
gi.require_version('Gtk', '3.0')

from gi.repository import Gtk
from gi.repository import Gdk

import stack
import buttons
import misc
import header
import sys
import os

class Installer(Gtk.Window):
	def __init__(self):
		Gtk.Window.__init__(self, title='AryaLinux Installer')

		self.context = dict()
		self.context['main_window'] = self
		self.context['installation_cmd'] = [ '/usr/bin/sudo', '/bin/bash', '/opt/installer-new/backend.sh' ]
		self.context['install_started'] = False

		self.header = header.Header()
		self.vbox = Gtk.VBox(spacing=5)
		self.stack = stack.Stack(self.context, buttons.prevButton, buttons.nextButton, buttons.installButton)
		self.buttons = buttons.Buttons(self.context)

		self.vbox.pack_start(self.header, False, True, 0)
		self.vbox.pack_start(self.stack, True, True, 0)
		self.vbox.pack_start(Gtk.HSeparator(), False, True, 0)
		self.vbox.pack_start(self.buttons, False, True, 0)
		self.add(self.vbox)

		# Set half the size of screen and center
		screen = Gdk.Screen.get_default()
		self.set_size_request(screen.get_width()/2, screen.get_height()/2)
		self.set_position(Gtk.WindowPosition.CENTER_ALWAYS)
		self.set_border_width(5)

		buttons.cancelButton.connect('clicked', self.confirm_cancellation)

		self.set_border_width(5)
		self.context['install_started'] = False
		self.context['input_started'] = True

	def confirm_cancellation(self, widget):
		if os.path.exists('/tmp/installation-completed'):
			sys.exit()
		dialog = Gtk.MessageDialog(self, 0, Gtk.MessageType.QUESTION, Gtk.ButtonsType.YES_NO, "Cancel Installation?")
		msg = None
		if self.context['install_started']:
			msg = "The system may end up in an unusable state if you cancel. Are you sure you want to cancel the installation?"
		elif self.context['input_started']:
			msg = "Are you sure you want to cancel the installation?"
		dialog.format_secondary_text(msg)
		response = dialog.run()
		if response == Gtk.ResponseType.YES:
			Gtk.main_quit(widget)
		elif response == Gtk.ResponseType.NO:
			dialog.destroy()

misc.apply_style()
installer = Installer()
installer.set_resizable(False)
installer.connect('destroy', Gtk.main_quit)
installer.show_all()
Gtk.main()
