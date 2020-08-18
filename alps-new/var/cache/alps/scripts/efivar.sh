#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:dosfstools
#REQ:pciutils

cd $SOURCE_DIR

NAME=efivar
VERSION=37
URL=https://github.com/rhboot/efivar/releases/download/37/efivar-37.tar.bz2
SECTION="Others"
DESCRIPTION="Tools and libraries to work with EFI variables"

wget -nc $URL
wget -nc http://www.linuxfromscratch.org/~xry111/efivar-37-gcc_9-1.patch

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

sed -e 's/-Werror//g' -i gcc.specs
sed 's|-rpath,$(TOPDIR)/src|-rpath,$(libdir)|g' -i src/test/Makefile

make libdir=/usr/lib         \
     bindir=/usr/bin         \
     mandir=/usr/share/man   \
     includedir=/usr/include

make libdir=/usr/lib         \
     bindir=/usr/bin         \
     mandir=/usr/share/man   \
     includedir=/usr/include \
     -C src/test

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make libdir=/usr/lib          \
     bindir=/usr/bin          \
     mandir=/usr/share/man    \
     includedir=/usr/include  \
     install -j1 V=1
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
install -vDm 755 src/test/tester /usr/bin/efivar-tester
install -vDm 644 {README.md,TODO} -t /usr/share/doc/efivar-37
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
