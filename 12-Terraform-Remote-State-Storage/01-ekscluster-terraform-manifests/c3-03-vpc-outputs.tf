# VPC Output Values

# VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# VPC CIDR blocks
output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# VPC Private Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

# VPC Public Subnets
output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

# VPC NAT gateway Public IP
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

# VPC AZs
output "azs" {
  description = "A list of availability zones spefified as argument to this module"
  value       = module.vpc.azs
}

output "vpc_owner_id" {
  description = "The AWS Account ID of the VPC owner"
  value       = data.aws_caller_identity.current.account_id
}

# output "eks_remote_access_security_group_id" {
#   description = "Security group used for EKS remote access"
#   value       = aws_security_group.eks_remote_access.id
# }

output "eks_cluster_security_group_id" {
  description = "Security group associated with the EKS cluster's control plane"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

