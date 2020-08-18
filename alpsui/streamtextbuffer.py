#!/usr/bin/env python

import gi
gi.require_version('Gtk', '3.0')

from gi.repository import Gtk
from gi.repository import GObject

import os
import fcntl
import subprocess

class StreamTextBuffer(Gtk.TextBuffer):
	def __init__(self):
		Gtk.TextBuffer.__init__(self)
		self.IO_WATCH_ID = tuple()

	def bind_subprocess(self, proc):
		self.unblock_fd(proc.stdout)
		watch_id_stdout = GObject.io_add_watch(
			channel   = proc.stdout,
			priority_ = GObject.IO_IN,
			condition = self.buffer_update,
		)

		self.unblock_fd(proc.stderr)
		watch_id_stderr = GObject.io_add_watch(
			channel   = proc.stderr,
			priority_ = GObject.IO_IN,
			condition = self.buffer_update,
		)

		self.IO_WATCH_ID = (watch_id_stdout, watch_id_stderr)
		return self.IO_WATCH_ID

	def buffer_update(self, stream, condition):
		self.insert_at_cursor(stream.read().decode('utf-8'))
		self.textview.scroll_to_mark(self.get_insert(), 0.0, True, 0.5, 0.5)
		return True

	def unblock_fd(self, stream):
		fd = stream.fileno()
		fl = fcntl.fcntl(fd, fcntl.F_GETFL)
		fcntl.fcntl(fd, fcntl.F_SETFL, fl | os.O_NONBLOCK)

	def set_textview(self, textview):
		self.textview = textview

	def append_text(self, text):
		self.insert_at_cursor(text)
		self.textview.scroll_to_mark(self.get_insert(), 0.0, True, 0.5, 0.5)
