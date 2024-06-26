#!/bin/bash

## Source Common Functions
curl -s "https://gitlab.com/thecloudcareers/opensource/-/raw/master/centos7/common-functions.sh?ref_type=heads" >/tmp/common-functions.sh
source /tmp/common-functions.sh

## Checking Root User or not.
CheckRoot

## Checking SELINUX Enabled or not.
CheckSELinux

## Checking Firewall on the Server.
CheckFirewall

ELV=$(rpm -qi basesystem | grep Release  | awk -F . '{print $NF}')
export OSVENDOR=$(rpm -qi basesystem  | grep Vendor | awk -F : '{print $NF}' | sed -e 's/^ //')

which java &>/dev/null
if [ $? -ne 0 ]; then 
	yum install java wget -y &>/dev/null
	if [ $? -eq 0 ]; then 
		success "JAVA Installed Successfully"
	else
		error "JAVA Installation Failure!"
		exit 1
	fi
else
	success "Java already Installed"
fi

## Downloading Nexus
yum install https://kojipkgs.fedoraproject.org/packages/python-html2text/2016.9.19/1.el7/noarch/python2-html2text-2016.9.19-1.el7.noarch.rpm -y &>/dev/null

if [ "$ELV" == "el7" ]; then
    URL=$(curl -L -s https://help.sonatype.com/display/NXRM3/Download+Archives+-+Repository+Manager+3 | html2text | grep tar.gz | sed -e 's/>//g' -e 's/<//g' | grep ^http|head -1 | awk '{print $1}')

elif [ "$ELV" == "el8" ]; then
    yum install java-17-openjdk unzip -y
    URL="https://download.sonatype.com/nexus/3/nexus-3.64.0-04-unix.tar.gz"
fi

NEXUSFILE=$(echo $URL | awk -F '/' '{print $NF}')
NEXUSDIR=$(echo $NEXUSFILE|sed -e 's/-unix.tar.gz//')
NEXUSFILE="/opt/$NEXUSFILE"
wget $URL -O $NEXUSFILE &>/dev/null
if [ $? -eq 0  ]; then 
	success "NEXUS Downloaded Successfully"
else
	error "NEXUS Downloading Failure"
	exit 1
fi

## Adding Nexus User
id nexus &>/dev/null
if [ $? -ne  0 ]; then 
	useradd nexus
	if [ $? -eq 0 ]; then 
		success "Added NEXUS User Successfully"
	else
		error "Adding NEXUS User Failure"
		exit 1
	fi
fi

## Extracting Nexus
if [ ! -f "/home/nexus/$NEXUSDIR" ]; then 
su nexus <<EOF
cd /home/nexus
tar xf $NEXUSFILE
EOF
fi
success "Extracted NEXUS Successfully"
## Setting Nexus starup
unlink /etc/init.d/nexus &>/dev/null
ln -s /home/nexus/$NEXUSDIR/bin/nexus /etc/init.d/nexus 
echo "run_as_user=nexus" >/home/nexus/$NEXUSDIR/bin/nexus.rc
success "Updating System Configuration"
systemctl enable nexus &>/dev/null
systemctl start nexus
if [ $? -eq 0 ]; then 
	success "Starting Nexus Service"
else
	error "Starting Nexus Failed"
	exit 1
fi