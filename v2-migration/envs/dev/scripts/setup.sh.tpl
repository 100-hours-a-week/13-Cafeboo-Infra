#!/bin/bash

set -e

echo "🔄 시스템 패키지 업데이트 중..."
sudo apt-get update -y

############################################
# MySQL 설치 및 설정
############################################
gsutil cp gs://v2-db/dump.sql ~/dump.sql

sudo apt install -y mysql-server

# MySQL root 계정으로 명령 실행
sudo mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS cafeboo CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

CREATE USER 'cafeboo'@'%' IDENTIFIED BY "${DB_PASSWORD}";
ALTER USER 'cafeboo'@'%' IDENTIFIED WITH mysql_native_password BY "${DB_PASSWORD}";
GRANT ALL PRIVILEGES ON *.* TO 'cafeboo'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

echo "💾 dump.sql을 데이터베이스에 복원 중..."
sudo mysql -u cafeboo -p"${DB_PASSWORD}" cafeboo < ~/dump.sql

echo "✅ MySQL 설정 및 데이터 복원 완료!"

############################################
# Docker 설치
############################################
echo "🐳 Docker 설치 중..."

sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Docker GPG 키 추가
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Docker apt 리포지토리 등록
echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 패키지 리스트 업데이트
sudo apt-get update

# Docker 패키지 설치
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 도커 서비스 활성화
sudo systemctl enable docker
sudo systemctl start docker

# Docker 인증 설정 추가
sudo gcloud auth configure-docker asia-northeast3-docker.pkg.dev --quiet


echo "✅ Docker 설치 및 실행 완료!"

############################################
# Promtail 설치 및 설정
############################################
echo "📦 Promtail 설치 중..."
sudo apt-get install -y unzip

curl -LO "https://github.com/grafana/loki/releases/download/v2.9.4/promtail-linux-amd64.zip"
unzip promtail-linux-amd64.zip
chmod +x promtail-linux-amd64
sudo mv promtail-linux-amd64 /usr/local/bin/promtail

sudo mkdir -p /etc/promtail

# Promtail 설정 파일 생성
cat <<EOF | sudo tee /etc/promtail/config.yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0
  log_level: info

positions:
  filename: /etc/promtail/positions.yaml

clients:
  - url: http://10.30.2.19:3100/loki/api/v1/push

scrape_configs:
  - job_name: docker-containers
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 5s

    pipeline_stages:
      - docker: {}

      - labels:
          job: backend
          instance: dev-vm

    relabel_configs:
      - source_labels: [__meta_docker_container_name]
        target_label: container
        regex: /(.+)
        replacement: \$1
        action: replace

      - source_labels: [__meta_docker_container_id]
        target_label: __path__
        regex: (.+)
        replacement: /var/lib/docker/containers/\$1/*.log
        action: replace
EOF

# Promtail 실행
echo "🚀 Promtail 시작 중..."
nohup promtail -config.file=/etc/promtail/config.yaml > ~/promtail.log 2>&1 &

echo "✅ 모든 설치 및 설정이 완료되었습니다!"