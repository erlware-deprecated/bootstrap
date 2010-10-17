#!/bin/sh

VSN="V1"
FILENAME=faxien-launcher-$VSN.sh

cat header.txt > $FILENAME
cat faxien.tar.gz >> $FILENAME

echo "done creating $FILENAME"
