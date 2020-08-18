#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:xorg-server


cd $SOURCE_DIR

NAME=x7driver#xorg-nouveau-driver
VERSION=1.0.16
URL=https://www.x.org/pub/individual/driver/xf86-video-nouveau-1.0.16.tar.bz2
SECTION="Xorg Drivers"
DESCRIPTION="The Xorg Nouveau Driver package contains the X.Org Video Driver for NVidia Cards including RIVA TNT, RIVA TNT2, GeForce 256, QUADRO, GeForce2, QUADRO2, GeForce3, QUADRO DDC, nForce, nForce2, GeForce4, QUADRO4, GeForce FX, QUADRO FX, GeForce 6XXX and GeForce 7xxx chipsets."

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

./configure $XORG_CONFIG &&
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

 
