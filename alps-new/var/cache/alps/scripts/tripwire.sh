#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf



cd $SOURCE_DIR

NAME=tripwire
VERSION=2.4.3.7
URL=https://github.com/Tripwire/tripwire-open-source/releases/download/2.4.3.7/tripwire-open-source-2.4.3.7.tar.gz
SECTION="Security"
DESCRIPTION="The Tripwire package contains programs used to verify the integrity of the files on a given system."

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

sed -e '/^CLOBBER/s/false/true/'         \
    -e 's|TWDB="${prefix}|TWDB="/var|'   \
    -e '/TWMAN/ s|${prefix}|/usr/share|' \
    -e '/TWDOCS/s|${prefix}/doc/tripwire|/usr/share/doc/tripwire-2.4.3.7|' \
    -i installer/install.cfg                               &&

find . -name Makefile.am | xargs                           \
    sed -i 's/^[[:alpha:]_]*_HEADERS.*=/noinst_HEADERS =/' &&

sed '/dist/d' -i man/man?/Makefile.am                      &&
autoreconf -fi                                             &&

./configure --prefix=/usr --sysconfdir=/etc/tripwire       &&
make

sed -i -e 's@installer/install.sh@& -n -s <site-password> -l <local-password>@' Makefile

sed '/-t 0/,+3d' -i installer/install.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install &&
cp -v policy/*.txt /usr/share/doc/tripwire-2.4.3.7
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
twadmin --create-polfile --site-keyfile /etc/tripwire/site.key \
    /etc/tripwire/twpol.txt &&
tripwire --init
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
tripwire --check > /etc/tripwire/report.txt
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
twprint --print-report -r /var/lib/tripwire/report/<report-name.twr>
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh
rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
tripwire --update --twrfile /var/lib/tripwire/report/<report-name.twr>
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh
rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
twadmin --create-polfile /etc/tripwire/twpol.txt &&
tripwire --init
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
