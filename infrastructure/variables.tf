variable "github_token" {
  description = "Github token to connect runner to the repository"
  type        = string
  sensitive   = false
}

variable "kubernetes_config_path" {
  description = "Path to the kubeconfig file"
  type        = string
  sensitive   = false
  default     = "~/.kube/config"
}
