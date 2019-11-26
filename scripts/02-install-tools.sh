#!/bin/sh
#error and exit = set -e
#set -o errexit
#color
source /etc/init.d/functions
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

toolsName="lsof lrzsz telnet traceroute net-tools bash-completion vim yum-utils"

function deal(){
  yum install $toolsName -y > /dev/null
}


function main(){
  action "install tools" deal
}

main
