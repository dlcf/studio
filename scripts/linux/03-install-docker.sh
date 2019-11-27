#!/bin/sh
#error and exit = set -e
#set -o errexit
#color
source /etc/init.d/functions
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

function createConfig(){
mkdir -p /etc/docker/
cat>/etc/docker/daemon.json<<\EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "registry-mirrors": [
    "https://fz5yth0r.mirror.aliyuncs.com",
    "https://hub-mirror.c.163.com",
    "https://registry.docker-cn.com",
    "https://docker.mirrors.ustc.edu.cn"
  ],
  "graph":"/var/lib/docker",
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
EOF
}

function deal(){
  if [ ! -f /etc/docker/daemon.json ] ;then
     createConfig
  fi
  if [ ! -f /etc/yum.repos.d/docker-ce.repo ] ;then
     curl -sL http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo
  fi
  export docker_version=18.09.9
  version=$(yum list docker-ce.x86_64 --showduplicates|sort -r|grep ${docker_version}|awk '{print $2}')
  yum -y install --setopt=obsoletes=0 docker-ce-${docker_version} docker-ce-selinux-${docker_version} docker-compose > /dev/null
  systemctl enable --now docker > /dev/null
}


function main(){
  action "$0" deal
  # yum -y install yum-plugin-versionlock
  # yum versionlock docker-ce
  # yum versionlock delete docker-ce
  # yum versionlock clear
}

main $*
