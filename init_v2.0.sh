#!/bin/bash
#

##----------------------------##
# @Time:2015-10-30 11:30:06    #
# @rootsecurity                #
# @Ver:1.0                     #
##----------------------------##

base_init_repo() {
	if [ -s /etc/issue ] && grep 'CentOS release 6.*' /etc/issue; then
		rm -rf /etc/yum.repos.d/*
		wget -q https://lug.ustc.edu.cn/wiki/_export/code/mirrors/help/centos?codeblock=2 -O CentOS-Base.repo
		wget -q https://lug.ustc.edu.cn/wiki/_export/code/mirrors/help/epel?codeblock=0 -O epel.repo
		wget -q https://lug.ustc.edu.cn/wiki/_export/code/mirrors/help/epel?codeblock=1 -O epel-testing.repo
		mv *.repo /etc/yum.repos.d/
		yum clean all && yum makecache
		echo -e '\033[33m |---------- yum repo源即将设置完毕，请稍候!!! ----------|\033[0m' && sleep 2
	fi
	if [ -s /etc/issue ] && grep 'CentOS release 5.*' /etc/issue; then
		rm -rf /etc/yum.repos.d/*
		wget -q https://lug.ustc.edu.cn/wiki/_export/code/mirrors/help/centos?codeblock=1 -O CentOS-Base.repo
		wget -q https://lug.ustc.edu.cn/wiki/_export/code/mirrors/help/epel?codeblock=0 -O epel.repo
		wget -q https://lug.ustc.edu.cn/wiki/_export/code/mirrors/help/epel?codeblock=1 -O epel-testing.repo
		mv *.repo /etc/yum.repos.d/
		yum clean all && yum makecache
		echo -e '\033[33m |---------- yum repo源即将设置完毕，请稍候!!! ----------|\033[0m' && sleep 2
	fi
}

base_init_yum() {
	if [ ! -f "/tmp/init.lock" ]; then 
		echo -e '\033[33m |---------- 系统即将 yum 安装依赖包，请稍候!!! ----------|\033[0m' && sleep 2 && touch /tmp/init.lock
		for packages in yum -y install gcc gcc-c++ make libedit pcre pcre-devel magic flex libevent libevent-devel bison libtool* gperftools-libs bzip2-devel iptraf pptp-setup python-devel python-setuptools libxml2 libxml2-devel gettext gettext-devel ncurses-devel file file-devel libyaml libyaml-devel libhtp libhtp-devel gd gd-devel freetype freetype-devel openssl openssl-devel libcurl libcurl-devel libpcap libpcap-devel lrzsz gd gd-devel libcurl libcurl-devel freetype freetype-devel tcl tcl-devel perl-Time-HiRes
		do
			yum -y install $packages
		done
		echo -e '\033[33m |---------- 系统即将yum 卸载依赖包，请稍候!!! ----------|\033[0m' && sleep 2
		yum -y remove postfix mysql-libs
		echo -e '\033[33m |---------- 系统即将 yum 安装依赖包，请稍候!!! ----------|\033[0m' && sleep 2
		yum -y install sysstat cronie crontabs cronie-anacron
		else
			echo -e '\033[33m |---------- yum初始化已完成，无需再次初始化!!! ----------|\033[0m'
			exit 0
		fi
}

base_add_user() {
	groupadd -g 555 rootsecurity
	useradd -u 555 -g rootsecurity rootsecurity
	echo "91Tm3ALai138))rksj4" | passwd --stdin root
	echo "B91o1,7an371n43oL18" | passwd --stdin rootsecurity
	sleep 2 && echo -e '\033[33m |---------- 用户更新完毕!!! ----------|\033[0m'
}

base_add_mysql_user() {
	groupadd -g 600 mysql
	useradd -u 600 -g mysql mysql
	echo "18bhsLU&!B&NQ*NBJ!1" | passwd --stdin mysql
	sleep 2 && echo -e '\033[33m |---------- 用户更新完毕!!! ----------|\033[0m'
} 

base_add_www_user() {
	groupadd -g 601 www
	useradd -u 601 -g www www
	echo "8mB482n@)4k1n3u81m7" | passwd --stdin root
	sleep 2 && echo -e '\033[33m |---------- 用户更新完毕!!! ----------|\033[0m'
}

base_set_ssh() {
	sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config
	sed -i 's/#PermitRootLogin yes/PermitRootLogin no /' /etc/ssh/sshd_config
	sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
	sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
	sed -i 's/#GSSAPIAuthentication no/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
	sed -i 's/GSSAPIAuthentication yes/#GSSAPIAuthentication yes/g' /etc/ssh/sshd_config
	sed -i 's/Defaults    requiretty/#Defaults    requiretty/' /etc/sudoers
	sed -i -e  '/^root/a \rootsecurity	ALL=(ALL)       NOPASSWD:ALL' /etc/sudoers
	echo -e '\033[33m |---------- SSH服务设置完毕!!! ----------|\033[0m'
	sleep 2 && /etc/init.d/sshd restart
}

base_set_sysctl() {
sed -i 's/net.bridge.bridge-nf-call-ip6tables = 0/#net.bridge.bridge-nf-call-ip6tables = 0/g' /etc/sysctl.conf
sed -i 's/net.bridge.bridge-nf-call-iptables = 0/#net.bridge.bridge-nf-call-iptables = 0/g' /etc/sysctl.conf
sed -i 's/net.bridge.bridge-nf-call-arptables = 0/#net.bridge.bridge-nf-call-arptables = 0/g' /etc/sysctl.conf
cat >> /etc/sysctl.conf << SYSCTL
net.core.somaxconn = 32768
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 0
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.ip_local_port_range = 1024  65535
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_keepalive_time = 100
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 20000
net.ipv4.ip_default_ttl = 255
SYSCTL
/sbin/sysctl -p && sleep 2
echo -e '\033[33m |---------- SYSCTL设置完毕!!! ----------|\033[0m'
}

base_add_dir() {
	mkdir -p /export/{App,Config,Log,MySQLData,Service,Server,Shell,Zookeeper}
	mkdir -p /export/Log/{mysql,nginx,php-fpm,httpd}
	chown -R mysql.mysql /export/MySQLData
	chown -R mysql.mysql /export/Log/mysql
	chown -R www.www /export/Log/nginx
	chown -R www.www /export/App
	echo -e '\033[33m |---------- 系统目录设置完毕!!! ----------|\033[0m'
}

base_set_services() {
for service_off in iptables ip6tables; do chkconfig --level 2345 $service_off off;done
for service_on in sshd network sysstat; do chkconfig --level 2345 $service_on on;done
sleep 2 && echo -e '\033[33m |---------- 系统服务设置完毕!!! ----------|\033[0m'
}

base_set_timezone() {
	ntpserv=`rpm -qa |grep ntp-4.2 |wc -l`
	if [ $ntpserv == "0" ]; then
		yum install ntp ntpdate
	else 
		yum remove ntp && yum install ntp 
	fi
cat > /etc/sysconfig/clock <<DATE
ZONE="Asia/Shanghai"
UTC=false
ARC=false
DATE
ntpdate cn.pool.ntp.org > /dev/null 2>&1
echo -e '\033[33m |---------- 系统时间设置完毕!!! ----------|\033[0m'
}

case $1 in
	repo)
		base_init_repo
		;;
	yum)
		base_init_yum
		;;
	add_user)
		base_add_user
		;;
	add_mysql_user)
		base_add_mysql_user
		;;
	add_www_user)
		base_add_www_user
		;;
	ssh)
		base_set_ssh
		;;
	sysctl)
		base_set_sysctl
		;;
	add_dir)
		base_add_dir
		;;
	services)
		base_set_services
		;;
	timezone)
		base_set_timezone
		;;
	--help|-h|-help)
		help_info
		;;
	*)
		echo "Usage: $0 {repo|yum|add_user|add_mysql_user|add_www_user|ssh|sysctl|add_dir|services|timezone}"
		exit 1
		;;
esac