#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:perl-deps#perl-datetime-locale
#REQ:perl-deps#perl-datetime-timezone
#REQ:perl-deps#perl-cpan-meta-check
#REQ:perl-deps#perl-test-fatal
#REQ:perl-deps#perl-test-warnings


cd $SOURCE_DIR

NAME=perl-deps#perl-datetime
VERSION=1.52
URL=https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/DateTime-1.52.tar.gz
SECTION="Perl Module Dependencies"
DESCRIPTION="DateTime is a date and time object for perl."

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

 
