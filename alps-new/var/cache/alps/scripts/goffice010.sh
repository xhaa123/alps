#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:gtk3
#REQ:libgsf
#REQ:librsvg
#REQ:libxslt
#REQ:which


cd $SOURCE_DIR

NAME=goffice010
VERSION=0.10.47
URL=http://ftp.gnome.org/pub/gnome/sources/goffice/0.10/goffice-0.10.47.tar.xz
SECTION="X Libraries"
DESCRIPTION="The GOffice package contains a library of GLib/GTK document centric objects and utilities. This is useful for performing common operations for document centric applications that are conceptually simple, but complex to implement fully. Some of the operations provided by the GOffice library include support for plugins, load/save routines for application documents and undo/redo functions."

wget -nc $URL

wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/goffice-0.10.47-upstream_fixes-1.patch
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

patch -Np1 -i ../goffice-0.10.47-upstream_fixes-1.patch

./configure --prefix=/usr &&
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

 
