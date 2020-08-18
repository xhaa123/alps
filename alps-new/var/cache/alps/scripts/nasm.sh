#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf




cd $SOURCE_DIR

NAME=nasm
VERSION=2.15.03
URL=http://www.nasm.us/pub/nasm/releasebuilds/2.15.03/nasm-2.15.03.tar.xz
SECTION="Programming"
DESCRIPTION="NASM (Netwide Assembler) is an 80x86 assembler designed for portability and modularity. It includes a disassembler as well."

wget -nc $URL
wget -nc http://www.nasm.us/pub/nasm/releasebuilds/2.15.03/nasm-2.15.03-xdoc.tar.xz

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

tar -xf ../nasm-2.15.03-xdoc.tar.xz --strip-components=1

./configure --prefix=/usr &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
install -m755 -d         /usr/share/doc/nasm-2.15.03/html  &&
cp -v doc/html/*.html    /usr/share/doc/nasm-2.15.03/html  &&
cp -v doc/*.{txt,ps,pdf} /usr/share/doc/nasm-2.15.03
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
