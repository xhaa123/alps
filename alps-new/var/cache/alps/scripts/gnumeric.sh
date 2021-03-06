#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:goffice010
#REQ:itstool
#REQ:rarian
#REQ:adwaita-icon-theme
#REQ:oxygen-icons5
#REQ:gnome-icon-theme
#REQ:yelp


cd $SOURCE_DIR

NAME=gnumeric
VERSION=1.12.47
URL=http://ftp.gnome.org/pub/gnome/sources/gnumeric/1.12/gnumeric-1.12.47.tar.xz
SECTION="Office Programs"
DESCRIPTION="The Gnumeric package contains a spreadsheet program which is useful for mathematical analysis."

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

sed -i 's/HELP_LINGUAS = cs de es/HELP_LINGUAS = de es/' doc/Makefile.in &&
./configure --prefix=/usr  &&
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

 
