#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:extra-cmake-modules
#REQ:qtwebengine


cd $SOURCE_DIR

NAME=falkon
VERSION=3.1.0
URL=https://download.kde.org/stable/falkon/3.1/falkon-3.1.0.tar.xz
SECTION="Graphical Web Browsers"
DESCRIPTION="Falkon is a KDE web browser using the QtWebEngine rendering engine. It was previously known as QupZilla. It aims to be a lightweight web browser available through all major platforms."

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

rm -rf po/

sed -i '/#include <QSettings>/a#include <QFile>' \
   src/plugins/VerticalTabs/verticaltabsplugin.cpp

sed -i '/#include <QPainter>/a #include <QPainterPath>' \
   src/lib/tools/qztools.cpp

mkdir build &&
cd    build &&

cmake -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_BUILD_TYPE=Release  \
      .. &&

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

 
