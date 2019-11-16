#!/bin/bash
yum install dos2unix -y
dos2unix zabbix-src-install.sh
server='Zabbix service'
hostname=127.0.0.1
echo "[Start to Install Zabbix Agent...]"

echo "Install Zabbix Dependency"
yum -y install net-snmp-devel libxml2-devel libcurl-deve libevent libevent-devel curl curl-devel mydql-devel net-snmp snmp perl-DBI php-gd php-xml php-bcmath \
php-mbstring php-ldap php-odbc php-xmlrpc mariadb-devel deltarpm gcc mariadb-devel
echo 'Install Dependency Success '

echo " Create Zabbix User And Group"
groupadd zabbix
useradd -g zabbix zabbix
echo 'Create Zabbix User And Group Success'

echo 'Tar zabbix-4.2.0.tar To /Usr/src'
tar -zxf zabbix-4.2.0.tar -C /usr/src/
echo 'Tar zabbix-4.2.0.tar To /Usr/src Success'

cd /usr/src/zabbix-4.2.0
./configure --prefix=/usr/local/zabbix --sysconfdir=/etc/zabbix --enable-agent --enable-proxy --with-mysql --enable-net-snmp --with-libcurl
make && make install  

cp misc/init.d/fedora/core/zabbix_agentd  /etc/init.d/
cp misc/init.d/fedora/core/zabbix_agentd /usr/local/sbin/
chmod 755 /etc/init.d/zabbix_agentd

if [[ ! -f '/etc/zabbix' ]]; then
    mkdir -p /etc/zabbix
fi

if [[ ! -f '/etc/zabbix/zabbix_agentd.conf' ]]; then
   cp conf/zabbix_agentd.conf  /etc/zabbix/
fi


echo '[Edit the Config File]'
sed -i 's/# EnableRemoteCommands=0/EnableRemoteCommands=1/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# LogRemoteCommands=0/LogRemoteCommands=1/g' /etc/zabbix/zabbix_agentd.conf

sed -i "s/Server=127.0.0.1/Server=$server/g" /etc/zabbix/zabbix_agentd.conf
sed -i "s/ServerActive=127.0.0.1/ServerActive=$server/g" /etc/zabbix/zabbix_agentd.conf

sed -i "s/Hostname=Zabbix server/Hostname=$hostname/g" /etc/zabbix/zabbix_agentd.conf
echo "[Edit The File  Success !!!!!]"


#Start Zabbix-agent on Boot
chkconfig zabbix_agentd on
systemctl start zabbix_agentd

if
	ps -A | grep "zabbix_agent" 
	then
		echo "Zabbix-agent is Running"
	else
		echo "Zabbix-agent is not Run, Please check whether the Zabbix-agent is installed correctly."
fi
