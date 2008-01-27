#!/bin/sh

TARGET_ERTS_VSN=5.5.5
CURRENT_BOOTSTRAPPER_VSN="V4"

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

if [ "$#" = "2" ];then

	ERTS_PATH=$1
	BOOTSTRAPPER_VSN=$2

else

	echo ""
	echo "Please a path to erts. [/usr/local/lib/erlang/erts-$TARGET_ERTS_VSN] $> "
	read ERTS_PATH
	echo ""
	echo "Optionally enter additional OS info. For instance an erts package" 
	echo "compiled for mac os 10.4(Tiger) will not run on 10.5(Leopard) and" 
	echo "so for a bootstrapper created on Tiger adding \"Tiger\" or \"10.4\"" 
	echo "here is required if no such condition exists then enter nothing $> "
	read ADDITIONAL_OS_INFO

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
mkdir erts_packages
cp -r $ERTS_PATH ./erts_packages/erts-$ERTS_VSN; or_exit $? "erts copy failed"
rm ./erts_packages/erts-$ERTS_VSN/bin/dialyzer
rm ./erts_packages/erts-$ERTS_VSN/bin/erl
cp ../bootstrap.tar.gz .
tar -zxf bootstrap.tar.gz
rm bootstrap.tar.gz
tar -zcf contents.tar.gz *
mv contents.tar.gz ..
cd -

rm -rf erlware

MACHINE=$(uname -m | sed 's/ /-/')
KERNEL=$(uname -s | sed 's/ /-/')

FILENAME=faxien-launcher-$MACHINE-$KERNEL-$ADDITIONAL_OS_INFO-$CURRENT_BOOTSTRAPPER_VSN.sh
if [ "$ADDITIONAL_OS_INFO" = "" ];then
  FILENAME=faxien-launcher-$MACHINE-$KERNEL-$CURRENT_BOOTSTRAPPER_VSN.sh
fi

cat header.txt > $FILENAME
cat contents.tar.gz >> $FILENAME
rm contents.tar.gz

echo "done creating $FILENAME"
