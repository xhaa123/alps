#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf


cd $SOURCE_DIR

NAME=net-tools
VERSION=CVS_20101030
URL=http://anduin.linuxfromscratch.org/BLFS/net-tools/net-tools-CVS_20101030.tar.gz
SECTION="Networking Programs"
DESCRIPTION="The Net-tools package is a collection of programs for controlling the network subsystem of the Linux kernel."

wget -nc $URL
wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/net-tools-CVS_20101030-remove_dups-1.patch

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

patch -Np1 -i ../net-tools-CVS_20101030-remove_dups-1.patch &&
sed -i '/#include <netinet\/ip.h>/d'  iptunnel.c &&

yes "" | make config &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make update
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
