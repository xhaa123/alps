#!/usr/bin/env python

import gi
gi.require_version('Gtk', '3.0')

from gi.repository import Gtk

from basecard import BaseCard
import misc
misc.apply_style()

descriptionText = '''
This installer would install aryalinux to the hard disk.
You need to have a partition of size at least 20GB where AryaLinux can be installed.
Click the 'Partition Disk' button below to open GParted and create a partition if you do not have one.

Other System requirements are:

<b>Processor Architecture</b>: Intel 64 bit
<b>Processor clock speed</b>: Faster the processor better it is
<b>RAM</b>: 2 GB or higher
<b>Disk space</b>: 20GB root partition, swap partition twice RAM size if RAM less than 4GB
'''
class Intro(BaseCard):
	def __init__(self, context):
		BaseCard.__init__(self, 'Welcome to AryaLinux', context)

		self.label2 = Gtk.Label(descriptionText, xalign=0, yalign=0)
		self.label2.set_hexpand(True)
		self.label2.set_vexpand(True)
		self.label2.set_line_wrap(True)
		self.label2.set_markup(descriptionText)
		self.label2.set_justify(Gtk.Justification.FILL)
		self.theBox.pack_start(self.label2, True, True, 0)

