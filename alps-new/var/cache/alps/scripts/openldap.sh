#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf


cd $SOURCE_DIR

NAME=openldap
VERSION=2.4.50
URL=ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-2.4.50.tgz
SECTION="Other Server Software"
DESCRIPTION="The OpenLDAP package provides an open source implementation of the Lightweight Directory Access Protocol."

wget -nc $URL
wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/openldap-2.4.50-consolidated-1.patch


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

patch -Np1 -i ../openldap-2.4.50-consolidated-1.patch &&
autoconf &&

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-static  \
            --enable-dynamic  \
            --disable-debug   \
            --disable-slapd &&

make depend &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install

ln -sf ../lib/slapd /usr/sbin/slapd
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
