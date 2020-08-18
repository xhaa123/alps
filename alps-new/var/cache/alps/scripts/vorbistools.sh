#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:libvorbis
#REQ:libao


cd $SOURCE_DIR

NAME=vorbistools
VERSION=1.4.0
URL=https://downloads.xiph.org/releases/vorbis/vorbis-tools-1.4.0.tar.gz
SECTION="Audio Utilities"
DESCRIPTION="The Vorbis Tools package contains command-line tools useful for encoding, playing or editing files using the Ogg CODEC."

wget -nc $URL
wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/vorbis-tools-1.4.0-security_fix-1.patch


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

patch -Np1 -i ../vorbis-tools-1.4.0-security_fix-1.patch

./configure --prefix=/usr \
            --enable-vcut \
            --without-curl &&
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

 
