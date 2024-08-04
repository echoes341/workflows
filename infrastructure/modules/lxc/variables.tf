variable "name" {
  description = "Name of the runner"
  type        = string
}

variable "ip" {
  description = "IP address of the runner"
  type        = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "tags" {
  type     = string
  nullable = true
  default  = null
}

variable "memory" {
  type    = number
  default = 512
}

variable "ostemplate" {
  type    = string
  default = "local:vztmpl/ubuntu-23.10-standard_23.10-1_amd64.tar.zst"
}
