#!/bin/bash
exec >> /var/log/startup.log 2>&1
set -eux

echo "[CPU INIT] Starting setup..."

# 홈 디렉토리 안에 바로 디렉토리 생성
mkdir -p /home/cafeboo/{front,back,ai,db,nginx}
chown -R cafeboo:cafeboo /home/cafeboo

echo "[✓] 디렉토리 생성 완료"

# 패키지 설치
DEBIAN_FRONTEND=noninteractive apt update -yq && apt upgrade -yq
apt install -y curl git unzip gnupg lsb-release nginx mysql-server openjdk-21-jdk python3 python3-pip

echo "[✓] Java & NGINX & MySQL & Python 설치 완료"

# MySQL 초기 설정
service mysql start
mysql -u root <<EOF
CREATE DATABASE cafeboo DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'cafeboo'@'localhost' IDENTIFIED BY 'cafeboo123';
GRANT ALL PRIVILEGES ON cafeboo.* TO 'cafeboo'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "[✓] MySQL 초기화 완료"

# NGINX 설정
cat <<EOF > /etc/nginx/sites-available/cafeboo
server {
    listen 80;

    location / {
        root /home/cafeboo/front;
        index index.html;
        try_files \$uri /index.html;
    }

    location /api/ {
        proxy_pass http://localhost:8080/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

ln -sf /etc/nginx/sites-available/cafeboo /etc/nginx/sites-enabled/cafeboo
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx

echo "[✓] NGINX 설정 완료"