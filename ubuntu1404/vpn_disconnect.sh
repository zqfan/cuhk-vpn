#!/bin/bash
if [[ "$UID" != 0 ]]; then
	echo "Root privileges required!"
	echo "For normal user, please use sudo."
	exit 1
fi
echo "Getting original device and gateway..."
GW=$(awk -F# '{print $1}' /tmp/vpn_dev_gw)
DEV=$(awk -F# '{print $2}' /tmp/vpn_dev_gw)
echo "Device: $DEV"
echo "Gateway: $GW"
echo ""
echo "Disconnecting VPN..."
echo "d" > /var/run/xl2tpd/l2tp-control
echo "Done."
echo ""
echo "Restoring default route..."
ip route del default
ip route add default via $GW dev $DEV
echo "Done."
echo "The connection should be disconnected."
echo "You can check that by going to http://checkip.org and check if your IP has been restored."
