#!/bin/sh

VSN="V2"
FILENAME=faxien-piggyback-launcher-$VSN.sh

cat header.txt > $FILENAME
cat faxien.tar.gz >> $FILENAME

echo "done creating $FILENAME"
