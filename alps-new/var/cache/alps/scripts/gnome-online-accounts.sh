#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:gcr
#REQ:json-glib
#REQ:rest
#REQ:vala
#REQ:webkitgtk
#REQ:gobject-introspection

cd $SOURCE_DIR

NAME=gnome-online-accounts
VERSION=3.36.0
URL=http://ftp.gnome.org/pub/gnome/sources/gnome-online-accounts/3.36/gnome-online-accounts-3.36.0.tar.xz
SECTION="GNOME Libraries and Desktop"
DESCRIPTION="The GNOME Online Accounts package contains a framework used to access the user's online accounts."

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
            --disable-static \
            --with-google-client-secret=5ntt6GbbkjnTVXx-MSxbmx5e \
            --with-google-client-id=595013732528-llk8trb03f0ldpqq6nprjp1s79596646.apps.googleusercontent.com &&
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

 
