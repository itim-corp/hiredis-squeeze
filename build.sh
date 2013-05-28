#!/bin/sh -e
if [ "$1" = " -h" ] || [ "$1" = "--help" ] 
then
	echo "usage: ./build.sh [version [debian changelog message]]"
	exit 1 
fi
cd hiredis
if [ "$1" != "" ]
then
	USCAN_OPTS="--download-version $1"
fi
if [ "$2" != "" ]
then 
	CHANGELOG="$2"
else
	CHANGELOG="Building from source"
fi
set +e #uscan returns 1 when new repo is found 0 otherwise
uscan $USCAN_OPTS
set -e
CNT=`ls ../*orig.tar.gz | wc -l`
if [ "$CNT" -eq "0" ]
then 
	echo "No orig.tar.gz. Seems that uscan failed."
	exit 1
fi
if [ "$CNT" -gt "1" ]
then 
	echo "ambigous orig.tar.gz. Please delete all orig.tar.gz.archives and rerun build"
	exit 1
fi
VERSION=`ls ../*orig.tar.gz | sed 's/^.*hiredis_\(.*\)\.orig\.tar\.gz/\1/g'`
dch -v $VERSION "$CHANGELOG"
tar -xzf ../*orig.tar.gz --strip-components=1
dpkg-buildpackage

