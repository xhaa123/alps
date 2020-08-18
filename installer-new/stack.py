#!/usr/bin/env python

import gi
gi.require_version('Gtk', '3.0')

from gi.repository import Gtk
from gi.repository import Gdk

import misc
import intro
import device
import partition
import locale
import user
import root
import status
import timezone
import finalinfo


class Stack(Gtk.VBox):
	def __init__(self, context, prev, next, install):
		Gtk.VBox.__init__(self)
		self.prev = prev
		self.next = next
		self.install = install
		self.context = context

		intro_card = intro.Intro(self.context)
		device_card = device.Device(self.context)
		partition_card = partition.Partition(self.context)
		timezone_card = timezone.Timezone(self.context)
		locale_card = locale.Locale(self.context)
		user_card = user.User(self.context)
		root_card = root.Root(self.context)
		finalinfo_card = finalinfo.FinalInfo(self.context)
		status_card = status.Status(self.context)

		self.card_names = ['intro_card', 'device_card', 'partition_card', 'timezone_card', 'locale_card', 'user_card', 'root_card', 'finalinfo_card', 'status_card']
		self.cards = [intro_card, device_card, partition_card, timezone_card, locale_card, user_card, root_card, finalinfo_card, status_card]

		self.the_stack = Gtk.Stack()
		self.the_stack.set_hexpand(True)
		self.the_stack.set_vexpand(True)

		self.context['the_stack'] = self.the_stack

		self.pack_start(self.the_stack, True, True, 0)
		self.set_name('stack')

		# add the cards to the stack

		self.the_stack.add_titled(intro_card, 'intro_card', 'Introduction')
		self.the_stack.add_titled(device_card, 'device_card', 'Device')
		self.the_stack.add_titled(partition_card, 'partition_card', 'Partition')
		self.the_stack.add_titled(timezone_card, 'timezone_card', 'Timezone')
		self.the_stack.add_titled(locale_card, 'locale_card', 'Locale')
		self.the_stack.add_titled(user_card, 'user_card', 'User')
		self.the_stack.add_titled(root_card, 'root_card', 'Root')
		self.the_stack.add_titled(finalinfo_card, 'finalinfo_card', 'Confirmation')
		self.the_stack.add_titled(status_card, 'status_card', 'Status')

		self.prev.connect('clicked', self.nav_prev)
		self.next.connect('clicked', self.nav_next)

		self.current_card = self.card_names[0]
		self.current_index = 0

		self.prev.set_sensitive(False)
		self.install.set_sensitive(False)

	def nav_prev(self, btn):
		if self.current_index > 0:
			self.current_index = self.current_index - 1
			self.current_card = self.card_names[self.current_index]
			self.the_stack.set_visible_child_name(self.current_card)
			misc.enter_card(self.current_card, self.the_stack)
		if self.current_index == 0:
			self.prev.set_sensitive(False)
			self.install.set_sensitive(False)
		else:
			self.next.set_sensitive(True)
			self.install.set_sensitive(False)

	def nav_next(self, btn):
		if not self.cards[self.current_index].exit_card():
			return
		if self.current_index < len(self.card_names) - 1:
			self.current_index = self.current_index + 1
			self.current_card = self.card_names[self.current_index]
			self.the_stack.set_visible_child_name(self.current_card)
			misc.enter_card(self.current_card, self.the_stack)
			self.install.set_sensitive(False)
		if self.current_index == len(self.card_names) - 2:
			self.next.set_sensitive(False)
			self.install.set_sensitive(True)
		else:
			self.prev.set_sensitive(True)
			self.install.set_sensitive(False)

