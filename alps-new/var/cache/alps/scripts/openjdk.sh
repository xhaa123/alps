#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:alsa-lib
#REQ:cpio
#REQ:cups
#REQ:unzip
#REQ:which
#REQ:x7lib
#REQ:zip
#REQ:make-ca
#REQ:giflib
#REQ:lcms2
#REQ:libjpeg
#REQ:libpng
#REQ:wget

cd $SOURCE_DIR

NAME=openjdk
VERSION=14.0.1
URL=http://hg.openjdk.java.net/jdk-updates/jdk14u/archive/jdk-14.0.1+7.tar.bz2
SECTION="Programming"
DESCRIPTION="OpenJDK is an open-source implementation of Oracle's Java Standard Edition platform. OpenJDK is useful for developing Java programs, and provides a complete runtime environment to run Java programs."

wget -nc $URL
wget -nc http://anduin.linuxfromscratch.org/BLFS/OpenJDK/OpenJDK-14.0.1/jtreg-4.2-b13-517.tar.gz
wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/openjdk-14.0.1-make_4.3_fix-1.patch

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

tar -xf ../jtreg-4.2-b13-517.tar.gz

patch -p1 -i ../openjdk-14.0.1-make_4.3_fix-1.patch

unset JAVA_HOME                                       &&
bash configure --enable-unlimited-crypto              \
               --with-extra-cflags="$CFLAGS -fcommon" \
               --disable-warnings-as-errors           \
               --with-stdc++lib=dynamic               \
               --with-giflib=system                   \
               --with-jtreg=$PWD/jtreg                \
               --with-lcms=system                     \
               --with-libjpeg=system                  \
               --with-libpng=system                   \
               --with-zlib=system                     \
               --with-version-build="7"               \
               --with-version-pre=""                  \
               --with-version-opt=""                  \
               --with-cacerts-file=/etc/pki/tls/java/cacerts &&
make images

export JT_JAVA=$(echo $PWD/build/*/jdk) &&
jtreg/bin/jtreg -jdk:$JT_JAVA -automatic -ignore:quiet -v1 \
    test/jdk:tier1 test/langtools:tier1 &&
unset JT_JAVA

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
install -vdm755 /opt/jdk-14.0.1+7             &&
cp -Rv build/*/images/jdk/* /opt/jdk-14.0.1+7 &&
chown -R root:root /opt/jdk-14.0.1+7          &&
for s in 16 24 32 48; do
  install -vDm644 src/java.desktop/unix/classes/sun/awt/X11/java-icon${s}.png \
                  /usr/share/icons/hicolor/${s}x${s}/apps/java.png
done
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
ln -v -nsf jdk-14.0.1+7 /opt/jdk
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
mkdir -pv /usr/share/applications &&

cat > /usr/share/applications/openjdk-java.desktop << "EOF" &&
[Desktop Entry]
Name=OpenJDK Java 14.0.1 Runtime
Comment=OpenJDK Java 14.0.1 Runtime
Exec=/opt/jdk/bin/java -jar
Terminal=false
Type=Application
Icon=java
MimeType=application/x-java-archive;application/java-archive;application/x-jar;
NoDisplay=true
EOF
cat > /usr/share/applications/openjdk-jconsole.desktop << "EOF"
[Desktop Entry]
Name=OpenJDK Java 14.0.1 Console
Comment=OpenJDK Java 14.0.1 Console
Keywords=java;console;monitoring
Exec=/opt/jdk/bin/jconsole
Terminal=false
Type=Application
Icon=java
Categories=Application;System;
EOF
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
ln -sfv /etc/pki/tls/java/cacerts /opt/jdk/lib/security/cacerts
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
cd /opt/jdk
bin/keytool -list -cacerts
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
