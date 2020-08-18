#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:cmake
#REQ:fontconfig
#REQ:cairo
#REQ:lcms2
#REQ:libjpeg
#REQ:libpng
#REQ:nss
#REQ:openjpeg2


cd $SOURCE_DIR

NAME=poppler
VERSION=20.08.0
URL=https://poppler.freedesktop.org/poppler-20.08.0.tar.xz
SECTION="Graphics and Font Libraries"
DESCRIPTION="The Poppler package contains a PDF rendering library and command line tools used to manipulate PDF files. This is useful for providing PDF rendering functionality as a shared library."

wget -nc $URL
wget -nc https://poppler.freedesktop.org/poppler-data-0.4.9.tar.gz

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

mkdir build                         &&
cd    build                         &&

cmake  -DCMAKE_BUILD_TYPE=Release   \
       -DCMAKE_INSTALL_PREFIX=/usr  \
       -DTESTDATADIR=$PWD/testfiles \
       -DENABLE_UNSTABLE_API_ABI_HEADERS=ON     \
       ..                           &&
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
install -v -m755 -d           /usr/share/doc/poppler-20.08.0 &&
cp -vr ../glib/reference/html /usr/share/doc/poppler-20.08.0
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

tar -xf ../../poppler-data-0.4.9.tar.gz &&
cd poppler-data-0.4.9

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make prefix=/usr install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh
if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 