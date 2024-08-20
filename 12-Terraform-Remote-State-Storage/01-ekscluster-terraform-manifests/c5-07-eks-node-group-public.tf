
# resource "aws_route_table" "public" {
#   vpc_id = module.vpc.vpc_id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }

#   tags = {
#     Name = "public-route-table"
#   }
# }

# resource "aws_route_table_association" "public_subnet_assoc" {
#   count          = length(module.vpc.public_subnets)
#   subnet_id      = module.vpc.public_subnets[count.index]
#   route_table_id = aws_route_table.public.id
# }

resource "aws_security_group_rule" "allow_port_31280" {
  type              = "ingress"
  from_port         = 31280
  to_port           = 31280
  protocol          = "tcp"
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]  # or your specific CIDR
}

# Create AWS EKS Node Group - Public
resource "aws_eks_node_group" "eks_ng_public" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${local.name}-eks-ng-public"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = module.vpc.public_subnets
  ami_type        = "AL2_x86_64"
  capacity_type   = "ON_DEMAND"
  disk_size       = 20
  instance_types  = ["t3.medium"]
  remote_access {
    ec2_ssh_key               = "eks-terraform-key"
    source_security_group_ids = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id]
  }
  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }
  update_config {
    max_unavailable = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_registry_readonly,
  ]
  tags = {
    Name = "Public-Node-Group"
  }
}

################################################################



data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "terraform-on-aws-eks-bucket" 
    key    = "dev/eks-cluster/terraform.tfstate" 
    region = "us-east-1"
  }
}

data "aws_eks_cluster" "eks_cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

data "external" "oidc_thumbprint" {
  program = ["bash", "${path.module}/get_thumbprint.sh"]
}

# data "aws_eks_cluster" "cluster" {
#   name = data.terraform_remote_state.eks.outputs.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = data.terraform_remote_state.eks.outputs.cluster_id
# }

# Terraform Kubernetes Provider
provider "kubernetes" {
  host = data.terraform_remote_state.eks.outputs.cluster_endpoint 
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
  token = data.aws_eks_cluster_auth.cluster.token
}

# data "aws_ami" "eks_worker" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["amazon-eks-node-1.30-v*"]
#   }
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
#   owners = ["602401143452"]
# }


# data "aws_ssm_parameter" "eks_ami" {
#   name = "/aws/service/eks/optimized-ami/1.30/amazon-linux-2/recommended/image_id"
# }

# resource "aws_launch_template" "eks_node_group" {
#   name_prefix            = "eks-node-group-launch-template"
#   image_id               = data.aws_ssm_parameter.eks_ami.value
#   instance_type          = "t3.medium"
#   key_name               = "eks-terraform-key"
#   vpc_security_group_ids = [aws_security_group.eks_remote_access.id]

#   block_device_mappings {
#     device_name = "/dev/xvda"
#     ebs {
#       volume_size           = 40
#       volume_type           = "gp2"
#       delete_on_termination = true
#     }
#   }
#   metadata_options {
#     http_endpoint               = "enabled"
#     http_tokens                 = "required"
#     http_put_response_hop_limit = 2
#     instance_metadata_tags      = "enabled"
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
#   tags = {
#     "Name"                                      = "${var.cluster_name}-eks-node-group"
#     "kubernetes.io/cluster/${var.cluster_name}" = "owned"
#   }
# }

# resource "aws_eks_node_group" "eks_ng_public" {
#   cluster_name    = aws_eks_cluster.eks_cluster.name
#   node_group_name = "${local.name}-eks-ng-public"
#   node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
#   subnet_ids      = module.vpc.public_subnets
#   # ami_type        = "CUSTOM"
#   capacity_type   = "ON_DEMAND"
#   launch_template {
#     id      = aws_launch_template.eks_node_group.id
#     version = "$Default"
#   }

#   scaling_config {
#     desired_size = 2
#     min_size     = 1
#     max_size     = 2
#   }

#   update_config {
#     max_unavailable = 1
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.eks_worker_node,
#     aws_iam_role_policy_attachment.eks_cni_policy,
#     aws_iam_role_policy_attachment.ec2_registry_readonly,
#   ]

#   tags = {
#     Name = "Public-Node-Group"
#   }
# }
# ################################


# ################################


# resource "aws_security_group" "eks_remote_access" {
#   name        = "eks-remote-access"
#   description = "Custom security group for EKS remote access"
#   vpc_id      = module.vpc.vpc_id
  
#   ingress {
#     from_port   = 10250
#     to_port     = 10250
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   # Kubernetes API server access for kubelet
#   ingress {
#     from_port   = 10250
#     to_port     = 10250
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 31280
#     to_port     = 31280
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "eks-remote-access"
#   }
# }