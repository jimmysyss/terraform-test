module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.name}-${var.env}-vpc"
  azs  = var.vpc_azs
  cidr = var.vpc_cidr

  # public_subnets   = var.vpc_public_subnets
  # private_subnets  = var.vpc_private_subnets
  # database_subnets = var.vpc_database_subnets

  public_subnets   = slice(var.vpc_public_subnets, 0, length(var.vpc_azs))
  private_subnets  = slice(var.vpc_private_subnets, 0, length(var.vpc_azs))
  database_subnets = slice(var.vpc_database_subnets, 0, length(var.vpc_azs))

  enable_nat_gateway     = var.vpc_enable_nat_gateway
  single_nat_gateway     = var.vpc_single_nat_gateway
  one_nat_gateway_per_az = var.vpc_one_nat_gateway_per_az

  create_database_subnet_group       = true
  create_database_subnet_route_table = true
}

