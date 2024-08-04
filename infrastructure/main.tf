terraform {
  backend "pg" {}

  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://pxm.ross.in:8006/api2/json"
}

module "github-runner" {
  source                   = "./github-runner"
  github_token             = var.github_token
  github_runner_repository = "https://github.com/echoes341/workflows"
  ip                       = "192.168.1.109"
}
