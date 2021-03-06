#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:exo
#REQ:libxfce4ui
#REQ:gnome-icon-theme
#REQ:lxde-icon-theme
#REQ:libgudev
#REQ:libnotify
#REQ:xfce4-panel


cd $SOURCE_DIR

NAME=thunar
VERSION=1.8.15
URL=http://archive.xfce.org/src/xfce/thunar/1.8/thunar-1.8.15.tar.bz2
SECTION="Xfce Desktop"
DESCRIPTION="Thunar is the Xfce file manager, a GTK+ 3 GUI to organise the files on your computer."

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

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/Thunar-1.8.15 &&
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

 
