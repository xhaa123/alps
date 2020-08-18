#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:gnutls
#REQ:gtk3
#REQ:libgcrypt
#REQ:gobject-introspection
#REQ:python2
#REQ:vala



cd $SOURCE_DIR

NAME=gtk-vnc
VERSION=1.0.0
URL=http://ftp.gnome.org/pub/gnome/sources/gtk-vnc/1.0/gtk-vnc-1.0.0.tar.xz
SECTION="X Libraries"
DESCRIPTION="The Gtk VNC package contains a VNC viewer widget for GTK+. It is built using coroutines allowing it to be completely asynchronous while remaining single threaded.

This package is known to build and work properly using an LFS-9"

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

mkdir build &&
cd    build &&

meson --prefix=/usr .. &&
ninja

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
ninja install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
