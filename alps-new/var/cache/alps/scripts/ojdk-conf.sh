#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf


cd $SOURCE_DIR

NAME=ojdk-conf
VERSION=1

SECTION="Programming"
DESCRIPTION="After the package installation is complete, the next step is to make sure that the system can properly find the files. If you set up your login scripts as recommended in The Bash Shell Startup Files, update the environment by creating the openjdk.sh script, as the root user:"


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
cat > /etc/profile.d/openjdk.sh << "EOF"
# Begin /etc/profile.d/openjdk.sh

# Set JAVA_HOME directory
JAVA_HOME=/opt/jdk

# Adjust PATH
pathappend $JAVA_HOME/bin

# Add to MANPATH
pathappend $JAVA_HOME/man MANPATH

# Auto Java CLASSPATH: Copy jar files to, or create symlinks in, the
# /usr/share/java directory. Note that having gcj jars with OpenJDK 8
# may lead to errors.

AUTO_CLASSPATH_DIR=/usr/share/java

pathprepend . CLASSPATH

for dir in `find ${AUTO_CLASSPATH_DIR} -type d 2>/dev/null`; do
    pathappend $dir CLASSPATH
done

for jar in `find ${AUTO_CLASSPATH_DIR} -name "*.jar" 2>/dev/null`; do
    pathappend $jar CLASSPATH
done

export JAVA_HOME
unset AUTO_CLASSPATH_DIR dir jar

# End /etc/profile.d/openjdk.sh
EOF
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
cat > /etc/sudoers.d/java << "EOF"
Defaults env_keep += JAVA_HOME
Defaults env_keep += CLASSPATH
EOF
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
cat >> /etc/man_db.conf << "EOF" &&
# Begin Java addition
MANDATORY_MANPATH     /opt/jdk/man
MANPATH_MAP           /opt/jdk/bin     /opt/jdk/man
MANDB_MAP             /opt/jdk/man     /var/cache/man/jdk
# End Java addition
EOF

mkdir -p /var/cache/man &&
mandb -c /opt/jdk/man
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
/opt/jdk/bin/keytool -list -cacerts
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
