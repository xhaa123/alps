#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:gobject-introspection
#REQ:librsvg


cd $SOURCE_DIR

NAME=babl
VERSION=0.1.78
URL=https://download.gimp.org/pub/babl/0.1/babl-0.1.78.tar.xz
SECTION="Graphics and Font Libraries"
DESCRIPTION="The Babl package is a dynamic, any to any, pixel format translation library."

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

mkdir bld &&
cd    bld &&

meson --prefix=/usr .. &&
ninja 

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
ninja install &&

install -v -m755 -d                         /usr/share/gtk-doc/html/babl/graphics &&
install -v -m644 docs/*.{css,html}          /usr/share/gtk-doc/html/babl          &&
install -v -m644 docs/graphics/*.{html,svg} /usr/share/gtk-doc/html/babl/graphics
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
