#!/bin/sh
#error and exit = set -e
#set -o errexit
#color
source /etc/init.d/functions
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

function historyConf(){
	PROMPTCOUNT=`grep "PROMPT_COMMAND" /etc/profile |wc -l`
	if [ $PROMPTCOUNT -eq 0 ];then
    	cat >> /etc/profile << \EOF
export HISTTIMEFORMAT="[%F %T] "
export PROMPT_COMMAND='
command_history="$( history 1 |sed "s/^ *\([0-9]*\) *\[[0-9]*-[0-9]*-[0-9]* *[0-9]*:[0-9]*:[0-9]*] *\(.*\)$/\2   #seq=[\1]/g")"
command_history_v=${command_history}" `whoami`"
command_history_vv=${command_history}" $( who am i | sed -r "s|^([^ \t]+)[ \t]+([^ \t]+)[ \t]+(.+)[ \t]+(\(.+\))|user=[\1] tty=[\2] date=[\3] ip=\4|") pwd=[`pwd`]"
echo "$command_history_vv" >> /var/log/usercmd.log
'
EOF
		touch /var/log/usercmd.log
		chmod 622 /var/log/usercmd.log
	else
		echo -e "${yellow}Warn:${plain} history have been configured !"
	fi

}

function chronyConf(){
  cat > /etc/chrony.conf <<EOF

# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (http://www.pool.ntp.org/join.html).
#server 0.centos.pool.ntp.org iburst
#server 1.centos.pool.ntp.org iburst
#server 2.centos.pool.ntp.org iburst
#server 3.centos.pool.ntp.org iburst

server ntp1.aliyun.com iburst
server ntp2.aliyun.com iburst
server ntp6.aliyun.com iburst
server ntp7.aliyun.com iburst
# Record the rate at which the system clock gains/losses time.
driftfile /var/lib/chrony/drift

# Allow the system clock to be stepped in the first three updates
# if its offset is larger than 1 second.
makestep 1.0 3

# Enable kernel synchronization of the real-time clock (RTC).
rtcsync

# Enable hardware timestamping on all interfaces that support it.
#hwtimestamp *

# Increase the minimum number of selectable sources required to adjust
# the system clock.
#minsources 2

# Allow NTP client access from local network.
#allow 192.168.0.0/16

# Serve time even if not synchronized to a time source.
#local stratum 10

# Specify file containing keys for NTP authentication.
#keyfile /etc/chrony.keys

# Specify directory for log files.
logdir /var/log/chrony

# Select which information is logged.
#log measurements statistics tracking

EOF
}

function securityConf(){
  sed -i '/^SELINUX=enforcing/s@enforcing@disabled@' /etc/selinux/config
  sed -i '/^SELINUX=permissive/s@permissive@disabled@' /etc/selinux/config
  setenforce 0 > /dev/null 2>&1
  systemctl stop firewalld.service
  systemctl disable firewalld.service > /dev/null 2>&1
  echo -e "${yellow}Warn:${plain} Firewalld is stop !"
}

function personConf(){

    swapoff -a
    sed -i 's/.*swap.*/#&/' /etc/fstab

    chmod +x /etc/rc.d/rc.local
    
    cat /etc/issue > /etc/issue.bak
    cat /dev/null > /etc/issue
    
    timedatectl set-timezone "Asia/Shanghai"
    
    rm -f  /usr/lib/systemd/system/ctrl-alt-del.target
    echo "set paste" >> /root/.vimrc
    echo "set ts=4" >> /root/.vimrc
	
}

function deal(){
  historyConf
  chronyConf
  securityConf
  personConf
}


function main(){
  action "$0" deal
}

main $*
