#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:perl-deps#perl-alien-build
#REQ:libxml2
#REQ:perl-deps#perl-test2-suite



cd $SOURCE_DIR

NAME=perl-deps#perl-alien-libxml2
VERSION=0.16
URL=https://cpan.metacpan.org/authors/id/P/PL/PLICEASE/Alien-Libxml2-0.16.tar.gz
SECTION="Perl Module Dependencies"
DESCRIPTION="Alien::Libxml2 is designed to allow modules to install the C libxml2 library on your system. In BLFS, it uses pkg-config to find how to link to the installed libxml2-2.9.10."

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

perl Makefile.PL &&
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

 
