#!/bin/sh

rm -rf erlware

ERTS_PATH=$(dirname $(dirname $(ls /tmp/erlang/lib/erlang/erts-*/bin/erl)))
echo "Path to Erts: $ERTS_PATH"
ERTS_VSN=$(echo $(basename $ERTS_PATH)| sed 's/erts-//g')
echo "Erts version: $ERTS_VSN"

mkdir erlware
cd erlware
wget -O - http://repo.erlware.org/pub/bootstrap/bootstrap.tar.gz | tar -xzv
mkdir erts
echo "Copying $ERTS_PATH to erts/$ERTS_VSN"
cp -r $ERTS_PATH erts/$ERTS_VSN
rm erts/$ERTS_VSN/bin/dializer
rm erts/$ERTS_VSN/bin/erl
cd -

echo "Enter the full path to the faxien_launcher $"
read LAUNCHER_PATH

FAXIEN_LAUNCHER=$LAUNCHER_PATH/faxien_launcher
echo "copy $FAXIEN_LAUNCHER to erlware/bin"
cp $FAXIEN_LAUNCHER erlware/bin

cd erlware
tar czhf tmp.tar.gz *

echo "Is this bootstrap for mac or linux/unix? [m|l] $"
read OS
case $OS in
    l)
	sed -e "s/__REPLACE_WITH_MD5_SUM__/`cat tmp.tar.gz | md5sum`/g" ../unix/header.txt > lheader.txt
         ;;
    m)
	sed -e "s/__REPLACE_WITH_MD5_SUM__/`cat tmp.tar.gz | /sbin/md5`/g" ../osx/header.txt > lheader.txt
         ;;
    *)
         echo "$OS is bad input - enter m or l"
	 exit 1
         ;;
esac

echo "Please enter a platform string in for this platform, something like i386-linux $"
read PLATFORM_STRING
echo "Please enter the version for this launcher $"
read LAUNCHER_VSN

LAUNCHER_FILE=faxien-bootstrap-$PLATFORM_STRING-$LAUNCHER_VSN.sh
cat lheader.txt tmp.tar.gz > $LAUNCHER_FILE
mv $LAUNCHER_FILE ..
cd -
rm -rf erlware

echo "done"
