#!/bin/bash

# Check that signed vendors are ok

CHECKSUMS=$( cd $(dirname $0) ; pwd -P )

# update the checksums
cd $CHECKSUMS && git pull >/dev/null 2>/dev/null && cd - >/dev/null

BAD=0
composer show -i > /tmp/packages
PACKAGES=`cut -d ' ' -f 1 /tmp/packages`
for PACKAGE in $PACKAGES
do
    # Get the installed version
    VERSION=`grep -E "$PACKAGE " /tmp/packages | tr -s ' ' | cut -d ' ' -f 2`

    printf "%-55s" "$PACKAGE@$VERSION"

    # Do we have a signature for this package?
    if [ ! -d $CHECKSUMS/$PACKAGE ]; then
        echo -e " \033[43;37m -- \033[m unknown package"
        continue
    fi

    # Do we have a signature for this version?
    CHECKSUM_FILE=$CHECKSUMS/$PACKAGE/$VERSION.txt
    if [ ! -f $CHECKSUM_FILE ]; then
        echo -e " \033[43;37m -- \033[m not signed"
        continue
    fi

    # Is it a fixed tag?
    if [[ $VERSION == dev-* ]]; then
        echo -e " \033[43;37m -- \033[m no signature"
        continue
    fi

    cd vendor/$PACKAGE
    if [ -d ".git" ]; then
        TYPE="Git signature"
        git tag -v $VERSION > /dev/null 2>/dev/null
        RESULT=$?
    else
        TYPE="files signature"

        # Check the file is correct
        gpg --verify $CHECKSUM_FILE >/dev/null 2>/dev/null
        if [ $? -ne 0 ]; then
            RESULT=1
        else
            # Extract the sha1 for files
            SHA1=`grep files_sha1 $CHECKSUM_FILE | tr -s ' ' | cut -d ' ' -f 2`

            # Compute the SHA1 for installed files
            DIR=$(dirname `find . -name composer.json | head -n1`)
            CURRENT_SHA1=`cd $DIR && find . -type f -print0 | xargs -0 shasum | shasum |  tr -s ' ' | cut -d ' ' -f 1`

            # Check that the sha1 in the signed file is the same
            [ "$SHA1" == "$CURRENT_SHA1" ]
            RESULT=$?
        fi
    fi

    if [ $RESULT -eq 0 ]; then
        echo -e " \033[42;37m OK \033[m $TYPE"
    else
        echo -e " \033[41;37m KO \033[m $TYPE"
        BAD=$(($BAD + 1))
    fi

    cd ../../..
done

echo ""
if [ $BAD -ne 0 ]; then
    echo -e "\033[41;37m $BAD packages are potentially corrupted. \033[m"
    echo -e "\033[41;37m Check that you did not add/modify/delete some files. \033[m"
    exit 1
else
    echo -e "\033[42;37m Great! Checked packages are trusted. \033[m"
fi
