#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:x7lib


cd $SOURCE_DIR

NAME=imagemagick6
VERSION=6.9.10-93
URL=https://www.imagemagick.org/download/releases/ImageMagick-6.9.10-93.tar.xz
SECTION="General Utilities"
DESCRIPTION="ImageMagick underwent many changes in its libraries between versions 6 and 7. Most packages in BLFS which use ImageMagick can use version 7, but for the others this page will install only the libraries, headers and general documentation (not programs, manpages, perl modules), and it will rename the unversioned pkgconfig files so that they do not overwrite the same-named files from version 7."

wget -nc $URL
wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/ImageMagick-6.9.10-93-libs_only-1.patch

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

patch -Np1 -i ../ImageMagick-6.9.10-93-libs_only-1.patch &&
autoreconf -fi                                          &&
./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --enable-hdri     \
            --with-modules    \
            --disable-static  &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make DOCUMENTATION_PATH=/usr/share/doc/imagemagick-6.9.10 install-libs-only
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
