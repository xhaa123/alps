#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:dconf
#REQ:iso-codes
#REQ:vala
#REQ:gobject-introspection
#REQ:gtk2
#REQ:libnotify

cd $SOURCE_DIR

NAME=ibus
VERSION=1.5.22
URL=https://github.com/ibus/ibus/releases/download/1.5.22/ibus-1.5.22.tar.gz
SECTION="General Utilities"
DESCRIPTION="ibus is an Intelligent Input Bus. It is a new input framework for the Linux OS. It provides a fully featured and user friendly input method user interface."

wget -nc $URL
wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/ibus-1.5.22-wayland_display-1.patch
wget -nc https://www.unicode.org/Public/zipped/10.0.0/UCD.zip

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

patch -Np1 -i ../ibus-1.5.22-wayland_display-1.patch

mkdir -p               /usr/share/unicode/ucd &&
unzip -u ../UCD.zip -d /usr/share/unicode/ucd

sed -i 's@/desktop/ibus@/org/freedesktop/ibus@g' \
    data/dconf/org.freedesktop.ibus.gschema.xml

./configure --prefix=/usr             \
            --sysconfdir=/etc         \
            --disable-unicode-dict    \
            --disable-emoji-dict      &&
rm -f tools/main.c                    &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install &&
gzip -dfv /usr/share/man/man{{1,5}/ibus*.gz,5/00-upstream-settings.5.gz}
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
