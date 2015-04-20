This script is for connecting to the CUHK VPN on Ubuntu 14.04.

Before using the scripts, please install the following packages:

racoon
ipsec-tools
xl2tpd
ppp
isc-dhcp-client

For the first time connecting to VPN, please run:
sudo ./install.sh

The shell script will help you to set the required config files, and also the CUSIS ID and password.
For each computer, you need to run the script once only.

To connect to the VPN, please run:
sudo ./vpn_connect.sh

To disconnect from the VPN, please run:
sudo ./vpn_disconnect.sh
