#!/bin/sh

TARGET_ERTS_VSN=5.7.1
CURRENT_BOOTSTRAPPER_VSN="V9"

# exit with a nice message on a function failure.
or_exit() {
  if [ "$1" != "0" ];then
    echo "\$? = $1"
    echo $2
    exit $1
  fi
}

if [ "$1" = "help" ];then
	echo "$0 [path_to_erlang]"
	exit 0
fi

if [ "$#" = "1" ];then

	ERTS_PATH=$1

else

	echo ""
	echo "Please enter a path to erts. [/usr/local/lib/erlang/erts-$TARGET_ERTS_VSN] $> \c" 
	read ERTS_PATH

fi

if [ "$ERTS_PATH" = "" ];then
	ERTS_PATH="/usr/local/lib/erlang/erts-$TARGET_ERTS_VSN"
fi

echo "Path to Erts: $ERTS_PATH"
ERTS_VSN=$(basename $ERTS_PATH | sed 's/erts-//')

if [ "$ERTS_VSN" != "$TARGET_ERTS_VSN" ];then
  echo "Erts version must be $TARGET_ERTS_VSN. You supplied $ERTS_VSN."
  exit 1
fi

mkdir erlware
cd erlware
cp ../bootstrap.tar.gz .
tar -zxf bootstrap.tar.gz
rm bootstrap.tar.gz
INSTALLED_ERTS_PATH="./erts-$ERTS_VSN"
cp -r $ERTS_PATH $INSTALLED_ERTS_PATH; or_exit $? "erts copy failed"
rm $INSTALLED_ERTS_PATH/bin/dialyzer
rm $INSTALLED_ERTS_PATH/bin/erl
tar -zcf contents.tar.gz *
mv contents.tar.gz ..
cd -

rm -rf erlware

MACHINE=$(uname -m | sed 's/ /-/')
KERNEL=$(uname -s | sed 's/ /-/')

KERNEL_VSN=$(uname -r | sed -e 's;-.*;;')
FILENAME=faxien-launcher-$MACHINE-$KERNEL-$KERNEL_VSN-$CURRENT_BOOTSTRAPPER_VSN.sh

cat header.txt > $FILENAME
cat contents.tar.gz >> $FILENAME
rm contents.tar.gz

echo "done creating $FILENAME"
