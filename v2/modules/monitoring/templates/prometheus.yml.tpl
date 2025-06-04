global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'spring-be'
    gce_sd_configs:
      - project: ${project_id}
        zone: ${zone}
        filter: 'name=~"${be_service_name}" AND labels.managed-by-mig="true"'
    relabel_configs:
      - source_labels: [__meta_gce_private_ip]
        target_label: __address__
        replacement: '$1:8080'
    metrics_path: '/actuator/prometheus'
    
  - job_name: 'fastapi-ai'
    gce_sd_configs:
      - project: ${project_id}
        zone: ${zone}
        filter: 'name=~"${ai_service_name}" AND labels.managed-by-mig="true"'
    relabel_configs:
      - source_labels: [__meta_gce_private_ip]
        target_label: __address__
        replacement: '$1:8000'
    metrics_path: '/metrics' 