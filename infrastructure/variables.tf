variable "github_token" {
  description = "Github token to connect runner to the repository"
  type        = string
  sensitive   = true
}

variable "kubernetes_config_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

# IPs
variable "ip_pg" {}
variable "ip_dns_nameserver" {}
variable "ip_github_runner" {}
variable "ip_k3s_1" {}
