#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:colord
#REQ:gtk3
#REQ:gobject-introspection
#REQ:gtk2
#REQ:vala


cd $SOURCE_DIR

NAME=colord-gtk
VERSION=0.2.0
URL=https://www.freedesktop.org/software/colord/releases/colord-gtk-0.2.0.tar.xz
SECTION="X Libraries"
DESCRIPTION="The Colord GTK package contains GTK+ bindings for Colord."

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

meson --prefix=/usr  \
      -Dgtk2=true    \
      -Dvapi=true    \
      -Ddocs=false   \
      -Dman=false .. &&
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

 
