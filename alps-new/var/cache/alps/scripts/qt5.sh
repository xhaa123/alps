#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:x7lib
#REQ:alsa-lib
#REQ:make-ca
#REQ:cups
#REQ:glib2
#REQ:gst10-plugins-base
#REQ:harfbuzz
#REQ:icu
#REQ:jasper
#REQ:libjpeg
#REQ:libmng
#REQ:libpng
#REQ:libtiff
#REQ:libwebp
#REQ:libxkbcommon
#REQ:mesa
#REQ:mitkrb
#REQ:mtdev
#REQ:pcre2
#REQ:sqlite
#REQ:wayland
#REQ:xcb-util-image
#REQ:xcb-util-keysyms
#REQ:xcb-util-renderutil
#REQ:xcb-util-wm


cd $SOURCE_DIR

NAME=qt5
VERSION=5.15.0
URL=https://download.qt.io/archive/qt/5.15/5.15.0/single/qt-everywhere-src-5.15.0.tar.xz
SECTION="X Libraries"
DESCRIPTION="Qt5 is a cross-platform application framework that is widely used for developing application software with a graphical user interface (GUI) (in which cases Qt5 is classified as a widget toolkit), and also used for developing non-GUI programs such as command-line tools and consoles for servers. One of the major users of Qt is KDE Frameworks 5 (KF5)."

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

export QT5PREFIX=/opt/qt5

mkdir /opt/qt-5.15.0
ln -sfnv qt-5.15.0 /opt/qt5

sed -i 's/python /python3 /' qtdeclarative/qtdeclarative.pro \
                             qtdeclarative/src/3rdparty/masm/masm.pri &&

./configure -prefix $QT5PREFIX                              \
            -sysconfdir /etc/xdg                            \
            -confirm-license                                \
            -opensource                                     \
            -dbus-linked                                    \
            -openssl-linked                                 \
            -system-harfbuzz                                \
            -system-sqlite                                  \
            -nomake examples                                \
            -no-rpath                                       \
            -skip qtwebengine                               \
            -archdatadir    /usr/lib/qt5                    \
            -bindir         /usr/bin                        \
            -plugindir      /usr/lib/qt5/plugins            \
            -importdir      /usr/lib/qt5/imports            \
            -headerdir      /usr/include/qt5                \
            -datadir        /usr/share/qt5                  \
            -docdir         /usr/share/doc/qt5              \
            -translationdir /usr/share/qt5/translations     \
            -examplesdir    /usr/share/doc/qt5/examples     &&
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
find $QT5PREFIX/ -name \*.prl \
   -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' {} \;
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
QT5BINDIR=$QT5PREFIX/bin

install -v -dm755 /usr/share/pixmaps/                  &&

install -v -Dm644 qttools/src/assistant/assistant/images/assistant-128.png \
                  /usr/share/pixmaps/assistant-qt5.png &&

install -v -Dm644 qttools/src/designer/src/designer/images/designer.png \
                  /usr/share/pixmaps/designer-qt5.png  &&

install -v -Dm644 qttools/src/linguist/linguist/images/icons/linguist-128-32.png \
                  /usr/share/pixmaps/linguist-qt5.png  &&

install -v -Dm644 qttools/src/qdbus/qdbusviewer/images/qdbusviewer-128.png \
                  /usr/share/pixmaps/qdbusviewer-qt5.png &&

install -dm755 /usr/share/applications &&

cat > /usr/share/applications/assistant-qt5.desktop << EOF
[Desktop Entry]
Name=Qt5 Assistant
Comment=Shows Qt5 documentation and examples
Exec=$QT5BINDIR/assistant
Icon=assistant-qt5.png
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;Documentation;
EOF

cat > /usr/share/applications/designer-qt5.desktop << EOF
[Desktop Entry]
Name=Qt5 Designer
GenericName=Interface Designer
Comment=Design GUIs for Qt5 applications
Exec=$QT5BINDIR/designer
Icon=designer-qt5.png
MimeType=application/x-designer;
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;
EOF

cat > /usr/share/applications/linguist-qt5.desktop << EOF
[Desktop Entry]
Name=Qt5 Linguist
Comment=Add translations to Qt5 applications
Exec=$QT5BINDIR/linguist
Icon=linguist-qt5.png
MimeType=text/vnd.trolltech.linguist;application/x-linguist;
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;
EOF

cat > /usr/share/applications/qdbusviewer-qt5.desktop << EOF
[Desktop Entry]
Name=Qt5 QDbusViewer
GenericName=D-Bus Debugger
Comment=Debug D-Bus applications
Exec=$QT5BINDIR/qdbusviewer
Icon=qdbusviewer-qt5.png
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;Debugger;
EOF
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
for file in moc uic rcc qmake lconvert lrelease lupdate; do
  ln -sfrvn $QT5BINDIR/$file /usr/bin/$file-qt5
done
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
cat > /etc/profile.d/qt5.sh << "EOF"
# Begin /etc/profile.d/qt5.sh

QT5DIR=/usr
export QT5DIR
pathappend $QT5DIR/bin

# End /etc/profile.d/qt5.sh
EOF
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
cat > /etc/sudoers.d/qt << "EOF"
Defaults env_keep += QT5DIR
EOF
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
cat >> /etc/ld.so.conf << EOF
# Begin Qt addition

/opt/qt5/lib

# End Qt addition
EOF

ldconfig
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
cat > /etc/profile.d/qt5.sh << "EOF"
# Begin /etc/profile.d/qt5.sh

QT5DIR=/opt/qt5

pathappend $QT5DIR/bin           PATH
pathappend $QT5DIR/lib/pkgconfig PKG_CONFIG_PATH

export QT5DIR

# End /etc/profile.d/qt5.sh
EOF
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
