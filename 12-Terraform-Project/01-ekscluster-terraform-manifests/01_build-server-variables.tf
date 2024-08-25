# AWS Jenkins EC2 Instance Type
variable "jenkins_instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t2.large"
}

variable "build_server_sg" {
  description = "The name of the security group"
  type        = string
  default     = "Build-Server-SG"
}

variable "ingress_rules" {
  description = "List of ingress rules to apply"
  type        = list(string)
  default = [
    "8080",
    "22",
    "9000",
    "8081",
  ]
}


variable "rules" {
  description = "Map of rule definitions"
  type        = map(list(string))
  default = {
    "Jenkins-8080-SG"   = ["8080", "8080", "tcp", "Allow Jenkins"],
    "Sonarqube-9000-SG" = ["9000", "9000", "tcp", "Allow SonarQube"],
    "Nexus-8081-SG"     = ["8081", "8081", "tcp", "Allow Nexus"],
    "Nexus-8082-SG"     = ["8082", "8082", "tcp", "Allow Nexus SSL"],
    "SSH-22-SG"         = ["22", "22", "tcp", "Allow SSH"]
  }
}