#!/bin/bash

set -e

echo "🔄 시스템 패키지 업데이트 중..."
sudo apt-get update -y

############################################
# Redis 설치 및 실행
############################################
echo "📦 Redis 설치 중..."
sudo apt-get install -y redis-server

echo "🛠️ Redis 설정 변경 (background 실행)..."
sudo sed -i 's/^supervised no/supervised systemd/' /etc/redis/redis.conf

echo "🚀 Redis 서비스 시작..."
sudo systemctl enable redis-server
sudo systemctl restart redis-server

echo "✅ Redis 설치 및 실행 완료!"

############################################
# MySQL 설치 및 설정
############################################

