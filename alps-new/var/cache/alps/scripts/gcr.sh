#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:glib2
#REQ:libgcrypt
#REQ:libtasn1
#REQ:p11-kit
#REQ:gnupg
#REQ:gobject-introspection
#REQ:gtk3
#REQ:libxslt
#REQ:vala
#REQ:gtk-doc

cd $SOURCE_DIR

NAME=gcr
VERSION=3.36.0
URL=http://ftp.gnome.org/pub/gnome/sources/gcr/3.36/gcr-3.36.0.tar.xz
SECTION="GNOME Libraries and Desktop"
DESCRIPTION="The Gcr package contains libraries used for displaying certificates and accessing key stores. It also provides the viewer for crypto files on the GNOME Desktop."

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

sed -i -r 's:"(/desktop):"/org/gnome\1:' schema/*.xml &&

sed -i '610 s/;/ = { 0 };/' gck/gck-slot.c &&

mkdir gcr-build &&
cd    gcr-build &&

meson --prefix=/usr -Dgtk_doc=false -Dgtk_doc=true.. &&
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

 
