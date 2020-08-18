#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:gsettings-desktop-schemas
#REQ:gtk3
#REQ:iso-codes
#REQ:itstool
#REQ:libseccomp
#REQ:libxml2
#REQ:xkeyboard-config
#REQ:bubblewrap
#REQ:gobject-introspection


cd $SOURCE_DIR

NAME=gnome-desktop
VERSION=3.36.5
URL=http://ftp.gnome.org/pub/gnome/sources/gnome-desktop/3.36/gnome-desktop-3.36.5.tar.xz
SECTION="GNOME Libraries and Desktop"
DESCRIPTION="The GNOME Desktop package contains a library that provides an API shared by several applications on the GNOME Desktop."

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



rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"

ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
