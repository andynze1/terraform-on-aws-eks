variable "namespace_monitoring" {
  description = "The namespace for monitoring tools like Prometheus and Grafana."
  type        = string
  default     = "monitoring"
}

variable "namespace_argocd" {
  description = "The namespace for Argo CD."
  type        = string
  default     = "argocd"
}

variable "argo_cd_version" {
  description = "The version of the Argo CD Helm chart."
  type        = string
  default     = "5.24.1"
}

variable "grafana_version" {
  description = "The version of the Grafana Helm chart."
  type        = string
  default     = "8.4.4"
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana."
  type        = string
  default     = "securepassword"
}

variable "vpc_owner_id" {
  description = "The AWS Account ID of the VPC owner"
  type        = string
  default     = "461086874723"
}