#!/bin/sh

# exit with a nice message on a function failure
or_exit() {
  if [ "$1" != "0" ];then
    echo "\$? = $1"
    echo $2
    exit $1
  fi
}

do_md5() {
  if exists md5sum; then
    md5sum | awk '{ print $1 }'
  elif exists md5; then
    md5
  elif exists openssl; then
    openssl md5
  else
    echo "Couldn't find 'md5sum' or 'md5' or 'openssl' in path!" >&2
    echo "Please add one of these to your path and rerun." >&2
    exit 1
  fi
}

exists() {
   test -n "`which $1 2> /dev/null`"
}


rm -rf erlware

if [ "$1" = "help" ];then
	echo "$0 [path_to_erlang  launcher_path  suffix]"
	exit 0
fi

if [ "$#" = "3" ];then

	ERLANG_PATH=$1
	LAUNCHER_PATH=$2
	SUFFIX=$3

else

	echo "Please enter the location of an erlang installation $"
	read ERLANG_PATH
	echo "Enter the full path to the faxien_launcher $"
	read LAUNCHER_PATH
	echo "Please enter a filename suffix as in (faxien-bootstrap-<suffix>.sh) $"
	read SUFFIX

fi

ERTS_PATH=$(echo $ERLANG_PATH/erts-*)
echo "Path to Erts: $ERTS_PATH"
ERTS_VSN=$(echo $(basename $ERTS_PATH)| sed 's/erts-//g')
echo "Erts version: $ERTS_VSN"

mkdir erlware
cd erlware
mkdir erts
echo "Copying $ERTS_PATH to erts/$ERTS_VSN"
cp -r $ERTS_PATH erts/$ERTS_VSN; or_exit $? "erts copy failed"
rm erts/$ERTS_VSN/bin/dialyzer
rm erts/$ERTS_VSN/bin/erl
wget -O - http://repo.erlware.org/pub/bootstrap/bootstrap.tar.gz | tar -xzv
cd -

FAXIEN_LAUNCHER=$LAUNCHER_PATH/faxien_launcher
echo "copy $FAXIEN_LAUNCHER to erlware/bin"
cp $FAXIEN_LAUNCHER erlware/bin; or_exit $? "faxien launcher copy failed"

cd erlware
tar czhf tmp.tar.gz *

sed -e "s/__REPLACE_WITH_MD5_SUM__/`cat tmp.tar.gz | do_md5`/g" ../header.txt > lheader.txt

LAUNCHER_FILE=faxien-bootstrap-$SUFFIX.sh
cat lheader.txt tmp.tar.gz > $LAUNCHER_FILE
mv $LAUNCHER_FILE ..
cd -
rm -rf erlware

echo "done"
