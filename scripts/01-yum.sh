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
  mkdir -p /etc/yum.repos.d.bak
  mv /etc/yum.repos.d/* /etc/yum.repos.d.bak/ -f
  curl -sL https://mirrors.aliyun.com/repo/Centos-7.repo -o /etc/yum.repos.d/centos-aliyun-7.repo
  curl -sL https://mirrors.aliyun.com/repo/epel-7.repo -o /etc/yum.repos.d/epel-aliyun-7.repo
  yum makecache fast > /dev/null
}

function checkparam(){
  if [ $# -gt 0 ] ;then
    case $1 in
      "-f")
        return 1
        ;;
      "force")
        return 1
        ;;
      *)
        echo "vaild param is -f or force"
        exit -1
        ;;
    esac
  fi
}

function checkfile(){
  checkparam $*
  if [ $? -eq 1 ] ;then
    action "update aliyun yum." deal
  else
    if [ -d /etc/yum.repos.d.bak ] ;then
      echo -e "${yellow}[$0] /etc/yum.repos.d.bak is exists. force update use param -f or force.${plain}"
      return 0
    else
      action "install aliyun yum." deal
    fi
  fi
}

function main(){
  checkfile $*
}

main $*
