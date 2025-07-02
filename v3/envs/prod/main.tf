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

module "nat" {
  source = "../../modules/nat"

  vpc_id = module.vpc.vpc_id

  public_subnets = {
    "ap-northeast-2a" = module.vpc.public_subnet_ids[0]
    "ap-northeast-2c" = module.vpc.public_subnet_ids[1]
  }

  private_subnets = {
    "ap-northeast-2a" = module.vpc.private_subnet_ids[0]
    "ap-northeast-2c" = module.vpc.private_subnet_ids[1]
  }
}
