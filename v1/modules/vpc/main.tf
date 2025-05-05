# VPC 네트워크 생성
resource "google_compute_network" "vpc" {
  # VPC 이름
  name = var.vpc_name

  # GCP 프로젝트 ID
  project = var.project

  # Custom VPC 모드 사용 (서브넷 수동 생성)
  auto_create_subnetworks = false

  # GCP 설명
  description = "Main VPC created via Terraform"
}

# 퍼블릭 서브넷 설정
resource "google_compute_subnetwork" "public_subnet" {
  # 서브넷 이름
  name = "${var.vpc_name}-public-subnet"

  # CIDR 대역
  ip_cidr_range = var.public_subnet_cidr

  # 리전 및 프로젝트 정보
  region  = var.region
  project = var.project

  # 연결할 VPC ID
  network = google_compute_network.vpc.id

  # 서브넷 설명
  description = "Public Subnet for internet-facing resources"
}
