#!/bin/bash 

function checkVersion() {
	if type lsb_release >/dev/null 2>&1; then
    	OS=$(lsb_release -sr)
	elif [ -f /etc/redhat-release ]; then
	    OS=$(cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f1)
	else
	    OS=$(uname -r)
	fi
}

function disable() {
	sudo systemctl stop firewalld
	sudo systemctl disable firewalld
	sudo systemctl mask --now firewalld
	sed -i '' -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
}

function config() {
	sed -i '' -e "s/#PermitRootLogin/PermitRootLogin/g" /etc/ssh/sshd_config
	service sshd restart
	chmod +x /etc/re.local

	if [[ $OS == "6" ]]; then
		rm -rf /etc/yum.repos.d/CentOS*
		touch /etc/yum.repos.d/CISP.repo	
cat <<EOF > /etc/yum.repos.d/CISP.repo
[CISP]
name=CISP Repository
baseurl=http://mirror.cisp.com/CentOS/6/os/x86_64/
enabled=1
gpgcheck=1
gpgkey=http://mirror.cisp.com/CentOS/6/os/x86_64/RPM-GPG-KEY-CentOS-6
EOF
	fi
}

function ubuntu() {
	installArr=("sudo apt install tcpdump -y"1
				"sudo apt install telnet -y"
				"sudo apt update" 
				"sudo apt upgrade -y")

	for i in "${installArr[@]}"; do $i; done
}

function centos() {
	cat /etc/redhat-release
	installArr=("yum install tcpdump -y"
				"yum install telnet -y"
				"yum update" 
				"sudo apt upgrade -y")

	for i in "${installArr[@]}"; do $i; done
}

function main() {
	if [[ $OS == "6" ]]; then
		disable
		config
		centos
	else
		disable
		config 
		ubuntu
	fi
}

main


