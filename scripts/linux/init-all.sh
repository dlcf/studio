#!/bin/sh
curPath=`pwd`
cd `dirname $0`
dirPath=`pwd`

sh 01-install-aliyum.sh
sh 02-install-tools.sh
sh 03-install-docker.sh
sh 04-install-ansible.sh
sh 05-upgrade-kernel.sh
sh 06-system-param.sh
sh 07-optimizing-config.sh

cd $curPath
