#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:libaio
#REQ:thin-provisioning-tools



cd $SOURCE_DIR

NAME=lvm2
VERSION=2.03.10
URL=https://sourceware.org/ftp/lvm2/LVM2.2.03.10.tgz
SECTION="File Systems and Disk Management"
DESCRIPTION="The LVM2 package is a set of tools that manage logical partitions. It allows spanning of file systems across multiple physical disks and disk partitions and provides for dynamic growing or shrinking of logical partitions, mirroring and low storage footprint snapshots."

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

SAVEPATH=$PATH                     &&
PATH=$PATH:/sbin:/usr/sbin         &&
./configure --prefix=/usr          \
            --exec-prefix=         \
            --enable-cmdlib        \
            --enable-pkgconfig     \
            --enable-udev_sync     \
            --enable-dmeventd      \
            --with-cache=internal  \
            --with-thin=internal   &&
make                               &&
PATH=$SAVEPATH                     &&
unset SAVEPATH

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install
make install_systemd_units
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
