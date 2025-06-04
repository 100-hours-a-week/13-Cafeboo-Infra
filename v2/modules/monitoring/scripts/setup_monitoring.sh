# 시스템 업데이트 및 도커 설치
apt-get update
apt-get upgrade -y
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce
systemctl start docker
systemctl enable docker

# 디렉토리 생성
mkdir -p /etc/prometheus
mkdir -p /etc/grafana
# prometheus.yml 직접 생성 (zone 명시)
cat > /etc/prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'spring-be'
    gce_sd_configs:
      - project: "elevated-valve-459107-h8"
        zone: "asia-northeast3-a"
        port: 8080
        filter: '(name eq "backend-mig-.*")'
      - project: "elevated-valve-459107-h8"
        zone: "asia-northeast3-b"
        port: 8080
        filter: '(name eq "backend-mig-.*")'
    relabel_configs:
      - source_labels: [__meta_gce_private_ip]
        target_label: __address__
        replacement: '\$1:8080'
      - source_labels: [__meta_gce_zone]
        target_label: zone
    metrics_path: '/actuator/prometheus'
  - job_name: 'fastapi-ai'
    gce_sd_configs:
      - project: "elevated-valve-459107-h8"
        zone: "asia-northeast3-a"
        port: 8000
        filter: '(name eq "ai-mig-.*")'
      - project: "elevated-valve-459107-h8"
        zone: "asia-northeast3-b"
        port: 8000
        filter: '(name eq "ai-mig-.*")'
    relabel_configs:
      - source_labels: [__meta_gce_private_ip]
        target_label: __address__
        replacement: '\$1:8000'
      - source_labels: [__meta_gce_zone]
        target_label: zone
    metrics_path: '/metrics'
EOF


# Prometheus, Grafana 컨테이너 실행
docker run -d \
  --name prometheus \
  --restart unless-stopped \
  -p 9090:9090 \
  -v /etc/prometheus:/etc/prometheus \
  prom/prometheus \
  --config.file=/etc/prometheus/prometheus.yml

docker run -d \
  --name grafana \
  --restart unless-stopped \
  -p 3000:3000 \
  grafana/grafana

curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"Prometheus","type":"prometheus","url":"http://localhost:9090","access":"proxy"}' \
  http://admin:admin@localhost:3000/api/datasources 
