#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:boost
#REQ:double-conversion
#REQ:gc
#REQ:gdl
#REQ:gsl
#REQ:libxslt
#REQ:poppler
#REQ:popt
#REQ:wget
#REQ:imagemagick
#REQ:lcms2
#REQ:lcms
#REQ:libcanberra
#REQ:potrace
#REQ:python-modules#lxml
#REQ:python-modules#scour
#REQ:gtk2
#REQ:gtk3


cd $SOURCE_DIR

NAME=inkscape
VERSION=1.0
URL=https://media.inkscape.org/dl/resources/file/inkscape-1.0.tar.xz
SECTION="Other X-based Programs"
DESCRIPTION="Inkscape is a what you see is what you get Scalable Vector Graphics editor. It is useful for creating, viewing and changing SVG images."

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

cmake -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_BUILD_TYPE=Release  \
      ..                          &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
gtk-update-icon-cache -qtf /usr/share/icons/hicolor &&
update-desktop-database -q
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
