#!/bin/bash

set +e

. /tmp/install-properties

export LFS=/mnt/dest

if [ -f /mnt/dest/tmp/install-properties ]; then
    . /mnt/dest/tmp/install-properties
fi

if [ "x$home_partition" != "x-" ]; then
umount --force $home_partition
fi

if [ "x$boot_partition" != "x-" ]; then
umount --force $boot_partition
fi

if [ "x$swap_partition" != "x-" ]; then
swapoff -a
fi

if [ -d $LFS/boot/efi ]; then
umount $LFS/boot/efi
fi

if [ -d /mnt/dest/sys/firmware/efi/efivars ]; then
    umount /mnt/dest/sys/firmware/efi/efivars
fi

umount $LFS/dev/pts &> /dev/null
umount $LFS/dev/shm &> /dev/null
umount $LFS/dev &> /dev/null
umount $LFS/sys &> /dev/null
umount $LFS/proc &> /dev/null
umount $LFS/run &> /dev/null
umount $LFS/home &> /dev/null
umount $LFS &> /dev/null

exit 0

