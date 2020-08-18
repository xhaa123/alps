#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

cd $SOURCE_DIR

NAME=tex-path
VERSION=
SECTION="Typesetting"
DESCRIPTION="Before starting to build TeX Live, set up your PATH so that the system can properly find the files. If you set up your login scripts as recommended in The Bash Shell Startup Files, update the needed paths by appending to the extrapaths.sh script. The programs are always installed in an <ARCH>-linux subdirectory and on 32-bit x86 this is always i386-linux. For x86_64 and i?86 we can generate this as $TEXARCH:"

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



rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
export TEXARCH=$(uname -m | sed -e 's/i.86/i386/' -e 's/$/-linux/') &&

cat >> /etc/profile.d/extrapaths.sh << EOF

# Begin texlive addition

pathappend /opt/texlive/2020/texmf-dist/doc/man  MANPATH
pathappend /opt/texlive/2020/texmf-dist/doc/info INFOPATH
pathappend /opt/texlive/2020/bin/$TEXARCH

# End texlive addition

EOF

unset TEXARCH
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
