#!/bin/bash

apt-get update
apt-get install -y curl docker.io unzip

PROMTAIL_VERSION="2.9.4"
curl -LO "https://github.com/grafana/loki/releases/download/v2.9.4/promtail-linux-amd64.zip"
unzip promtail-linux-amd64.zip
chmod +x promtail-linux-amd64
mv promtail-linux-amd64 /usr/local/bin/promtail

mkdir -p /etc/promtail

# Promtail Config
cat <<EOF > /etc/promtail/config.yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0
  log_level: info

positions:
  filename: /etc/promtail/positions.yaml

clients:
  - url: "${loki_url}"

scrape_configs:
  - job_name: docker-containers
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 5s

    pipeline_stages:
      - docker: {}

      - labels:
          job: ${job_label}
          instance: ${instance}

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

# Run Promtail
nohup promtail -config.file=/etc/promtail/config.yaml > /var/log/promtail.log 2>&1 &
