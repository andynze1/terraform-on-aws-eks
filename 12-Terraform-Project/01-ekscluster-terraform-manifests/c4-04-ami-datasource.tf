# Get latest AMI ID for Amazon Linux2 OS
data "aws_ami" "ubuntu-linux-2404" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu) account ID #owners = [ "amazon" ]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
# data "aws_caller_identity" "current" {}
