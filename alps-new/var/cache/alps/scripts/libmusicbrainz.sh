#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf


cd $SOURCE_DIR

NAME=libmusicbrainz
VERSION=2.1.5
URL=http://ftp.musicbrainz.org/pub/musicbrainz/historical/libmusicbrainz-2.1.5.tar.gz
SECTION="Multimedia Libraries and Drivers"
DESCRIPTION="The libmusicbrainz package contains a library which allows you to access the data held on the MusicBrainz server. This is useful for adding MusicBrainz lookup capabilities to other applications.MusicBrainz is a community music metadatabase that attempts to create a comprehensive music information site. You can use the MusicBrainz data either by browsing the web site, or you can access the data from a client program — for example, a CD player program can use MusicBrainz to identify CDs and provide information about the CD, about the artist or other related information."

wget -nc $URL
wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/libmusicbrainz-2.1.5-missing-includes-1.patch

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

patch -Np1 -i ../libmusicbrainz-2.1.5-missing-includes-1.patch &&

CXXFLAGS=-std=c++98 \
./configure --prefix=/usr --disable-static &&
make

(cd python && python setup.py build)

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install &&
install -v -m644 -D docs/mb_howto.txt \
    /usr/share/doc/libmusicbrainz-2.1.5/mb_howto.txt
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
(cd python && python setup.py install)
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
