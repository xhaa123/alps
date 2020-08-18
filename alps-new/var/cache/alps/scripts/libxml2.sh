#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:icu


cd $SOURCE_DIR

NAME=libxml2
VERSION=2.9.10
URL=http://xmlsoft.org/sources/libxml2-2.9.10.tar.gz
SECTION="General Libraries"
DESCRIPTION="The libxml2 package contains libraries and utilities used for parsing XML files."

#wget -nc $URL
#wget -nc http://www.w3.org/XML/Test/xmlts20130923.tar.gz

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

sed -i 's/test.test/#&/' python/tests/tstLastError.py

./configure --prefix=/usr    \
            --disable-static \
            --with-history   \
			--with-icu       \
			--with-threads   \
            --with-python=/usr/bin/python3 &&
make

tar xf ../xmlts20130923.tar.gz

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
