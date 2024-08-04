terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc3"
    }

    dns = {
      source  = "hashicorp/dns"
      version = "3.4.1"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://pxm.ross.in:8006/api2/json"
}

provider "dns" {
  update {
    server = "192.168.1.105"
  }
}
