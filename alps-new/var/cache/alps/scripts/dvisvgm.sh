#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:gs
#REQ:potrace

cd $SOURCE_DIR

NAME=dvisvgm
VERSION=2.9.1
URL=https://github.com/mgieseki/dvisvgm/releases/download/2.9.1/dvisvgm-2.9.1.tar.gz
SECTION="Typesetting"
DESCRIPTION="The dvisvgm package converts DVI, EPS and PDF files to SVG format."

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

ln -svf /opt/texlive/2020/lib/libkpathsea.so /usr/lib

./configure                                    \
 --bindir=/opt/texlive/2020/bin/${TEXARCH}     \
 --mandir=/opt/texlive/2020/texmf-dist/doc/man \
 --with-kpathsea=/opt/texlive/2020            &&
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

 
