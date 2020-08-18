#!/bin/bash

. /tmp/system.props

# Step 1. Setup the target machine

systemd-machine-id-setup
echo "$HOSTNAME" > /etc/hostname

# Step 2. Generate initrd and grub.conf

dracut -f $(ls /boot/initrd*) $(ls /lib/modules/)
grub-mkconfig -o /boot/grub/grub.cfg

# Step 3. Generate necessary configuration files

# Step 4. Create user and assign groups to the user

useradd -m -k /etc/skel -c "$FULL_NAME" $USER_NAME

# Step 5. Assign password to root user

# Step 6. Install bootloader

# Step 7. Clean up


