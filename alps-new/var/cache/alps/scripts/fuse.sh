#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf



cd $SOURCE_DIR

NAME=fuse
VERSION=3.9.2
URL=https://github.com/libfuse/libfuse/releases/download/fuse-3.9.2/fuse-3.9.2.tar.xz
SECTION="File Systems and Disk Management"
DESCRIPTION="FUSE (Filesystem in Userspace) is a simple interface for userspace programs to export a virtual filesystem to the Linux kernel. Fuse also aims to provide a secure method for non privileged users to create and mount their own filesystem implementations."

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

sed -i '/^udev/,$ s/^/#/' util/meson.build &&

mkdir build &&
cd    build &&

meson --prefix=/usr .. &&
ninja

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
ninja install                                             &&

mv -vf   /usr/lib/libfuse3.so.3*     /lib                 &&
ln -sfvn ../../lib/libfuse3.so.3.9.2 /usr/lib/libfuse3.so &&

mv -vf /usr/bin/fusermount3  /bin         &&
mv -vf /usr/sbin/mount.fuse3 /sbin        &&
chmod u+s /bin/fusermount3                &&

install -v -m755 -d /usr/share/doc/fuse-3.9.2      &&
install -v -m644    ../doc/{README.NFS,kernel.txt} \
                    /usr/share/doc/fuse-3.9.2      &&
cp -Rv ../doc/html  /usr/share/doc/fuse-3.9.2      
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
