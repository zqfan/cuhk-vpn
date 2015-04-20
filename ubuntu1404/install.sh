#!/bin/bash

if [[ "$UID" != 0 ]]; then
    echo "Root privileges required!"
    echo "For normal user, please use sudo."
    exit 1
fi

CheckInstalled() {
    if [[ $# != 1 ]]; then
        return 1
    fi
    dpkg -s $1 > /dev/null 2>&1
    return $?
}

echo "Checking whether required packaged are installed..."
PKG_LIST=('racoon' 'ipsec-tools' 'xl2tpd' 'ppp' 'isc-dhcp-client')
PKG_NEED=()
for pkg in ${PKG_LIST[@]}; do
    CheckInstalled $pkg
    if [[ $? != 0 ]]; then
        PKG_NEED+=($pkg)
    fi
done
if [[ ${#PKG_NEED[@]} > 0 ]]; then
    echo "The following packages are missing:"
    for pkg in ${PKG_NEED[@]}; do
        echo " - $pkg"
    done
    echo "Installing needed package..."
    apt-get install ${PKG_NEED[@]}
    if [[ $? != 0 ]]; then
        echo "Installation failed! Please install them manually."
        echo "For details, please refer to the manual."
        exit 1
    fi
fi
echo "Done."
echo ""

Backup() {
    local f=$1.bak.$(date +%Y%m%d%H%M)
    if [[ $# != 1 ]]; then
        return 1
    fi
    cp $1 $f
}

echo "Backuping the original config files..."
Backup /etc/racoon/racoon.conf
Backup /etc/racoon/psk.txt
Backup /etc/xl2tpd/xl2tpd.conf
Backup /etc/ppp/options
Backup /etc/ppp/options.xl2tpd
Backup /etc/ppp/pap-secrets
echo "Copying the config files..."
cd $(dirname $0)
cd conf
cp racoon.conf /etc/racoon/racoon.conf
cp xl2tpd.conf /etc/xl2tpd/xl2tpd.conf
cp options /etc/ppp/options
cp options.xl2tpd /etc/ppp/options.xl2tpd
echo "Done."
echo ""
echo "Please enter your CUSIS ID and password."
echo "Exapmle: "
echo "CUSIS ID: s1155012345"
echo "Password: the_password"
echo "Repeat the password: the_password"
echo "Note that for secure reason, the password will not be shown."
echo ""
echo -n "ID: "
read ID
while [[ 1 ]]; do
    echo -n "Password: "
    read -s PW1
    echo ""
    echo -n "Repeat the password: "
    read -s PW2
    echo ""
    if [[ $PW1 != $PW2 ]]; then
        echo "Password not match! Try again."
    else
        break
    fi
done
cat psk.txt >> /etc/racoon/psk.txt
echo "$ID vpn.cuhk.edu.hk \"$PW1\"" >> /etc/ppp/pap-secrets
echo "name $ID" >> /etc/ppp/options.xl2tpd
echo "Done."
echo ""
ChPerm() {
    declare permission
    if [[ $# == 1 ]]; then
        permission=644
    elif [[ $# == 2 ]]; then
        permission=$2
    else
        return 1
    fi
    chown root $1
    chmod $permission $1
}

echo "Changing file owner and permission..."
ChPerm /etc/racoon/racoon.conf
ChPerm /etc/racoon/psk.txt 600
ChPerm /etc/xl2tpd/xl2tpd.conf
ChPerm /etc/ppp/pap-secrets 600
ChPerm /etc/ppp/options
ChPerm /etc/ppp/options.xl2tpd
echo "Done."
echo ""
echo "You may now use vpn_connect.sh to connect to the VPN."
