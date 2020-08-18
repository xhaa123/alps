#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:libatasmart
#REQ:libblockdev
#REQ:libgudev
#REQ:libxslt
#REQ:polkit
#REQ:btrfs-progs
#REQ:dosfstools
#REQ:gptfdisk
#REQ:mdadm
#REQ:xfsprogs
#REQ:systemd


cd $SOURCE_DIR

NAME=udisks2
VERSION=2.9.0
URL=https://github.com/storaged-project/udisks/releases/download/udisks-2.9.0/udisks-2.9.0.tar.bz2
SECTION="System Utilities"
DESCRIPTION="The UDisks package provides a daemon, tools and libraries to access and manipulate disks and storage devices."

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

./configure --prefix=/usr        \
            --sysconfdir=/etc    \
            --localstatedir=/var \
            --disable-static     &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
