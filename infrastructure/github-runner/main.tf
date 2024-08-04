module "lxc" {
  source   = "../modules/lxc"
  ip       = var.ip
  password = "github-runner"
  name     = "github-runner"
}

resource "null_resource" "install" {
  connection {
    type = "ssh"
    host = var.ip
    user = "root"
  }
  depends_on = [module.lxc]

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
