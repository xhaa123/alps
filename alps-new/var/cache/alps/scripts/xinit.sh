#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:x7lib
#REQ:libevdev
#REQ:xf86-input-evdev
#REQ:libinput
#REQ:xf86-input-libinput
#REQ:xf86-input-synaptics
#REQ:xf86-video-intel
#REQ:libva
#REQ:libvdpau
#REQ:libvdpau-va-gl
#REQ:twm
#REQ:xclock
#REQ:xterm


cd $SOURCE_DIR

NAME=xinit
VERSION=1.4.1
URL=https://www.x.org/pub/individual/app/xinit-1.4.1.tar.bz2
SECTION="X Window System Environment"
DESCRIPTION="The xinit package contains a usable script to start the xserver."

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

./configure $XORG_CONFIG --with-xinitdir=/etc/X11/app-defaults &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install &&
ldconfig
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
