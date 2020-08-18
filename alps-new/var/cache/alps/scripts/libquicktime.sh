#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:libdv

cd $SOURCE_DIR

NAME=libquicktime
VERSION=1.2.4
URL=https://downloads.sourceforge.net/libquicktime/libquicktime-1.2.4.tar.gz
SECTION="Multimedia Libraries and Drivers"
DESCRIPTION="The libquicktime package contains the libquicktime library, various plugins and codecs, along with graphical and command line utilities used for encoding and decoding QuickTime files. This is useful for reading and writing files in the QuickTime format. The goal of the project is to enhance, while providing compatibility with the Quicktime 4 Linux library."

wget -nc $URL
wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/libquicktime-1.2.4-ffmpeg4-1.patch

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

patch -Np1 -i ../libquicktime-1.2.4-ffmpeg4-1.patch &&

./configure --prefix=/usr     \
            --enable-gpl      \
            --without-doxygen \
            --with-libdv      \
            --docdir=/usr/share/doc/libquicktime-1.2.4
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install &&

install -v -m755 -d /usr/share/doc/libquicktime-1.2.4 &&
install -v -m644    README doc/{*.txt,*.html,mainpage.incl} \
                    /usr/share/doc/libquicktime-1.2.4
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
