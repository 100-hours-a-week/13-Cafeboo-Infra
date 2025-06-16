#!/bin/bash
apt-get update
apt-get install -y openvpn easy-rsa
echo "OpenVPN installed" > /var/log/openvpn-setup.log
