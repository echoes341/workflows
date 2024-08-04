terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

resource "proxmox_lxc" "github_runner" {
  target_node  = "proxmox"
  hostname     = var.name
  password     = "github-runner"
  ostemplate   = "local:vztmpl/ubuntu-23.10-standard_23.10-1_amd64.tar.zst"
  unprivileged = true
  onboot       = true
  start        = true
  memory       = 1024
  tags         = "runners"

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

  connection {
    type     = "ssh"
    host     = var.ip
    user     = "root"
    password = "github-runner"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/docker.sh"
    destination = "/tmp/docker.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_runner.sh"
    destination = "/tmp/install_runner.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/docker.sh /tmp/install_runner.sh",
      "/tmp/docker.sh",
      "useradd -m -G docker -s /bin/bash runner",
      "sudo -u runner /tmp/install_runner.sh",
      "sudo -u runner /home/runner/.runner/config.sh --url ${var.github_runner_repository} --token ${var.github_token} --unattended --name ${var.name}",
      "cd /home/runner/.runner && ./svc.sh install runner && ./svc.sh start"
    ]
  }
}
