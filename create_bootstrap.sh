#!/bin/sh

TARGET_ERTS_VSN=5.5.5

# exit with a nice message on a function failure.
or_exit() {
  if [ "$1" != "0" ];then
    echo "\$? = $1"
    echo $2
    exit $1
  fi
}

if [ "$1" = "help" ];then
	echo "$0 [path_to_erlang  suffix]"
	exit 0
fi

if [ "$#" = "2" ];then

	ERTS_PATH=$1
	BOOTSTRAPPER_VSN=$2

else

	echo ""
	echo "Please enter the location of a working erts-$TARGET_ERTS_VSN as in /usr/local/lib/erlang/erts-5.5.5 $"
	read ERTS_PATH
	echo ""
	echo "Please enter a version string for the bootstrapper to be created (example: 0.2.1) $"
	echo "This is also a good place to add additional information obout the target system "
	echo "as in \"Leopard-0.9.1-0.2.1\" $"
	read BOOTSTRAPPER_VSN

fi

echo "Path to Erts: $ERTS_PATH"
ERTS_VSN=$(basename $ERTS_PATH | sed 's/erts-//')

if [ "$ERTS_VSN" != "$TARGET_ERTS_VSN" ];then
  echo "Erts version must be $TARGET_ERTS_VSN. You supplied $ERTS_VSN."
  exit 1
fi

mkdir erlware
cd erlware
mkdir erts
echo "Copying $ERTS_PATH to erts/$ERTS_VSN"
cp -r $ERTS_PATH erts/$ERTS_VSN; or_exit $? "erts copy failed"
rm erts/$ERTS_VSN/bin/dialyzer
rm erts/$ERTS_VSN/bin/erl
cp ../bootstrap.tar.gz .
tar -zxf bootstrap.tar.gz
rm bootstrap.tar.gz
tar -zcf contents.tar.gz *
mv contents.tar.gz ..
cd -

rm -rf erlware

FILENAME=faxien-launcher-$(uname -m)-$(uname -s)-$BOOTSTRAPPER_VSN.sh
cat header.txt > $FILENAME
cat contents.tar.gz >> $FILENAME
rm contents.tar.gz

echo "done creating $FILENAME"
