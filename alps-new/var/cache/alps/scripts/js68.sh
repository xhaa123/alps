#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:autoconf213
#REQ:icu
#REQ:python2
#REQ:which

cd $SOURCE_DIR

NAME=js68
VERSION=68.11.0
URL=https://archive.mozilla.org/pub/firefox/releases/68.11.0esr/source/firefox-68.11.0esr.source.tar.xz
SECTION="General Libraries"
DESCRIPTION="JS is Mozilla's JavaScript engine written in C. JS68 is taken from Firefox."

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

export SHELL=/bin/bash

mountpoint -q /dev/shm || mount -t tmpfs devshm /dev/shm

sed '21,+4d' -i js/moz.configure &&

mkdir obj &&
cd    obj &&

CC=gcc CXX=g++ LLVM_OBJDUMP=/bin/false       \
../js/src/configure --prefix=/usr            \
                    --with-intl-api          \
                    --with-system-zlib       \
                    --with-system-icu        \
                    --disable-jemalloc       \
                    --disable-debug-symbols  \
                    --enable-readline        \
                    --enable-unaligned-private-values &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install
rm -v /usr/lib/libjs_static.ajs
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
