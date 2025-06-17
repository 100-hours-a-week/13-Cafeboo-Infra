#!/bin/bash
apt-get update

# OpenVPN Access Server 설치
wget https://openvpn.net/downloads/openvpn-as-latest-ubuntu22.amd_64.deb
dpkg -i openvpn-as-*

# openvpn 사용자 비밀번호 설정 (예: "cafeboo123"로 설정)
echo "openvpn:cafeboo123" | chpasswd
