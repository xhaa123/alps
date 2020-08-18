#!/bin/bash

set -e

if [ "$1" == "1" ]; then
	sudo fdisk -l -o Device,Size,Start,End,Sectors,Type $2 | tr -s " " | grep "^$2"
fi
