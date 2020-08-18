#!/usr/bin/env python3

import subprocess
import os

def preinstall_check_valid(boot_device):
	if os.path.isdir('/sys/firmware/efi'):
		# We have boot in UEFI Mode
		cmd = 'sudo fdisk -l ' + boot_device + ' | grep "Disklabel type"'
		process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
		result = process.communicate()[0]
		if 'gpt' in result:
			return True
		else:
			return False
	else:
		# We have boot in legacy Mode
		cmd = 'sudo fdisk -l ' + boot_device + ' | grep "Disklabel type"'
		process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
		result = process.communicate()[0]
		if 'dos' in result:
			return True
		else:
			return False

