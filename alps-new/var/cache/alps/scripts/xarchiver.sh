#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:gtk2
#REQ:gtk3
#REQ:cpio
#REQ:lzo
#REQ:p7zip
#REQ:unrar
#REQ:unzip
#REQ:zip


cd $SOURCE_DIR

NAME=xarchiver
VERSION=0.5.4.15
URL=https://github.com/ib/xarchiver/archive/0.5.4.15/xarchiver-0.5.4.15.tar.gz
SECTION="Other X-based Programs"
DESCRIPTION="XArchiver is a GTK+ archive manager with support for tar, xz, bzip2, gzip, zip, 7z, rar, lzo and many other archive formats."

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

./configure  --prefix=/usr               \
             --libexecdir=/usr/lib/xfce4 \
             --docdir=/usr/share/doc/xarchiver-0.5.4.15 &&
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
gtk-update-icon-cache -qtf /usr/share/icons/hicolor &&
update-desktop-database -q
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
