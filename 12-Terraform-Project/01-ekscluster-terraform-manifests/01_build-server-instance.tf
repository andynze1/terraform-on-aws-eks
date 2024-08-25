# AWS EC2 Instance Terraform Module
# Bastion Host - EC2 Instance that will be created in VPC Public Subnet
module "jenkins_ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"
  #version = "5.0.0"  
  version = "5.5.0"
  # insert the required variables here
  name          = "${local.name}-Jenkins-Server"
  ami           = data.aws_ami.ubuntu-linux-2404.id
  instance_type = var.jenkins_instance_type
  key_name      = "linux-keypair"
  user_data     = file("${path.module}/app-scripts/install.sh")
  #monitoring             = true
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.jenkins_sg.security_group_id]
  tags                   = { Name = "Jenkins-Server" }
  root_block_device = [{
    volume_size           = 10
    volume_type           = "gp2"
    delete_on_termination = true
  }]
}


resource "aws_key_pair" "key-pair" {
  key_name   = "linux-keypair"
  public_key = tls_private_key.linux-keypair.public_key_openssh
}
resource "tls_private_key" "linux-keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "linux-pem-key" {
  content         = tls_private_key.linux-keypair.private_key_pem
  filename        = "./private-key/linux-keypair.pem"
  file_permission = "0400"
  depends_on      = [tls_private_key.linux-keypair]
}