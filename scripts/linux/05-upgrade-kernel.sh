#!/bin/sh
#error and exit = set -e
#set -o errexit
#color
source /etc/init.d/functions
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

function deal(){
  yum makecache fast -y > /dev/null 2>&1
  rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org > /dev/null 2>&1
  yum install -y https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm > /dev/null 2>&1

  yum --enablerepo=elrepo-kernel install kernel-ml-devel kernel-ml -y > /dev/null 2>&1

  awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg > /tmp/kernel.log 2>&1
  grub2-set-default 0 > /dev/null 2>&1
  grub2-mkconfig -o /etc/grub2.cfg > /dev/null 2>&1
}


function main(){
  action "$0" deal
}

main $*
