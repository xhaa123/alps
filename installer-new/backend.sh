#!/bin/bash

set -e
set +h

. /tmp/install-properties

# Copy live system to destination

sudo rm -rf /tmp/installation-completed

destination=/mnt/dest
mkdir -pv $destination
echo "y" | mkfs.ext4 $root_partition
mount $root_partition $destination
squashed_filesystem=$(find /mnt -name root.sfs)
unsquashfs -f -d $destination $squashed_filesystem
cp -v /opt/installer-new/post_install.sh $destination/tmp/
cp -v /tmp/install-properties $destination/tmp/

# Chroot into the destination and run post install

mount -v --bind /dev $destination/dev

mount -vt devpts devpts $destination/dev/pts -o gid=5,mode=620
mount -vt proc proc $destination/proc
mount -vt sysfs sysfs $destination/sys
mount -vt tmpfs tmpfs $destination/run

mount -vt tmpfs tmpfs $destination/dev/shm

chroot "$destination" /usr/bin/env -i              \
    HOME=/root TERM="$TERM" PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin     \
    /bin/bash -e +h /tmp/post_install.sh

# Cleaning up

echo "Cleaning up. Please wait..."
rm -v $destination/tmp/post_install.sh
rm -v $destination/tmp/install-properties
rm -rf $destination/opt/installer-new
rm -rf $destination/usr/share/applications/installer.desktop

sudo /opt/installer-new/umountal.sh &> /dev/null

rm -rf $destination/opt/installer-new
sudo touch /tmp/installation-completed
echo "Installation completed successfully."
