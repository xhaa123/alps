#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:perl-deps#perl-devel-stacktrace
#REQ:perl-deps#perl-eval-closure
#REQ:perl-deps#perl-module-runtime
#REQ:perl-deps#perl-role-tiny
#REQ:perl-deps#perl-sub-quote
#REQ:perl-deps#perl-try-tiny


cd $SOURCE_DIR

NAME=perl-deps#perl-specio
VERSION=0.46
URL=https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/Specio-0.46.tar.gz
SECTION="Perl Module Dependencies"
DESCRIPTION="Specio provides classes for representing type constraints and coercion, along with syntax sugar for declaring them."

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

 
