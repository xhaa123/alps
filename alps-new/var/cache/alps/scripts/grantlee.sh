#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:cmake
#REQ:qt5


cd $SOURCE_DIR

NAME=grantlee
VERSION=5.2.0
URL=http://downloads.grantlee.org/grantlee-5.2.0.tar.gz
SECTION="General Libraries"
DESCRIPTION="Grantlee is a set of free software libraries written using the Qt framework. Currently two libraries are shipped with Grantlee: Grantlee Templates and Grantlee TextDocument. The goal of Grantlee Templates is to make it easier for application developers to separate the structure of documents from the data they contain, opening the door for theming."

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

 
