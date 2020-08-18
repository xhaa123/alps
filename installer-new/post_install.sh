#!/bin/bash

set -e
set +h

. /tmp/install-properties

function get_uuid() {
  rm -rf /tmp/tmpfile
  for x in $(blkid $1); do echo $x >> /tmp/tmpfile; done
  the_uuid=$(cat /tmp/tmpfile | grep -e "^UUID=" | sed 's@"@@g' | sed 's@UUID=@@g')
  echo $the_uuid
}

disklabel_type=$(/sbin/fdisk -l $device | grep "Disklabel type" | cut -d ' ' -f3)
root_uuid=$(/sbin/blkid $root_partition | cut -d '"' -f2)

echo "Disklabel type: $disklabel_type"
echo "Root UUID: $root_uuid"

if [ $disklabel_type = "gpt" ]; then

  boot_part=$(fdisk -l $boot_device | grep "EFI System" | cut -d ' ' -f1)
  if [ "x$boot_part" != "x" ]; then
    boot_uuid=$(get_uuid $boot_part)
  fi

fi

echo "$hostname" > /etc/hostname
cat > /etc/fstab <<EOF
# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

UUID=$root_uuid     /            ext4     defaults            1     1

EOF

if [ "x$home_partition" != "x-" ]; then
  mount $home_partition /home
  uuid=$(get_uuid $home_partition)
  cat > /etc/fstab <<EOF
UUID=$uuid     /home            ext4     noatime            0     2
EOF
fi

if [ "x$swap_partition" != "x-" ]; then
  mkswap $swap_partition
  swapon $swap_partition
  uuid=$(get_uuid $swap_partition)
  cat > /etc/fstab <<EOF
UUID=$uuid     none            swap     defaults            0     0
EOF
fi

if [ "x$boot_partition" != "x-" ]; then
  mount $boot_partition /boot
  uuid=$(get_uuid $boot_partition)
  cat > /etc/fstab <<EOF
UUID=$uuid     /boot            vfat     defaults            0     2
EOF
fi

# Do this only if we have booted in uefi mode

if [ -d /sys/firmware/efi ] && [ $disklabel_type = "gpt" ] && [ ! "x$boot_uuid" == "x" ] ; then
  echo "Installing in efi mode, gpt partition table found & efi partition found"
  mkdir -pv /boot/efi
  mount $boot_part /boot/efi
  mount -t efivarfs efivarfs /sys/firmware/efi/efivars

cat >> /etc/fstab <<EOF
UUID=$boot_uuid       /boot/efi    vfat     defaults            0     1
efivarfs       /sys/firmware/efi/efivars  efivarfs  defaults  0      1

EOF

  codename=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | sed 's@DISTRIB_CODENAME="@@g' | sed 's@"@@g')
  os_name=$(cat /etc/lsb-release | grep DISTRIB_ID | sed 's@DISTRIB_ID="@@g' | sed 's@"@@g')

  bootloader_id="$os_name - $codename"
  grub-install --target=$(uname -m)-efi --efi-directory=/boot/efi --bootloader-id="$bootloader_id" --recheck --debug

elif [ -d /sys/firmware/efi ] && [ $disklabel_type = "gpt" ] && [ "x$boot_uuid" == "x" ]; then
  echo "Could not find an EFI partition to continue installation"
  exit
elif [ ! -d /sys/firmware/efi ] && [ $disklabel_type = "gpt" ]; then
  echo "Cannot install bootloader because we have a GPT type partition table and have boot in legacy mode. Bootloader for GPT type partition can be only be installed by booting in UEFI mode"
  exit
elif [ -d /sys/firmare/efi ] && [ $disklabel_type = "dos" ] && [ "x$boot_uuid" == "x" ]; then
  echo "Cannot install bootloader because there is no efi partition"
  exit
elif [ ! -d /sys/firmare/efi ] && [ $disklabel_type = "dos" ]; then
  echo "Installing for msdos partition table in legacy mode"
  grub-install $device
else
  echo "Don't know what went wrong. Not installing bootloader and exiting."
  ls -l /sys/firmware
  echo $disklabel_type
  echo $boot_uuid
  exit
fi

cat >> /etc/fstab <<EOF
# End /etc/fstab
EOF

grub-mkconfig -o /boot/grub/grub.cfg
cat > /etc/locale.conf << EOF
LANG=$locale
EOF

cat > /etc/vconsole.conf << EOF
KEYMAP=$keymap
EOF

if [ -f $LFS/etc/lightdm/lightdm.conf ]; then
sed -i "s@autologin-user=@#autologin-user=@g" $LFS/etc/lightdm/lightdm.conf
sed -i "s@autologin-user-timeout=@#autologin-user-timeout=@g" $LFS/etc/lightdm/lightdm.conf
sed -i "s@user-session=@#user-session=@g" $LFS/etc/lightdm/lightdm.conf
sed -i "s@pam-service=@#pam-service=@g" $LFS/etc/lightdm/lightdm.conf
sed -i "s@autologin-guest=@#autologin-guest=@g" $LFS/etc/lightdm/lightdm.conf
fi

ln -sfv /usr/share/zoneinfo/$timezone /etc/localtime
echo "$computer_name" > /etc/hostname

userdel -r aryalinux

useradd -m -c "$full_name" -s /bin/bash $username
sed -i "s/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g" /etc/sudoers

usermod -a -G wheel $username
usermod -a -G audio $username
usermod -a -G video $username

# Set passwords:
usermod --password $(echo $root_password | openssl passwd -1 -stdin) root
usermod --password $(echo $password | openssl passwd -1 -stdin) $username

if getent group lpadmin &> /dev/null; then
usermod -a -G lpadmin $username
fi

su $username -c "xdg-user-dirs-update --force"

mkdir -pv /var/cache/alps/sources
chmod a+rw /var/cache/alps/sources

ccache -c
ccache -C
su $username -c "ccache -c"
su $username -c "ccache -c"
