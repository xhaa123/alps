#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:curl
#REQ:libevent
#REQ:gtk3
#REQ:qt5


cd $SOURCE_DIR

NAME=transmission
VERSION=-3.00
URL=https://raw.githubusercontent.com/transmission/transmission-releases/master/transmission-3.00.tar.xz
SECTION="Other X-based Programs"
DESCRIPTION="Transmission is a cross-platform, open source BitTorrent client. This is useful for downloading large files (such as Linux ISOs) and reduces the need for the distributors to provide server bandwidth."

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

./configure --prefix=/usr --enable-cli &&
make

pushd qt        &&
  qmake qtr.pro &&
  make          &&
popd

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make INSTALL_ROOT=/usr -C qt install &&

install -m644 qt/transmission-qt.desktop /usr/share/applications/transmission-qt.desktop &&
install -m644 qt/icons/transmission.png  /usr/share/pixmaps/transmission-qt.png
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
