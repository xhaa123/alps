#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:yasm
#REQ:nasm
#REQ:which


cd $SOURCE_DIR

NAME=libvpx
VERSION=1.9.0
URL=https://github.com/webmproject/libvpx/archive/v1.9.0/libvpx-1.9.0.tar.gz
SECTION="Multimedia Libraries and Drivers"
DESCRIPTION="This package, from the WebM project, provides the reference implementations of the VP8 Codec, used in most current html5 video, and of the next-generation VP9 Codec."

wget -nc $URL
wget -nc http://www.nasm.us/pub/nasm/releasebuilds/2.15.03/nasm-2.15.03-xdoc.tar.xz

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

sed -i 's/cp -p/cp/' build/make/Makefile &&

mkdir libvpx-build            &&
cd    libvpx-build            &&

../configure --prefix=/usr    \
             --enable-shared  \
             --disable-static &&
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

 
