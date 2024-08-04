terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
    dns = {
      source = "hashicorp/dns"
    }
  }
}

resource "proxmox_lxc" "lxc" {
  target_node  = "proxmox"
  hostname     = var.name
  password     = var.password
  ostemplate   = var.ostemplate
  unprivileged = true
  onboot       = true
  start        = true
  memory       = var.memory
  tags         = var.tags

  ssh_public_keys = <<-EOT
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZS5DCA1uPMpvWfjYZQRqW/ZxDOKVzIokAzRMtY0TGi gianpaolo@gethank.com
  EOT

  rootfs {
    size    = "8G"
    storage = "local-lvm"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "${var.ip}/24"
    gw     = "192.168.1.254"
  }
}

resource "dns_a_record_set" "dns" {
  zone = "ross.in."
  name = var.name

  addresses = ["${var.ip}"]
}

