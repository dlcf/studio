#!/bin/sh
#error and exit = set -e
#set -o errexit
#color
source /etc/init.d/functions
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

toolsName="lsof lrzsz telnet traceroute net-tools bash-completion vim yum-utils yum-plugin-versionlock python3-pip git sshpass mtr conntrack-tools libseccomp libtool-ltdl device-mapper-persistent-data lvm2 conntrack ipvsadm ipset jq sysstat iotop iftop htop"

function deal(){
  yum install $toolsName -y > /dev/null 2>&1
}


function main(){
  action "$0" deal
}

main $*
