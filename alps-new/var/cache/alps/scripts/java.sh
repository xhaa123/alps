#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:alsa-lib
#REQ:cups
#REQ:giflib
#REQ:x7lib


cd $SOURCE_DIR

NAME=java
VERSION=14.0.1
URL=http://anduin.linuxfromscratch.org/BLFS/OpenJDK/OpenJDK-14.0.1/OpenJDK-14.0.1+7-i686-bin.tar.xz
SECTION="Programming"
DESCRIPTION="ava is different from most of the packages in LFS and BLFS. It is a programming language that works with files of byte codes to obtain instructions and executes then in a Java Virtual Machine (JVM). An introductory java program looks like:"

wget -nc $URL
wget -nc https://download.java.net/java/GA/jdk14.0.1/664493ef4a6946b186ff29eb326336a2/7/GPL/openjdk-14.0.1_linux-x64_bin.tar.gz

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

install -vdm755 /opt/OpenJDK-14.0.1+7-bin &&
mv -v * /opt/OpenJDK-14.0.1+7-bin         &&
chown -R root:root /opt/OpenJDK-14.0.1+7-bin

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
ln -sfn OpenJDK-14.0.1+7-bin /opt/jdk
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
