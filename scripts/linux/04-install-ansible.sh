#!/bin/sh
#error and exit = set -e
#set -o errexit
#color
source /etc/init.d/functions
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

toolsName="python3-pip git sshpass"

function deal(){
  yum install $toolsName -y > /dev/null
  mkdir -p ~/.pip
cat << EOF > ~/.pip/pip.conf
[global]
index-url = http://mirrors.aliyun.com/pypi/simple/
[install]
trusted-host = mirrors.aliyun.com
EOF
  pip3 install --no-cache-dir ansible > /dev/null
}


function main(){
  action "$0" deal
  echo -e "${green}ansible install k8s exec \ncd ~\ngit clone https://github.com/dlcf/a5e-k8s.git${plain}"
}

main $*
