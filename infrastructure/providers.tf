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

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.14.0"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://pxm.ross.in:8006/api2/json"
}

provider "dns" {
  update {
    server = var.ip_dns_nameserver
  }
}

provider "kubernetes" {
  config_path = var.kubernetes_config_path
}

provider "helm" {
  kubernetes {
    config_path = var.kubernetes_config_path
  }
}
