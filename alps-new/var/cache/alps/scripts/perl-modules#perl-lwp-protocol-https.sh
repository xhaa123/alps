#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:perl-modules#perl-io-socket-ssl
#REQ:perl-deps#perl-libwww-perl
#REQ:make-ca


cd $SOURCE_DIR

NAME=perl-modules#perl-lwp-protocol-https
VERSION=6.09
URL=https://www.cpan.org/authors/id/O/OA/OALDERS/LWP-Protocol-https-6.09.tar.gz
SECTION="Perl Modules"
DESCRIPTION="LWP::Protocol::https provides https support for LWP::UserAgent (i.e. libwww-perl-6.46). Once the module is installed LWP is able to access sites using HTTP over SSL/TLS."

wget -nc $URL
wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/LWP-Protocol-https-6.09-system_certs-2.patch


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

patch -Np1 -i ../LWP-Protocol-https-6.09-system_certs-2.patch

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

 
