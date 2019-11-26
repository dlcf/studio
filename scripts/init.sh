#!/bin/sh
curPath=`pwd`
cd `dirname $0`
dirPath=`pwd`
cd $curPath

sh $dirPath/01-yum.sh
