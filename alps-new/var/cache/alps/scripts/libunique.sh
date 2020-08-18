#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:gtk2


cd $SOURCE_DIR

NAME=libunique
VERSION=1.1.6
URL=http://ftp.gnome.org/pub/gnome/sources/libunique/1.1/libunique-1.1.6.tar.bz2
SECTION="General Libraries"
DESCRIPTION="The libunique package contains a library for writing single instance applications."

wget -nc $URL
wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/libunique-1.1.6-upstream_fixes-1.patch

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

patch -Np1 -i ../libunique-1.1.6-upstream_fixes-1.patch &&
autoreconf -fi &&

./configure --prefix=/usr  \
            --disable-dbus \
            --disable-static &&
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

 
