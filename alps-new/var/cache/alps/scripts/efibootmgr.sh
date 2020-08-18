#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:popt
#REQ:efivar


cd $SOURCE_DIR

NAME=efibootmgr
VERSION=16
URL=https://github.com/rhinstaller/efibootmgr/releases/download/16/efibootmgr-16.tar.bz2
SECTION="Others"
DESCRIPTION="Linux user-space application to modify the EFI Boot Manager"

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

make EFIDIR=LFS EFI_LOADER=grubx64.efi

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
install -v -D -m0755 src/efibootmgr /usr/sbin/efibootmgr &&
install -v -D -m0644 src/efibootmgr.8 \
        /usr/share/man/man8/efibootmgr.8
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
