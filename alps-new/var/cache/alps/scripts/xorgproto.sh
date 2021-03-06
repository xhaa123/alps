#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:util-macros


cd $SOURCE_DIR

NAME=xorgproto
VERSION=2020.1
URL=https://xorg.freedesktop.org/archive/individual/proto/xorgproto-2020.1.tar.bz2
SECTION="X Window System Environment"
DESCRIPTION="The xorgproto package provides the header files required to build the X Window system, and to allow other applications to build against the installed X Window system."

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

mkdir build &&
cd    build &&

meson --prefix=$XORG_PREFIX -Dlegacy=true .. &&
ninja

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
ninja install &&

install -vdm 755 $XORG_PREFIX/share/doc/xorgproto-2020.1 &&
install -vm 644 ../[^m]*.txt ../PM_spec $XORG_PREFIX/share/doc/xorgproto-2020.1
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
