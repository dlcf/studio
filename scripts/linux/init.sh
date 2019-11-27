#!/bin/sh
curPath=`pwd`
cd `dirname $0`
dirPath=`pwd`

sh 01-install-aliyum.sh
sh 02-install-tools.sh
sh 03-install-docker.sh
sh 04-install-ansible.sh

cd $curPath
