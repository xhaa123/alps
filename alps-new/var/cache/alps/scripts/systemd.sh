#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:linux-pam
#REQ:polkit
#REQ:gnu-efi
#REQ:lz4
#REQ:grub-efi
#REQ:btrfs-progs
#REQ:curl
#REQ:cryptsetup
#REQ:git
#REQ:gnutls
#REQ:libgcrypt
#REQ:libidn2
#REQ:libpwquality
#REQ:libseccomp
#REQ:terminus-font


cd $SOURCE_DIR

NAME=systemd
VERSION=246
URL=https://github.com/systemd/systemd/archive/v246/systemd-246.tar.gz
SECTION="System Utilities"
DESCRIPTION="While systemd was installed when building LFS, there are many features provided by the package that were not included in the initial installation because Linux-PAM was not yet installed. The systemd package needs to be rebuilt to provide a working systemd-logind service, which provides many additional features for dependent packages."

wget -nc $URL

if [ ! -z $URL ]; then
    TARBALL=$(echo $URL | rev | cut -d/ -f1 | rev)
    if [ -z $(echo $TARBALL | grep ".zip$") ]; then
        DIRECTORY=$(tar tf $TARBALL | cut -d/ -f1 | uniq | grep -v "^\.$")
        rm -rf $DIRECTORY
        tar --no-overwrite-dir -xf $TARBALL
    else
        DIRECTORY=$(unzip_dirname $TARBALL $NAME)
        unzip_file $TARBALL $NAME
    fi

    cd $DIRECTORY
fi

echo $USER > /tmp/currentuser


sed -i 's/GROUP="render", //' rules.d/50-udev-default.rules.in

mkdir build &&
cd    build &&

meson --prefix=/usr                 \
      --sysconfdir=/etc             \
      --localstatedir=/var          \
      -Dblkid=true                  \
      -Dbuildtype=release           \
      -Ddefault-dnssec=no           \
      -Dfirstboot=false             \
      -Dinstall-tests=false         \
      -Dldconfig=false              \
      -Dman=auto                    \
      -Drootprefix=                 \
      -Drootlibdir=/lib             \
      -Dsplit-usr=true              \
      -Dsysusers=false              \
      -Drpmmacrosdir=no             \
      -Db_lto=false                 \
      -Dhomed=true                  \
      -Duserdb=true                 \
      ..                            &&

ninja

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
ninja install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
cat >> /etc/pam.d/system-session << "EOF"
# Begin Systemd addition
    
session  required    pam_loginuid.so
session  optional    pam_systemd.so

# End Systemd addition
EOF

cat > /etc/pam.d/systemd-user << "EOF"
# Begin /etc/pam.d/systemd-user

account  required    pam_access.so
account  include     system-account

session  required    pam_env.so
session  required    pam_limits.so
session  required    pam_unix.so
session  required    pam_loginuid.so
session  optional    pam_keyinit.so force revoke
session  optional    pam_systemd.so

auth     required    pam_deny.so
password required    pam_deny.so

# End /etc/pam.d/systemd-user
EOF
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
