#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:GConf
#REQ:gtk2
#REQ:gtk3
#REQ:krameworks5
#REQ:libpwquality
#REQ:libxkbcommon
#REQ:mesa
#REQ:wayland
#REQ:networkmanager
#REQ:pipewire
#REQ:pulseaudio
#REQ:qca
#REQ:sassc
#REQ:taglib
#REQ:xcb-util-cursor
#REQ:fftw
#REQ:gsettings-desktop-schemas
#REQ:libdbusmenu-qt
#REQ:libcanberra
#REQ:x7driver#libinput
#REQ:linux-pam
#REQ:lm_sensors
#REQ:oxygen-icons5
#REQ:pciutils



cd $SOURCE_DIR

NAME=plasma-all
VERSION=5.18.5

SECTION="Building Plasma 5"
DESCRIPTION="KDE Plasma 5 is a collection of packages based on top of KDE Frameworks 5 and QML. They implement the KDE Display Environment (Plasma 5)."


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

url=http://download.kde.org/stable/plasma/5.18.5/

cat > plasma-5.18.5.md5 << "EOF"
d81cb7833db2169952c46a468b36b630  kdecoration-5.18.5.tar.xz
940627dd8c2792676dd6f74b8c1130ab  libkscreen-5.18.5.tar.xz
47d8b84f73fe6e91a5f7b53fec479a06  libksysguard-5.18.5.tar.xz
8632854a3528f18d8175613cd3457086  breeze-5.18.5.tar.xz
ccdb725c872bf797e4ce305a03de3eab  breeze-gtk-5.18.5.tar.xz
3bc3534b73ee3542aaab0f2d534763b2  kscreenlocker-5.18.5.tar.xz
07fd865eca86217d879e7470e4afe8b9  oxygen-5.18.5.tar.xz
40441c19d0b72071803dce462fca0ee1  kinfocenter-5.18.5.tar.xz
27f1ef3c7d6b9fb6d9b70d676afc88b7  ksysguard-5.18.5.tar.xz
2881bc40c660bb3a3290f0c08cc189e6  kwin-5.18.5.tar.xz
148072db8bc16ff483ffa444ea7efe9a  plasma-workspace-5.18.5.tar.xz
88d833f3b31c79ade207a908eeacf4be  bluedevil-5.18.5.tar.xz
3b7d4749556d01fe8eae098b68239366  kde-gtk-config-5.18.5.tar.xz
89f2de2be8fdfa784af9c79d0dadbd32  khotkeys-5.18.5.tar.xz
3c834f0e56d082a00afc4072c00f4139  kmenuedit-5.18.5.tar.xz
4cdf26bbf63abcd146ea88e0aa1911b5  kscreen-5.18.5.tar.xz
a16c7c1841e03b1573448157ae3a9347  kwallet-pam-5.18.5.tar.xz
86f5f66830405ed2a386401b246e71b2  kwayland-integration-5.18.5.tar.xz
6cf0af3a35c5dfe0a024d66a76482b26  kwrited-5.18.5.tar.xz
d28362417e3ab1ca14edb84e73df2b33  milou-5.18.5.tar.xz
07cd8272fc4694f16495ea20ab72b3c0  plasma-nm-5.18.5.tar.xz
78dd988bcbf45586a159a81a1153b22f  plasma-pa-5.18.5.tar.xz
e1e1e30bf1b6ccbe245189e19f212777  plasma-workspace-wallpapers-5.18.5.tar.xz
0c99475e2fc152f57fa25c61026e53bf  polkit-kde-agent-1-5.18.5.tar.xz
c20dd0685bc94392bc15c1514f324c2b  powerdevil-5.18.5.tar.xz
17bfd342f132fac634ffedfe2779a675  plasma-desktop-5.18.5.tar.xz
48726cf667fac5c2f38fa045dde636c4  kdeplasma-addons-5.18.5.tar.xz
58a43b57acc4ff8de899d7c57a8ce90a  kgamma5-5.18.5.tar.xz
197400f3c766b560dded88bd05266dfc  ksshaskpass-5.18.5.tar.xz
#65136393474814073877cdb17f953149  plasma-sdk-5.18.5.tar.xz
98c4bd10c1176e2d526b6e4dc55a1835  sddm-kcm-5.18.5.tar.xz
2b16115046eb7fef09fa4f438be64591  user-manager-5.18.5.tar.xz
34bad73daf95652b298bb990578e6bb0  discover-5.18.5.tar.xz
#28df67486f98d567f01db35dccba5714  breeze-grub-5.18.5.tar.xz
#9dd90fa2b868a8557dc67b0e86af8722  breeze-plymouth-5.18.5.tar.xz
d7aa47027645ed446177daac5743dd1b  kactivitymanagerd-5.18.5.tar.xz
69312d186b9c7380eeda1032ef327dce  plasma-integration-5.18.5.tar.xz
67277d2623d1fd86fcd073000b84b2f3  plasma-tests-5.18.5.tar.xz
#39b3b50f740b0122dd0db7391a049731  plymouth-kcm-5.18.5.tar.xz
2a6b5f111a111000e83a039ed1d5685e  xdg-desktop-portal-kde-5.18.5.tar.xz
51a6331304780d4f370135f8aeb96848  drkonqi-5.18.5.tar.xz
d7084769f2aee6f41d723d85645b9832  plasma-vault-5.18.5.tar.xz
7fb0482503c46c3852f5fd050ce6f449  plasma-browser-integration-5.18.5.tar.xz
4f5147c3932d1548550e633f0aa4a237  kde-cli-tools-5.18.5.tar.xz
8d46069f6129eea764e3e17469b53bd1  systemsettings-5.18.5.tar.xz
08adc73eacabecc6a4f787bfd0c64dc8  plasma-thunderbolt-5.18.5.tar.xz
#e43f19f06ad0ec687de9ce5362534d88  plasma-nano-5.18.5.tar.xz
#af6d01e56794acc9ca9e721064878133  plasma-phone-components-5.18.5.tar.xz
EOF

as_root()
{
  if   [ $EUID = 0 ];        then $*
  elif [ -x /usr/bin/sudo ]; then sudo $*
  else                            su -c \\"$*\\"
  fi
}

export -f as_root

while read -r line; do

    # Get the file name, ignoring comments and blank lines
    if $(echo $line | grep -E -q '^ *$|^#' ); then continue; fi
    file=$(echo $line | cut -d" " -f2)

    touch /tmp/plasma-done
    if grep $file /tmp/plasma-done; then continue; fi
    wget -nc $url/$file
    if echo $file | grep /; then file=$(echo $file | cut -d/ -f2); fi

    pkg=$(echo $file|sed 's|^.*/||')          # Remove directory
    packagedir=$(echo $pkg|sed 's|\.tar.*||') # Package directory

    tar -xf $file
    pushd $packagedir

       # Fix some build issues when generating some configuration files
       case $name in
         plasma-workspace)
           sed -i '/set.HAVE_X11/a set(X11_FOUND 1)' CMakeLists.txt
         ;;
      
         khotkeys)
           sed -i '/X11Extras/a set(X11_FOUND 1)' CMakeLists.txt
         ;;
      
         plasma-desktop)
           sed -i '/X11.h)/i set(X11_FOUND 1)' CMakeLists.txt
         ;;
       esac

       mkdir build
       cd    build

       cmake -DCMAKE_INSTALL_PREFIX=$KF5_PREFIX \
             -DCMAKE_BUILD_TYPE=Release         \
             -DBUILD_TESTING=OFF                \
             -Wno-dev ..  &&

        make
        as_root make install
    popd


    as_root rm -rf $packagedir
    as_root /sbin/ldconfig

    echo $file >> /tmp/plasma-done

done < plasma-5.18.5.md5


rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
cat > /etc/pam.d/kde << "EOF" 
# Begin /etc/pam.d/kde

auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     include        system-auth

account  include        system-account
password include        system-password
session  include        system-session

# End /etc/pam.d/kde
EOF

cat > /etc/pam.d/kde-np << "EOF" 
# Begin /etc/pam.d/kde-np

auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     required       pam_permit.so

account  include        system-account
password include        system-password
session  include        system-session

# End /etc/pam.d/kde-np
EOF

cat > /etc/pam.d/kscreensaver << "EOF"
# Begin /etc/pam.d/kscreensaver

auth    include system-auth
account include system-account

# End /etc/pam.d/kscreensaver
EOF
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
sed '/^Name=/s/Plasma/Plasma on Xorg/' -i /usr/share/xsessions/plasma.desktop
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
