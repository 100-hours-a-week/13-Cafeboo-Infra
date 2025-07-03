#!/bin/bash

set -e
echo "[INFO] Redis 설치 시작"

apt-get update
apt-get install -y redis-server

echo "[INFO] redis.conf 설정 변경 중"
sed -i "s/^bind .*/bind 0.0.0.0/" /etc/redis/redis.conf || echo "bind 0.0.0.0" >> /etc/redis/redis.conf

if grep -q "^# requirepass" /etc/redis/redis.conf; then
    sed -i "s/^# requirepass.*/requirepass ${redis_password}/" /etc/redis/redis.conf
elif grep -q "^requirepass" /etc/redis/redis.conf; then
    sed -i "s/^requirepass.*/requirepass ${redis_password}/" /etc/redis/redis.conf
else
    echo "requirepass ${redis_password}" >> /etc/redis/redis.conf
fi

sed -i "s/^protected-mode .*/protected-mode no/" /etc/redis/redis.conf || echo "protected-mode no" >> /etc/redis/redis.conf

systemctl enable redis-server
systemctl restart redis-server

echo "[INFO] Redis 설치 및 설정 완료"