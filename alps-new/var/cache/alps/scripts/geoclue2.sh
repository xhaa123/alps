#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:json-glib
#REQ:libsoup
#REQ:ModemManager
#REQ:vala
#REQ:avahi


cd $SOURCE_DIR

NAME=geoclue2
VERSION=2.5.6
URL=https://gitlab.freedesktop.org/geoclue/geoclue/-/archive/2.5.6/geoclue-2.5.6.tar.bz2
SECTION="Networking Libraries"
DESCRIPTION="GeoClue is a modular geoinformation service built on top of the D-Bus messaging system. The goal of the GeoClue project is to make creating location-aware applications as simple as possible."

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

meson --prefix=/usr --sysconfdir=/etc -Dgtk-doc=false .. &&
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

 
