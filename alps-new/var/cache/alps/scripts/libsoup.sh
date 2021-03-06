#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:glib-networking
#REQ:libpsl
#REQ:libxml2
#REQ:sqlite
#REQ:gobject-introspection
#REQ:vala


cd $SOURCE_DIR

NAME=libsoup
VERSION=2.70.0
URL=http://ftp.gnome.org/pub/gnome/sources/libsoup/2.70/libsoup-2.70.0.tar.xz
SECTION="Networking Libraries"
DESCRIPTION="The libsoup is a HTTP client/server library for GNOME. It uses GObject and the GLib main loop to integrate with GNOME applications and it also has an asynchronous API for use in threaded applications."

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

meson --prefix=/usr -Dvapi=enabled -Dgssapi=disabled .. &&
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

 
