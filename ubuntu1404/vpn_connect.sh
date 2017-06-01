#!/bin/bash
if [[ "$UID" != 0 ]]; then
	echo "Root privileges required!"
	echo "For normal user, please use sudo."
	exit 1
fi

echo -e "\n##################"
echo "# disconnecting..."
echo -e "##################\n"
. vpn_disconnect.sh
sleep 3

echo -e "\n###############"
echo "# connecting..."
echo -e "###############\n"
echo "Getting default device and gateway..."
TMP=$(ip route | sed -n -E "s/^default.*via ([0-9.]+).*dev ([[:alnum:]]+).*$/\1#\2/p")
echo $TMP > /tmp/vpn_dev_gw
#GW=$(echo $TMP | awk -F# '{print $1}')
GW=192.168.1.1
#DEV=$(echo $TMP | awk -F# '{print $2}')
DEV=wlan0
echo "Device: $DEV"
echo "Gateway: $GW"
echo ""
echo "Adding CUHK VPN Servers routes to $DEV..."
ip route add 137.189.192.200 via $GW dev $DEV
ip route add 137.189.192.201 via $GW dev $DEV
ip route add 137.189.192.202 via $GW dev $DEV
ip route add 137.189.192.203 via $GW dev $DEV
ip route add 137.189.192.204 via $GW dev $DEV
echo "Done."
echo ""
echo "Getting local IP..."
IP=$(ip addr show dev $DEV | sed -nE "s/^.*inet ([0-9.]+).*$/\1/p")
echo "IP: $IP"
echo "Flushing and writing SPD..."
echo -e flush\; | setkey -c
echo -e spdflush\; | setkey -c
echo -e spdadd $IP/32\[1701\] 0.0.0.0\/0\[0\] any \-P out ipsec esp\/transport\/\/require\; | setkey -c
echo "Done."
echo ""
sleep 2
echo "Restarting racoon..."
/etc/init.d/racoon restart
sleep 2
echo "Done."
echo ""
echo "Restarting xl2tpd..."
/etc/init.d/xl2tpd restart
sleep 2
echo "Done."
echo ""
echo "Connecting to the VPN..."
echo "c connect" > /var/run/xl2tpd/l2tp-control
sleep 5
ip addr show dev ppp0 > /dev/null
if [[ $? != 0 ]]; then
	echo "Device ppp0 is not found. Connection failed."
	exit 1
fi
echo "Device ppp0 found."
echo ""
echo "Adding default route to ppp0..."
sleep 2
ip route del default
ip route add default dev ppp0
echo "Done."
echo ""
echo "Adding google dns services..."
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "Done."
echo ""
echo "The connection should be established now."
echo "You can check that by going to http://checkip.org and check if your IP begins with 137.189."
