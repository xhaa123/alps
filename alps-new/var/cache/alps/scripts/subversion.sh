#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:apr-util
#REQ:sqlite
#REQ:serf



cd $SOURCE_DIR

NAME=subversion
VERSION=1.14.0
URL=https://archive.apache.org/dist/subversion/subversion-1.14.0.tar.bz2
SECTION="Programming"
DESCRIPTION="Subversion is a version control system that is designed to be a compelling replacement for CVS in the open source community. It extends and enhances CVS' feature set, while maintaining a similar interface for those already familiar with CVS. These instructions install the client and server software used to manipulate a Subversion repository. Creation of a repository is covered at Running a Subversion Server."

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

PYTHON=python3 ./configure --prefix=/usr             \
            --disable-static          \
            --with-apache-libexecdir  \
            --with-lz4=internal       \
            --with-utf8proc=internal &&
make

make swig-pl # for Perl
make swig-py \
     swig_pydir=/usr/lib/python3.8/site-packages/libsvn \
     swig_pydir_extra=/usr/lib/python3.8/site-packages/svn # for Python
make swig-rb # for Ruby

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install &&

install -v -m755 -d /usr/share/doc/subversion-1.14.0 &&
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install-swig-pl
make install-swig-py \
      swig_pydir=/usr/lib/python3.8/site-packages/libsvn \
      swig_pydir_extra=/usr/lib/python3.8/site-packages/svn
make install-swig-rb
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
