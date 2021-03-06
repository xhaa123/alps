#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:nss
#REQ:python2
#REQ:qt5
#REQ:alsa-lib
#REQ:pulseaudio
#REQ:ffmpeg
#REQ:icu
#REQ:libwebp
#REQ:libxslt
#REQ:opus


cd $SOURCE_DIR

NAME=qtwebengine
VERSION=5.15.0
URL=https://download.qt.io/archive/qt/5.15/5.15.0/submodules/qtwebengine-everywhere-src-5.15.0.tar.xz
SECTION="X Libraries"
DESCRIPTION="QtWebEngine integrates chromium's web capabilities into Qt. It ships with its own copy of ninja which it uses for the build if it cannot find a system copy, and various copies of libraries from ffmpeg, icu, libvpx, and zlib (including libminizip) which have been forked by the chromium developers."

wget -nc $URL
wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/qtwebengine-everywhere-src-5.15.0-consolidated_fixes-1.patch

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

if ! grep -ri "/opt/qt5/lib" /etc/ld.so.conf &> /dev/null; then
        echo "/opt/qt5/lib" | tee -a /etc/ld.so.conf
        ldconfig
fi

ldconfig
. /etc/profile.d/qt5.sh

find -type f -name "*.pr[io]" |
  xargs sed -i -e 's|INCLUDEPATH += |&$$QTWEBENGINE_ROOT/include |'

patch -Np1 -i ../qtwebengine-everywhere-src-5.15.0-consolidated_fixes-1.patch

sed -e '/link_pulseaudio/s/false/true/' \
    -i src/3rdparty/chromium/media/media_options.gni

sed -i 's/NINJAJOBS/NINJA_JOBS/' src/core/gn_run.pro

if [ -e ${QT5DIR}/lib/libQt5WebEngineCore.so ]; then
  mv -v ${QT5DIR}/lib/libQt5WebEngineCore.so{,.old}
fi

mkdir build &&
cd    build &&

qmake .. -- -system-ffmpeg -webengine-icu &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
find $QT5DIR/ -name \*.prl \
   -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' {} \;
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
