variable "name" {
  description = "Name of the runner"
  type        = string
  default     = "github-runner"
}

variable "github_token" {
  description = "Github token to connect runner to the repository"
  type        = string
  sensitive   = false
}

variable "github_runner_repository" {
  description = "Github repository to connect runner to"
  type        = string
}

variable "ip" {
  description = "IP address of the runner"
  type        = string
}

output "ip" {
  value = var.ip
}
