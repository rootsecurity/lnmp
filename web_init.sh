#!/bin/bash

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en_US.UTF-8
ipaddr=`ifconfig eth0 | grep "inet addr" | awk '{print $2}'|grep -v "127.0.0.1"|tr -d "addr:"|awk '{print $1}'`
rpm --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
yum -y install gcc gcc-c++ make pcre pcre-devel magic pptp-setup python-devel python-setuptools libxml2 libxml2-devel ncurses-devel file-devel libyaml libyaml-devel libhtp libhtp-devel gd gd-devel freetype freetype-devel openssl openssl-devel libcurl libcurl-devel libpcap libpcap-devel lrzsz gd gd-devel libcurl libcurl-devel freetype freetype-devel tcl tcl-devel perl-Time-HiRes

for packages in mysql mysql-libs mysql-devel mysql-server httpd httpd-devel php php-common php-cli php-pear php-gd php-mcrypt php-pecl php-mysql php-devel php-pear-Image-Canvas php-pear-Image-Color php-pear-Image-Graph php-pear-Image-Text php-pear-Mail php-pear-Net-SMTP php-pear-Net-Curl;
do yum -y install $packages;
done

ln -sf /usr/lib64/mysql  /usr/lib/mysql
ln -sf /usr/lib64/libhtp.so /usr/lib/libhtp.so

sed -i 's/exec \/sbin\/shutdown -r now "Control-Alt-Delete pressed"/#exec \/sbin\/shutdown -r now "Control-Alt-Delete pressed"/g' /etc/init/control-alt-delete.conf
sed -i 's/Options Indexes FollowSymLinks/Options FollowSymLinks/g' /etc/httpd/conf/httpd.conf
sed -i 's/expose_php = On/expose_php = Off/g' /etc/php.ini
sed -i 's/ServerTokens OS/ServerTokens Prod/g' /etc/httpd/conf/httpd.conf
sed -i 's/ServerSignature On/ServerSignature Off/g' /etc/httpd/conf/httpd.conf
sed -i 's/ServerAdmin root@localhost/ServerAdmin auto@usa.gov/g' /etc/httpd/conf/httpd.conf
sed -i 's/extension=module.so/;extension=module.so/g' /etc/php.d/mcrypt.ini
sed -i 's/#ServerName www.example.com:80/ServerName '$ipaddr':80/g' /etc/httpd/conf/httpd.conf
sed -i 's/extensions=module.so/;extensions=module.so/g' /etc/php.d/mcrypt.ini
sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
sed -i 's/#MaxAuthTries 6/MaxAuthTries 6/' /etc/ssh/sshd_config
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
echo "net.ipv4.tcp_syncookies=1" >> /etc/sysctl.conf
echo "export HISTTIMEFORMAT=' `whoami` %F %T '" >> /etc/profile

rm -f /etc/httpd/conf.d/welcome.conf
/etc/init.d/mysqld start
/etc/init.d/httpd start

chkconfig --level 2345 httpd on
chkconfig --level 2345 mysqld on
chkconfig --level 2345 ip6tables off
chkconfig --level 2345 iptables off
chkconfig --level 2345 cups off

echo "done!"
