# Jenkins Server IP
output "build_server_id" {
  description = "The Build Server Public IP address."
  value       = module.jenkins_ec2.public_ip
}

# output "eks_admins_iam_role" {
#   description = "EKS Admin Role"
#   value = module.eks_admins_iam_role.iam_role_arn
# }