#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:apache
#REQ:libxml2


cd $SOURCE_DIR

NAME=php
VERSION=7.4.9
URL=http://www.php.net/distributions/php-7.4.9.tar.xz
SECTION="Programming"
DESCRIPTION="PHP is the PHP Hypertext Preprocessor. Primarily used in dynamic web sites, it allows for programming code to be directly embedded into the HTML markup. It is also useful as a general purpose scripting language."

wget -nc $URL
https://www.php.net/distributions/manual/php_manual_en.html.gz
https://www.php.net/distributions/manual/php_manual_en.tar.gz

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

./configure --prefix=/usr                \
            --sysconfdir=/etc            \
            --localstatedir=/var         \
            --datadir=/usr/share/php     \
            --mandir=/usr/share/man      \
            --enable-fpm                 \
            --without-pear               \
            --with-fpm-user=apache       \
            --with-fpm-group=apache      \
            --with-fpm-systemd           \
            --with-config-file-path=/etc \
            --with-zlib                  \
            --enable-bcmath              \
            --with-bz2                   \
            --enable-calendar            \
            --enable-dba=shared          \
            --with-gdbm                  \
            --with-gmp                   \
            --enable-ftp                 \
            --with-gettext               \
            --enable-mbstring            \
            --disable-mbregex            \
            --with-readline              &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install                                     &&
install -v -m644 php.ini-production /etc/php.ini &&

install -v -m755 -d /usr/share/doc/php-7.4.9 &&
install -v -m644    CODING_STANDARDS* EXTENSIONS NEWS README* UPGRADING* \
                    /usr/share/doc/php-7.4.9
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
if [ -f /etc/php-fpm.conf.default ]; then
  mv -v /etc/php-fpm.conf{.default,} &&
  mv -v /etc/php-fpm.d/www.conf{.default,}
fi
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

wget http://pear.php.net/go-pear.phar
php ./go-pear.phar
rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
sed -i 's@php/includes"@&\ninclude_path = ".:/usr/lib/php"@' \
    /etc/php.ini
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
sed -i -e '/proxy_module/s/^#//'      \
       -e '/proxy_fcgi_module/s/^#//' \
       /etc/httpd/httpd.conf
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
echo \
'ProxyPassMatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/srv/www/$1' >> \
/etc/httpd/httpd.conf
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
#!/bin/bash

set -e
set +h


. ~/.bashrc
. /etc/alps/alps.conf

pushd $SOURCE_DIR
wget -nc http://www.linuxfromscratch.org/blfs/downloads/systemd/blfs-systemd-units-20200415.tar.xz
tar xf blfs-systemd-units-20200415.tar.xz
cd blfs-systemd-units-20200415
sudo make install-php-fpm
popd
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

sudo systemctl enable php-fpm && sudo systemctl start php-fpm && sudo systemctl restart httpd
	
if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
