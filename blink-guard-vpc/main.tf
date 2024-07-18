module "vpc" {
  source                  = "terraform-aws-modules/vpc/aws"
  name                    = var.name
  cidr                    = var.cidr
  azs                     = [var.az]
  public_subnets          = [var.public_subnet_cidr]
  map_public_ip_on_launch = true
  create_igw              = true
}
