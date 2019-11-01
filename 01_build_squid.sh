#!/bin/bash
# Helge custom script to build latest squid package from debian-testing with ssl interception
#######################################################################################
#Configure apt and build dependencies
rm /etc/apt/sources.list

printf "deb http://deb.debian.org/debian/ $RELEASE main contrib non-free" >> /etc/apt/sources.list
printf "\ndeb-src http://deb.debian.org/debian/ $RELEASE main contrib non-free" >> /etc/apt/sources.list
printf "\ndeb http://deb.debian.org/debian/ $RELEASE-updates main contrib non-free" >> /etc/apt/sources.list
printf "\ndeb-src http://deb.debian.org/debian/ $RELEASE-updates main contrib non-free" >> /etc/apt/sources.list
printf "\ndeb http://deb.debian.org/debian-security $RELEASE-security main" >> /etc/apt/sources.list
printf "\ndeb-src http://deb.debian.org/debian-security $RELEASE-security main" >> /etc/apt/sources.list

apt update && apt upgrade
apt -y install samba-dev dh-apparmor libwbclient-dev libnss-winbind libpam-winbind dpkg-dev libssl-dev nano libcrypto++-dev devscripts build-essential fakeroot libwbclient-dev libsmbclient-dev libsasl2-dev build-essential console-setup dialog apt locales smbclient
apt -y build-dep squid
apt -y build-dep openssh
apt -y build-dep openssl
apt -y build-dep smbclient

# Create temporary directory and get squid sources
temp_dir=$(mktemp -d)
squid_base=/tmp
squid_path=$squid_base/squid/

cd ${temp_dir}
apt-get source squid
mkdir $squid_path
cp -r squid-*/* $squid_path
cd $squid_path
rm -rf ${temp_dir}

#######################################################################################
#hotfix gnutls broken
# nur squid3
#sed -i "s|--with-gnutls||g" $CHROOTD/tmp/squid/debian/rules

# Tune debian/rules
sed -i "s,/var/run/squid.pid,/var/run/squid/squid.pid,g" $squid_path/debian/rules
sed -i '/with-default-user=proxy/i \\t\t--enable-ssl \\' $squid_path/debian/rules
sed -i '/with-default-user=proxy/i \\t\t--enable-ssl-crtd \\' $squid_path/debian/rules
sed -i '/with-default-user=proxy/i \\t\t--with-openssl \\' $squid_path/debian/rules
printf "\tinstall -m 755 -o proxy -g proxy -d debian/squid/var/run/squid" >> $squid_path/debian/rules

#multicore compile
#MAKEFLAGS += -j4
sed -i '2 a MAKEFLAGS += -j4' debian/rules
#######################################################################################
#build
#sudo ./configure && fakeroot debian/rules binary && cd ..
#Aufräumen des Quellverzeichnisbaums (»debian/rules clean«),
#Bauen des Quellpakets (»dpkg-source -b«),
#Bauen des Programms (»debian/rules build«),
#Bauen der Binärpakete (»fakeroot debian/rules binary«),
#just build debs
#dpkg-buildpackage -rfakeroot -b

sh $squid_path/configure 
sh fakeroot bash $squid_path/debian/rules binary
