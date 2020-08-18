#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf


cd $SOURCE_DIR

NAME=sdl2
VERSION=2.0.12
URL=http://www.libsdl.org/release/SDL2-2.0.12.tar.gz
SECTION="Multimedia Libraries and Drivers"
DESCRIPTION="The Simple DirectMedia Layer Version 2 (SDL2 for short) is a cross-platform library designed to make it easy to write multimedia software, such as games and emulators."

wget -nc $URL
wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/SDL2-2.0.12-opengl_include_fix-1.patch


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

case $(uname -m) in
   i?86) patch -Np1 -i ../SDL2-2.0.12-opengl_include_fix-1.patch ;;
esac

./configure --prefix=/usr &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install              &&
rm -v /usr/lib/libSDL2*.a
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
