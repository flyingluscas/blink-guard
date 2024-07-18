terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

provider "aws" {
  region = var.region
}

module "blink_guard_vpc" {
  source = "./blink-guard-vpc"
  az     = "${var.region}a"
}

module "blink_guard_wireguard" {
  source            = "./blink-guard-wireguard"
  vpc_id            = module.blink_guard_vpc.vpc_id
  public_subnet_id  = module.blink_guard_vpc.public_subnet_ids[0]
  allowed_admins_ip = ["${chomp(data.http.myip.response_body)}/32"]
}
