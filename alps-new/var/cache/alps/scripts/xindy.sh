#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:clisp
#REQ:texlive

cd $SOURCE_DIR

NAME=xindy
VERSION=2.5.1
URL=http://tug.ctan.org/support/xindy/base/xindy-2.5.1.tar.gz
SECTION="Typesetting"
DESCRIPTION="Xindy is an index processor that can be used to generate book-like indexes for arbitrary document-preparation systems. This includes systems such as TeX and LaTeX, the roff-family, and SGML/XML-based systems (e.g., HTML) that process some kind of text and generate indexing information."

wget -nc $URL
wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/xindy-2.5.1-upstream_fixes-1.patch


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

export TEXARCH=$(uname -m | sed -e 's/i.86/i386/' -e 's/$/-linux/') &&

sed -i "s/ grep -v '^;'/ awk NF/" make-rules/inputenc/Makefile.in &&

sed -i 's%\(indexentry\)%\1\\%' make-rules/inputenc/make-inp-rules.pl &&

patch -Np1 -i ../xindy-2.5.1-upstream_fixes-1.patch &&

./configure --prefix=/opt/texlive/2020              \
            --bindir=/opt/texlive/2020/bin/$TEXARCH \
            --datarootdir=/opt/texlive/2020         \
            --includedir=/usr/include               \
            --libdir=/opt/texlive/2020/texmf-dist   \
            --mandir=/opt/texlive/2020/texmf-dist/doc/man &&

make LC_ALL=POSIX

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
