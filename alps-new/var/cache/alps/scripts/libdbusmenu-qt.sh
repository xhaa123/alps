#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:qt5

cd $SOURCE_DIR

NAME=libdbusmenu-qt
VERSION=0.9.3+16.04.20160218
URL=http://launchpad.net/ubuntu/+archive/primary/+files/libdbusmenu-qt_0.9.3+16.04.20160218.orig.tar.gz
SECTION="Introduction to KDE"
DESCRIPTION="This library provides a Qt implementation of the DBusMenu specification that exposes menus via DBus."

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

if ! grep -ri "/opt/qt5/lib" /etc/ld.so.conf &> /dev/null; then
        echo "/opt/qt5/lib" | tee -a /etc/ld.so.conf
        ldconfig
fi

ldconfig
. /etc/profile.d/qt5.sh

mkdir build &&
cd    build &&

cmake -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_BUILD_TYPE=Release  \
      -DWITH_DOC=OFF              \
      -Wno-dev .. &&
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

 
