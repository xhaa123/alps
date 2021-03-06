#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:alsa-lib
#REQ:desktop-file-utils
#REQ:ffmpeg
#REQ:liba52
#REQ:libgcrypt
#REQ:libmad
#REQ:lua
#REQ:qt5
#REQ:gtk3
#REQ:gtk2


cd $SOURCE_DIR

NAME=vlc
VERSION=3.0.11.1
URL=https://download.videolan.org/vlc/3.0.11.1/vlc-3.0.11.1.tar.xz
SECTION="Video Utilities"
DESCRIPTION="VLC is a media player, streamer, and encoder. It can play from many inputs, such as files, network streams, capture devices, desktops, or DVD, SVCD, VCD, and audio CD. It can use most audio and video codecs (MPEG 1/2/4, H264, VC-1, DivX, WMV, Vorbis, AC3, AAC, etc.), and it can also convert to different formats and/or send streams through the network."

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

if ! grep -ri "/opt/qt5/lib" /etc/ld.so.conf &> /dev/null; then
        echo "/opt/qt5/lib" | tee -a /etc/ld.so.conf
        ldconfig
fi

ldconfig
. /etc/profile.d/qt5.sh

sed -i '/vlc_demux.h/a #define LUA_COMPAT_APIINTCASTS' modules/lua/vlc.h   &&
sed -i '/#include <QWidget>/a\#include <QPainterPath>/'            \
    modules/gui/qt/util/timetooltip.hpp                            &&
sed -i '/#include <QPainter>/a\#include <QPainterPath>/'           \
    modules/gui/qt/components/playlist/views.cpp                   \
    modules/gui/qt/dialogs/plugins.cpp                             &&

BUILDCC=gcc ./configure --prefix=/usr    \
                        --disable-opencv \
                        --disable-vpx    &&

make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make docdir=/usr/share/doc/vlc-3.0.11.1 install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
gtk-update-icon-cache -qtf /usr/share/icons/hicolor &&
update-desktop-database -q
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
