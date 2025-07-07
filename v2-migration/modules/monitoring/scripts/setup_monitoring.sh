set -e

# 시스템 업데이트 & Docker 설치


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
mkdir -p /opt/loki

mkdir -p /tmp/loki/index
mkdir -p /tmp/loki/boltdb-cache
mkdir -p /tmp/loki/chunks
mkdir -p /tmp/loki/compactor
mkdir -p /tmp/loki/wal

chown -R 10001:10001 /tmp/loki

# prometheus.yml 직접 생성 (zone 명시)
cat > /etc/prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'spring-be'
    gce_sd_configs:
      - project: "true-alliance-464905-t8"
        zone: "asia-northeast3-a"
        port: 8080
        filter: '(name eq "backend-mig-.*")'
      - project: "true-alliance-464905-t8"
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
      - project: "true-alliance-464905-t8"
        zone: "asia-northeast3-a"
        port: 8000
        filter: '(name eq "ai-mig-.*")'
      - project: "true-alliance-464905-t8"
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

  - job_name: 'node-exporter-be'
    gce_sd_configs:
      - project: "true-alliance-464905-t8"
        zone: "asia-northeast3-a"
        port: 9100
        filter: '(name eq "backend-mig-.*")'
      - project: "true-alliance-464905-t8"
        zone: "asia-northeast3-b"
        port: 9100
        filter: '(name eq "backend-mig-.*")'
    relabel_configs:
      - source_labels: [__meta_gce_private_ip]
        target_label: __address__
        replacement: '\$1:9100'
      - source_labels: [__meta_gce_zone]
        target_label: zone

  - job_name: 'node-exporter-ai'
    gce_sd_configs:
      - project: "true-alliance-464905-t8"
        zone: "asia-northeast3-a"
        port: 9100
        filter: '(name eq "ai-mig-.*")'
      - project: "true-alliance-464905-t8"
        zone: "asia-northeast3-b"
        port: 9100
        filter: '(name eq "ai-mig-.*")'
    relabel_configs:
      - source_labels: [__meta_gce_private_ip]
        target_label: __address__
        replacement: '\$1:9100'
      - source_labels: [__meta_gce_zone]
        target_label: zone
EOF

# Loki config 생성
cat > /opt/loki/loki-config.yaml <<EOF
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9095

ingester:
  wal:
    enabled: true
    dir: /tmp/loki/wal

  lifecycler:
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s

  chunk_idle_period: 5m
  max_chunk_age: 1h
  chunk_target_size: 1048576
  chunk_retain_period: 30s
  max_transfer_retries: 0

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

storage_config:
  boltdb_shipper:
    active_index_directory: /tmp/loki/index
    cache_location:           /tmp/loki/boltdb-cache
    shared_store:            filesystem

  filesystem:
    directory: /tmp/loki/chunks

limits_config:
  enforce_metric_name:        false
  reject_old_samples:         true
  reject_old_samples_max_age: 168h

chunk_store_config:
  max_look_back_period: 0s

table_manager:
  retention_deletes_enabled: false
  retention_period:          0s

compactor:
  working_directory: /tmp/loki/compactor
  shared_store:      filesystem
EOF

# Scouter Server 설치 & 기동
SCOUTER_VER=2.20.0
SCOUTER_DIR=/opt/scouter-server

apt-get install -y openjdk-11-jre

# Scouter 다운르도 및 압축 해제
sudo mkdir -p $SCOUTER_DIR
sudo curl -fsSL https://github.com/scouter-project/scouter/releases/download/v${SCOUTER_VER}/scouter-all-${SCOUTER_VER}.tar.gz -o /tmp/scouter.tar.gz
sudo tar -xzf /tmp/scouter.tar.gz -C $SCOUTER_DIR --strip-components=1
sudo rm /tmp/scouter.tar.gz

# 데이터/로그/설정 디렉토리 생성 및 권한 부여
sudo mkdir -p $SCOUTER_DIR/server/{data,log,conf,logs}
sudo chown -R $(whoami):$(whoami) $SCOUTER_DIR

# 설정 파일
cat > $SCOUTER_DIR/server/conf/scouter.conf <<EOF
scouter.server.data.dir=$SCOUTER_DIR/server/data
scouter.server.log.level=INFO

# UDP 메트릭 수집(heartbeat 등) – 모든 인터페이스에서 수신
scouter.server.udp.listen.ip=0.0.0.0
scouter.server.udp.listen.port=6100

# TCP 오브젝트 전송(List, Object 조회) – 모든 인터페이스에서 수신
scouter.server.tcp.listen.ip=0.0.0.0
scouter.server.tcp.listen.port=6188
EOF

# 기동
cd $SCOUTER_DIR/server
nohup java -Xmx1024m \
  -classpath "./scouter-server-boot.jar:./lib/*:../webapp" \
  scouter.boot.Boot \
  > ./log/scouter-server.log 2>&1 &

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

docker run -d \
  --name loki \
  --restart unless-stopped \
  -p 3100:3100 \
  -v /opt/loki/loki-config.yaml:/etc/loki/loki-config.yaml \
  -v /tmp/loki:/tmp/loki \
  grafana/loki:2.9.4 \
  -config.file=/etc/loki/loki-config.yaml

sleep 10

curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"Prometheus","type":"prometheus","url":"http://localhost:9090","access":"proxy"}' \
  http://admin:admin@localhost:3000/api/datasources 

curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"Loki","type":"loki","url":"http://localhost:3100","access":"proxy"}' \
  http://admin:admin@localhost:3000/api/datasources