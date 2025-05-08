# GCP VM 인스턴스 생성
resource "google_compute_instance" "vm" {
  # VM 이름
  name = var.name

  # GCP 프로젝트, 리전, 존 설정
  project = var.project
  zone    = var.zone

  # 머신 타입
  machine_type = var.machine_type

  # OS 이미지 설정
  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  # 네트워크 인터페이스
  network_interface {
    # 연결할 서브넷
    subnetwork = var.subnet_self_link

    # 외부 NAT IP 연결
    access_config {
      nat_ip = var.external_ip
    }
  }
  # 메타데이터 (scripts, ssh-keys 등)
  metadata = var.metadata

  # 방화벽 제어용 네트워크 태그
  tags = var.tags

  # VM 라벨 (역할/환경 구분용)
  labels = var.labels

  # GPU 설정(선택적)
  dynamic "guest_accelerator" {
    for_each = var.gpu_enabled ? [1] : []
    content {
      # GPU 타입
      type = var.gpu_type

      # GPU 수량
      count = var.gpu_count
    }
  }
}
