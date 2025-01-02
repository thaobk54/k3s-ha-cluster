module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "k3s-vpc"
  cidr = var.vpc_cidr

  azs             = var.vpc_available_zones
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}