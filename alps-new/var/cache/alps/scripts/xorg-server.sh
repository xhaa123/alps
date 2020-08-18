#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:pixman
#REQ:x7font
#REQ:xkeyboard-config
#REQ:libepoxy
#REQ:wayland
#REQ:wayland-protocols
#REQ:systemd


cd $SOURCE_DIR

NAME=xorg-server
VERSION=1.20.8
URL=https://www.x.org/pub/individual/xserver/xorg-server-1.20.8.tar.bz2
SECTION="X Window System Environment"
DESCRIPTION="The Xorg Server is the core of the X Window system."

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

export XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static"

sed -i 's/malloc(pScreen/calloc(1, pScreen/' dix/pixmap.c

./configure $XORG_CONFIG            \
            --enable-glamor         \
            --enable-suid-wrapper   \
            --with-xkb-output=/var/lib/xkb &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install &&
mkdir -pv /etc/X11/xorg.conf.d
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
