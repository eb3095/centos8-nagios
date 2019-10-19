#!/bin/bash

# Install dependencies
yum install -y gcc glibc glibc-common openssl openssl-devel perl wget make gettext automake net-snmp net-snmp-utils epel-release

# Build NRPE
cd /tmp
wget --no-check-certificate -O nrpe.tar.gz https://github.com/NagiosEnterprises/nrpe/archive/nrpe-3.2.1.tar.gz
tar xzf nrpe.tar.gz
cd /tmp/nrpe-nrpe-3.2.1/
./configure --enable-command-args
make all
make install-groups-users
make install
make install-config
make install-init

# Build NRPE Plugins
cd /tmp
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz
tar zxf nagios-plugins.tar.gz
cd /tmp/nagios-plugins-release-2.2.1/
./tools/setup
./configure
make
make install

# Label port
echo >> /etc/services
echo '# Nagios services' >> /etc/services
echo 'nrpe    5666/tcp' >> /etc/services

# Add firewall rule
firewall-cmd --zone=public --add-port=5666/tcp --permanent

# Configure
sed -i 's/^dont_blame_nrpe=.*/dont_blame_nrpe=1/g' /usr/local/nagios/etc/nrpe.cfg

# Enable
systemctl enable nrpe.service
