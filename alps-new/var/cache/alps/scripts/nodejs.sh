#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:python2
#REQ:which
#REQ:c-ares
#REQ:icu
#REQ:libuv
#REQ:nghttp2



cd $SOURCE_DIR

NAME=nodejs
VERSION=12.18.3
URL=https://nodejs.org/dist/v12.18.3/node-v12.18.3.tar.xz
SECTION="General Libraries"
DESCRIPTION="Node.js is a JavaScript runtime built on Chrome's V8 JavaScript engine."

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

./configure --prefix=/usr                  \
            --shared-cares                 \
            --shared-libuv                 \
            --shared-openssl               \
            --shared-nghttp2               \
            --shared-zlib                  \
            --with-intl=system-icu         &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install &&
ln -sf node /usr/share/doc/node-12.18.3
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
