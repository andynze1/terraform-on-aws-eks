# AWS Availability Zones Datasource
data "aws_availability_zones" "available" {
}
data "aws_caller_identity" "current" {}

# Create VPC Terraform Module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  #version = "4.0.1"
  version = "5.4.0"

  # VPC Basic Details
  name            = local.eks_cluster_name
  cidr            = var.vpc_cidr_block
  azs             = data.aws_availability_zones.available.names
  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets
  # public_subnet_tags   = { "kubernetes.io/role/elb" = "1" }
  # private_subnet_tags  = { "kubernetes.io/role/internal-elb" = "1"}

  # Database Subnets
  database_subnets                   = var.vpc_database_subnets
  create_database_subnet_group       = var.vpc_create_database_subnet_group
  create_database_subnet_route_table = var.vpc_create_database_subnet_route_table
  # create_database_internet_gateway_route = true
  # create_database_nat_gateway_route = true

  # NAT Gateways - Outbound Communication
  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway = var.vpc_single_nat_gateway

  # VPC DNS Parameters
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags     = local.common_tags
  vpc_tags = local.common_tags

  # Additional Tags to Subnets
  public_subnet_tags = {
    Type                                              = "Public Subnets"
    "kubernetes.io/role/elb"                          = 1
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
  }
  private_subnet_tags = {
    Type                                              = "private-subnets"
    "kubernetes.io/role/internal-elb"                 = 1
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
  }

  database_subnet_tags = {
    Type = "database-subnets"
  }
  # Instances launched into the Public subnet should be assigned a public IP address.
  map_public_ip_on_launch = true

}

################################################################

# resource "aws_route_table" "public" {
#   vpc_id = module.vpc.vpc_id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = module.vpc.internet_gateway_id
#   }

#   tags = local.common_tags
# }

# resource "aws_route_table_association" "public_a" {
#   subnet_id      = module.vpc.public_subnets[0]
#   route_table_id = aws_route_table.public.id
# }

# resource "aws_route_table_association" "public_b" {
#   subnet_id      = module.vpc.public_subnets[1]
#   route_table_id = aws_route_table.public.id
# }

# resource "aws_route_table" "private" {
#   vpc_id = module.vpc.vpc_id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = module.vpc.nat_gateway_id
#   }

#   tags = local.common_tags
# }

# resource "aws_route_table_association" "private_a" {
#   subnet_id      = module.vpc.private_subnets[0]
#   route_table_id = aws_route_table.private.id
# }

# resource "aws_route_table_association" "private_b" {
#   subnet_id      = module.vpc.private_subnets[1]
#   route_table_id = aws_route_table.private.id
# }
