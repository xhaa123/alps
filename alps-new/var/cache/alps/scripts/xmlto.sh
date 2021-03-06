#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:docbook
#REQ:docbook-xsl
#REQ:libxslt
#REQ:links


cd $SOURCE_DIR

NAME=xmlto
VERSION=0.0.28
URL=https://releases.pagure.org/xmlto/xmlto-0.0.28.tar.bz2
SECTION="Extensible Markup Language (XML)"
DESCRIPTION="The xmlto package is a front-end to a XSL toolchain. It chooses an appropriate stylesheet for the conversion you want and applies it using an external XSLT processor. It also performs any necessary post-processing."

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

LINKS="/usr/bin/links" \
./configure --prefix=/usr &&

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

 
