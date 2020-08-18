#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:which
#REQ:icu



cd $SOURCE_DIR

NAME=boost
VERSION=1.73.0
URL=https://dl.bintray.com/boostorg/release/1.73.0/source/boost_1_73_0.tar.bz2
SECTION="General Libraries"
DESCRIPTION="Boost provides a set of free peer-reviewed portable C++ source libraries. It includes libraries for linear algebra, pseudorandom number generation, multithreading, image processing, regular expressions and unit testing."

wget -nc $URL
wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/boost-1.73.0-gcc_10-1.patch

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

patch -Np1 -i ../boost-1.73.0-gcc_10-1.patch

./bootstrap.sh --prefix=/usr --with-icu --with-python=python3&&
./b2 stage -j$(nproc) threading=multi link=shared

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
./b2 install threading=multi link=shared                 &&
ln -svf detail/sha1.hpp /usr/include/boost/uuid/sha1.hpp
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
