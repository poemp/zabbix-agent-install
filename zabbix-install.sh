#!/bin/bash
usage() { echo "Usage: $0 [-s <zabbix server ip(s)>] [-n <zabbix host name>]" 1>&2; exit 1; }
if [ ! "$#" == "4" ]; then usage; fi
while getopts ":s:n:" o; do
    case "${o}" in
        s)
            server=${OPTARG}
            ;;
        n)
            hostname=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

echo "[Start to Install Zabbix Agent...]"
#System Detect from Oneinstack
OS=CentOS
CentOS_RHEL_version=7
OS_BIT=32

#Install Zabbix-agent from repo
yum install wget -y
echo "[-------------------------Centos Install ---------------------------------------]"
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
echo "[Will Install Zabbix-agent in CentOs]"
rpm -Uvh https://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-1.el7.noarch.rpm
rpm clean all
echo "[Successfully installed Zabbix-agent in Centos]"
echo '--------------------------------------------------------'

#Edit the config file
echo '[Edit the Config File]'
sed -i 's/# EnableRemoteCommands=0/EnableRemoteCommands=1/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# LogRemoteCommands=0/LogRemoteCommands=1/g' /etc/zabbix/zabbix_agentd.conf

sed -i "s/Server=127.0.0.1/Server=$server/g" /etc/zabbix/zabbix_agentd.conf
sed -i "s/ServerActive=127.0.0.1/ServerActive=$server/g" /etc/zabbix/zabbix_agentd.conf

sed -i "s/Hostname=Zabbix server/Hostname=$hostname/g" /etc/zabbix/zabbix_agentd.conf
echo "[Edit The File  Success !!!!!]"

#Configure the Iptables
if
	! iptables-save | grep "10050 -j ACCEPT" > /dev/null 2>&1
	then
	iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 10050 -j ACCEPT
else
	echo "Iptables rule have already been set"
fi

#Use rc.local to start zabbix and load iptables on boot
if
	[ ! -f "/etc/rc.local" ]; then
	ln -s /etc/rc.d/rc.local /etc/rc.local
fi
chmod +x /etc/rc.local
service iptables save

#Enable the Sudo for Zabbix Agent
echo "zabbix	ALL=NOPASSWD: ALL" >> /etc/sudoers
sed -i -r "s/Defaults(.*)requiretty/#Defaults		requiretty/g" /etc/sudoers
grep -q '!visiblepw' /etc/sudoers
if [ $? -eq 0 ] ; then
	sed -i -r "s/(.*)Defaults(.*)\!visiblepw/Defaults		visiblepw/g" /etc/sudoers
else
	echo "Defaults		visiblepw" >> /etc/sudoers
fi
echo "[Setting Finished]"
echo ""

#Start Zabbix-agent on Boot
if
	cat /etc/rc.local | grep "service zabbix-agent start" > /dev/null 2>&1
	then
		echo "Start on boot Already Exists"
	else
	echo "[Add Zabbix-Agent start on Boot]"
	if
		cat /etc/rc.local | grep "exit 0" > /dev/null 2>&1
		then
			sed -i "s/exit 0/service zabbix-agent start\nexit 0/g" /etc/rc.local
		else
			echo "service zabbix-agent start" >> /etc/rc.local
	fi
fi
echo "[Starting the Zabbix-Agent....]"

service zabbix-agent start

if
	ps -A | grep "zabbix_agent" > /dev/null 2>&1
	then
		echo "Zabbix-agent is Running"
	else
		echo "Zabbix-agent is not Run, Please check whether the Zabbix-agent is installed correctly."
fi
