#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:boost
#REQ:extra-cmake-modules
#REQ:docbook
#REQ:docbook-xsl
#REQ:giflib
#REQ:libepoxy
#REQ:libgcrypt
#REQ:libjpeg
#REQ:libpng
#REQ:libxslt
#REQ:lmdb
#REQ:phonon
#REQ:shared-mime-info
#REQ:perl-uri
#REQ:wget
#REQ:aspell
#REQ:avahi
#REQ:libdbusmenu-qt
#REQ:networkmanager
#REQ:polkit-qt
#REQ:kf5-intro
#REQ:bluez
#REQ:ModemManager
#REQ:noto-fonts
#REQ:python-Jinja2
#REQ:python-PyYAML
#REQ:jasper
#REQ:mitkrb
#REQ:udisks2
#REQ:upower
#REQ:media-player-info


cd $SOURCE_DIR

NAME=krameworks5
VERSION=5.70

SECTION="KDE Frameworks 5"
DESCRIPTION="KDE Frameworks 5 is a collection of libraries based on top of Qt5 and QML derived from the monolithic KDE 4 libraries. They can be used independent of the KDE Display Environment (Plasma 5)."



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

export QT5DIR=/opt/qt5
export KF5_PREFIX=/usr

#url=http://download.kde.org/stable/frameworks/5.70/
url=http://mirrors.ustc.edu.cn/kde/stable/frameworks/5.70/

cat > frameworks-5.70.0.md5 << "EOF"
0662c42c9956ff85d5677d01b2be54ed  attica-5.70.0.tar.xz
#fa9d2abfdb2b1679787f3e695591eec3  extra-cmake-modules-5.70.0.tar.xz
4529cd343c8405a3c3125db10805740e  kapidox-5.70.0.tar.xz
5c759116a6fd6e9ccb760c8c7668f4be  karchive-5.70.0.tar.xz
2220c9c8f58d5fd2202ff1f11cb40d8e  kcodecs-5.70.0.tar.xz
8403c9c5cbbb8c96bec4cea4ce6bc764  kconfig-5.70.0.tar.xz
1a7001a1cacf0fdd96f0ac882c071503  kcoreaddons-5.70.0.tar.xz
0c875564917a3769ecb8695cdd87dfa6  kdbusaddons-5.70.0.tar.xz
2bd111b8aa228fcaed274f2de4d9d7d7  kdnssd-5.70.0.tar.xz
922b5bf6520a0f551f3a24fc44736017  kguiaddons-5.70.0.tar.xz
38fa408218a40d0c8d7d73d22bb8c74c  ki18n-5.70.0.tar.xz
754083ef1afac1c1d280ad9beff262c8  kidletime-5.70.0.tar.xz
c1d393754324f1654332ffd15bf0a04b  kimageformats-5.70.0.tar.xz
fb178ef04b48741b3a56a3eb9a464a88  kitemmodels-5.70.0.tar.xz
cc5e9c1716a816d8f18c8ceaf5995afa  kitemviews-5.70.0.tar.xz
c7a41b3eaabebcf33a0525b90daca561  kplotting-5.70.0.tar.xz
c9af5d1b21cb57fd882420f04e7bfb24  kwidgetsaddons-5.70.0.tar.xz
afe3c023d1ebd1f2cd1b48ad1bb77046  kwindowsystem-5.70.0.tar.xz
a8a8954d3cbb2721531e7c38ae9b92c0  networkmanager-qt-5.70.0.tar.xz
8389e1ecfb9eace6af471a6fdfc249e8  solid-5.70.0.tar.xz
3d9d72f36bb135b8de91497734c1a08e  sonnet-5.70.0.tar.xz
01ba09be43c32826cebdaab01ba257e1  threadweaver-5.70.0.tar.xz
4561d348d12a5be34c3b1c96ee1303e3  kauth-5.70.0.tar.xz
c97543ad15f56a355640abd3535974ce  kcompletion-5.70.0.tar.xz
8d013cac0a0d57417d3b69188700a4b8  kcrash-5.70.0.tar.xz
68ee037e6ab6c7956c4c988a629fd606  kdoctools-5.70.0.tar.xz
5421e4cf962aad7ff75dd2ab3ba8c588  kpty-5.70.0.tar.xz
3465dcb86a7d5247b2fc6504dc59f345  kunitconversion-5.70.0.tar.xz
3e1bddd47524d52b416a5f82c787eba9  kconfigwidgets-5.70.0.tar.xz
27fcd57a9d763f34b185052743795903  kservice-5.70.0.tar.xz
a2cbcb92d8afc66f9d398feaa5ef4fcc  kglobalaccel-5.70.0.tar.xz
428f94a21061feca57feff45af819d33  kpackage-5.70.0.tar.xz
6f9a92bf3d2cbe26c67f74a8357040b2  kdesu-5.70.0.tar.xz
44dfe3d667259135dd076072c26ad569  kemoticons-5.70.0.tar.xz
1f98c26216b7ef6507d16815a69ffec2  kiconthemes-5.70.0.tar.xz
6dbdea28bc66853bfebf11e8b0c882f4  kjobwidgets-5.70.0.tar.xz
dfb0042a3663fe09cc013490e4a63860  knotifications-5.70.0.tar.xz
d00a98ef67a05c7848b755c95ccbc062  ktextwidgets-5.70.0.tar.xz
c0c0eb42c6df61c56006dbda64674b98  kxmlgui-5.70.0.tar.xz
179a9b158eeb5e39eaa17c6bce86e1ff  kbookmarks-5.70.0.tar.xz
33a1dc6ab1be41fac3e81f6cb472a069  kwallet-5.70.0.tar.xz
ea2f82e35ee5cb1672b4acecdd5a2166  kio-5.70.1.tar.xz
e16156acbe112f2b8fbfa3bc1a475517  kdeclarative-5.70.0.tar.xz
1fe4198573ec914521b8fefee112db09  kcmutils-5.70.0.tar.xz
f47f6e6e8df0fcd14cd0d4da8d13c387  kirigami2-5.70.0.tar.xz
ddbb73118bfd298a0f0cf6229a8ea3e8  knewstuff-5.70.0.tar.xz
2d48b0b982c85a00dd668ce9a759b762  frameworkintegration-5.70.0.tar.xz
e23ae6b5edc1eab71bc9efb0e4478579  kinit-5.70.0.tar.xz
8094d4e3d2f4c4de15fc43a90745fec3  knotifyconfig-5.70.0.tar.xz
43786f6a1e6629d85eddfdebba5d5779  kparts-5.70.0.tar.xz
2210df63319591f07161603856c05a89  kactivities-5.70.0.tar.xz
de3b5bcc752bdccbb380e79e1bef9749  kded-5.70.0.tar.xz
#62137f9ac20b3ae834f9db364a8fc883  kdewebkit-5.70.0.tar.xz
79483ab26b782ead8d9937e055c5ab80  syntax-highlighting-5.70.0.tar.xz
f761f1b7876cecfc12cdb09c58a7cab2  ktexteditor-5.70.1.tar.xz
eda29268e2fcc487f9b5327f50b2a6a1  kdesignerplugin-5.70.0.tar.xz
a5bd12d4f453e7fa2873887f8b67ed24  kwayland-5.70.0.tar.xz
7c34a86d46a9579e3222a233de2deaee  plasma-framework-5.70.1.tar.xz
#93e77e5e267c588e1a9c02cef7b66344  modemmanager-qt-5.70.0.tar.xz
4928a1fb4f30033cfc773f7788469113  kpeople-5.70.0.tar.xz
b1e8cf4271ff15c2405ea53a1ad96770  kxmlrpcclient-5.70.0.tar.xz
1e4ed6723f2f4e26272a930be175b43f  bluez-qt-5.70.0.tar.xz
ec4f5d2b42c7681b8394a651f036d02c  kfilemetadata-5.70.0.tar.xz
d2e58f6ff05939c017f9f609bcd88bba  baloo-5.70.0.tar.xz
#3bb6310b57e2bec3c3703b8ecdda8c4e  breeze-icons-5.70.0.tar.xz
#7514480df86969c3a688317c7d8d57c3  oxygen-icons5-5.70.0.tar.xz
dc3f2f6e3c3da0c7dfcbbdab80bf4525  kactivities-stats-5.70.0.tar.xz
5fccfd29b83eec47982420fc8d96a608  krunner-5.70.0.tar.xz
#179e9c8572d45c1c4fa1c22d3329aa6e  prison-5.70.0.tar.xz
7e620abb50e6a65ae0aba63d7965246e  qqc2-desktop-style-5.70.0.tar.xz
5da6b3606f188b628df1e46fa04c2617  kjs-5.70.0.tar.xz
aabe7800a7c8add84efd8344b7582ffb  kdelibs4support-5.70.0.tar.xz
1428874c22d8af52caeffb67bf3a92c1  khtml-5.70.0.tar.xz
4bba2510b573812de49bccc2ee447cad  kjsembed-5.70.0.tar.xz
f277b1426f982845eb3c5ebc42c15b48  kmediaplayer-5.70.0.tar.xz
6d619e298ac3a8b8d6b30a5020b2c128  kross-5.70.0.tar.xz
c0ba868390673010348f72679b1f7e46  kholidays-5.70.0.tar.xz
18a5eb19df6992fe3f66767ce2ed7029  purpose-5.70.0.tar.xz
894e8902c34abebaf49c1a92d0d53011  syndication-5.70.0.tar.xz
87160c7e63e09d84576fa1a95758676a  kcalendarcore-5.70.0.tar.xz
fddabbc040e37213bca9b51870e5ce6d  kcontacts-5.70.0.tar.xz
e0cf77affa32c3301efc93c84ffa5d28  kquickcharts-5.70.0.tar.xz
EOF


while read -r line; do

    # Get the file name, ignoring comments and blank lines
    if $(echo $line | grep -E -q '^ *$|^#' ); then continue; fi
    file=$(echo $line | cut -d" " -f2)

    touch /tmp/kframeworks-done
    if grep $file /tmp/kframeworks-done; then continue; fi
    wget -nc $url/$file
    if echo $file | grep /; then file=$(echo $file | cut -d/ -f2); fi

    pkg=$(echo $file|sed 's|^.*/||')          # Remove directory
    packagedir=$(echo $pkg|sed 's|\.tar.*||') # Package directory

    name=$(echo $pkg|sed 's|-5.*$||') # Isolate package name

    tar -xf $file
    pushd $packagedir

      case $name in
        kitemviews*) sed -i '/<QList>/a #include <QPersistentModelIndex>' \
          src/kwidgetitemdelegatepool_p.h ;;
        kplotting*) sed -i '/<QHash>/a #include <QHelpEvent>' \
          src/kplotwidget.cpp ;;
        knotifica*) sed -i '/<QUrl>/a #include <QVariant>' \
          src/knotification.h ;;
        kcompleti*) sed -i '/<QClipboard>/a #include <QKeyEvent>' \
          src/klineedit.cpp ;;
        kwayland*) sed -i '/<wayland-xdg-output-server-proto/a #include <QHash>' \
          src/server/xdgoutput_interface.cpp ;;
      esac  

      mkdir krameworks5-build
      cd    krameworks5-build
      pwd

      cmake -DCMAKE_INSTALL_PREFIX=$KF5_PREFIX \
            -DCMAKE_PREFIX_PATH=$QT5DIR        \
            -DCMAKE_BUILD_TYPE=Release         \
            -DBUILD_TESTING=OFF                \
            -Wno-dev ..
      make
      make install
    popd

    rm -rf $packagedir
    /sbin/ldconfig

  echo $file >> /tmp/kframeworks-done

done < frameworks-5.70.0.md5


if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"
