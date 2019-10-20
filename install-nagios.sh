#!/bin/bash

# Install requirements
yum install gcc glibc glibc-common wget gd gd-devel perl postfix nginx mariadb-server php php-mysqlnd php-fpm make gettext automake autoconf openssl-devel net-snmp net-snmp-utils epel-release

# Configure Mariadb
systemctl enable --now mariadb
mysql_secure_installation

# Compile and install Nagios
cd /tmp
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.2.tar.gz
tar xzf nagioscore.tar.gz
cd /tmp/nagioscore-nagios-4.4.2
./configure
make all
make install-groups-users
usermod -a -G nagios nginx
make install
make install-daemoninit
make install-config
make install-commandmode

# Compile and install Nagios Plugins
cd /tmp
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz
tar zxf nagios-plugins.tar.gz
cd /tmp/nagios-plugins-release-2.2.1/
./tools/setup
./configure
make
make install

# Create nagiosadmin account
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

# Create Nagios Service
cp /lib/systemd/system/nagios.service /etc/systemd/system/nagios.service

# Enable Services
systemctl enable --now nginx
systemctl enable --now nagios
