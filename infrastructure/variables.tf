variable "github_token" {
  description = "Github token to connect runner to the repository"
  type        = string
  sensitive   = false
}

variable "scanservjs_password" {
  type      = string
  sensitive = true
}
