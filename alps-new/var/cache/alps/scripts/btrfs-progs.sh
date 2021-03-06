#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:lzo
#REQ:asciidoc
#REQ:xmlto

cd $SOURCE_DIR


NAME=btrfs-progs
VERSION=5.7
URL=https://mirrors.ustc.edu.cn/kernel.org/linux/kernel/people/kdave/btrfs-progs/btrfs-progs-v5.7.tar.xz
SECTION="File Systems and Disk Management"
DESCRIPTION="The btrfs-progs package contains administration and debugging tools for the B-tree file system (btrfs)."

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

./configure --prefix=/usr \
            --bindir=/bin \
            --libdir=/lib &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install &&

ln -sfv ../../lib/$(readlink /lib/libbtrfs.so) /usr/lib/libbtrfs.so &&
ln -sfv ../../lib/$(readlink /lib/libbtrfsutil.so) /usr/lib/libbtrfsutil.so &&
rm -fv /lib/libbtrfs.{a,so} /lib/libbtrfsutil.{a,so} &&
mv -v /bin/{mkfs,fsck}.btrfs /sbin
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh


if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"
