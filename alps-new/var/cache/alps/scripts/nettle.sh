#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf


cd $SOURCE_DIR

NAME=nettle
VERSION=3.6
URL=https://ftp.gnu.org/gnu/nettle/nettle-3.6.tar.gz
SECTION="Security"
DESCRIPTION="The Nettle package contains a low-level cryptographic library that is designed to fit easily in many contexts."

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

./configure --prefix=/usr --disable-static &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install &&
chmod   -v   755 /usr/lib/lib{hogweed,nettle}.so &&
install -v -m755 -d /usr/share/doc/nettle-3.6 &&
install -v -m644 nettle.html /usr/share/doc/nettle-3.6
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
