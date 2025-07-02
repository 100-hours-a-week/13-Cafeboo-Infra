terraform {
  backend "s3" {
    bucket         = "cafeboo-terraform-v3-backend-bucket"
    key            = "prod/vpc/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-v3-lock-table"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr             = "10.20.0.0/16"
  public_subnet_cidrs  = ["10.20.0.0/24", "10.20.1.0/24"]
  private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]
  availability_zones   = ["ap-northeast-2a", "ap-northeast-2c"]
}

