#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:libsoup
#REQ:gnome-online-accounts
#REQ:gtk3
#REQ:json-glib
#REQ:vala
#REQ:gcr
#REQ:git
#REQ:gobject-introspection

cd $SOURCE_DIR

NAME=libgdata
VERSION=0.17.12
URL=http://ftp.gnome.org/pub/gnome/sources/libgdata/0.17/libgdata-0.17.12.tar.xz
SECTION="GNOME Libraries and Desktop"
DESCRIPTION="http://ftp.gnome.org/pub/gnome/sources/libgdata/0.17/libgdata-0.17.12.tar.xz"

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

meson --prefix=/usr -Dgtk_doc=false -Dalways_build_tests=false .. &&
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

 
