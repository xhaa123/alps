#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:perl-deps#perl-class-tiny
#REQ:perl-deps#perl-file-copy-recursive
#REQ:perl-deps#perl-file-sharedir
#REQ:perl-deps#perl-path-tiny
#REQ:perl-deps#perl-scope-guard


cd $SOURCE_DIR

NAME=perl-deps#perl-test-file-sharedir
VERSION=1.001002
URL=https://cpan.metacpan.org/authors/id/K/KE/KENTNL/Test-File-ShareDir-1.001002.tar.gz
SECTION="Perl Module Dependencies"
DESCRIPTION="Test::File::ShareDir is some low level plumbing to enable a distribution to perform tests while consuming its own share directories in a manner similar to how they will be once installed. This allows File-ShareDir-1.116 to see the latest version of content instead of whatever is installed on the target system where you are testing."

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

 
