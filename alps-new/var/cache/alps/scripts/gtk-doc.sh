#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:docbook
#REQ:docbook-xsl
#REQ:itstool
#REQ:libxslt
#REQ:python-pygments


cd $SOURCE_DIR

NAME=gtk-doc
VERSION=1.32
URL=http://ftp.gnome.org/pub/gnome/sources/gtk-doc/1.32/gtk-doc-1.32.tar.xz
SECTION="General Utilities"
DESCRIPTION="The GTK-Doc package contains a code documenter. This is useful for extracting specially formatted comments from the code to create API documentation. This package is optional; if it is not installed, packages will not build the documentation. This does not mean that you will not have any documentation. If GTK-Doc is not available, the install process will copy any pre-built documentation to your system."

#wget -nc $URL


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

 
