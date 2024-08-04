variable "ip" {
  type = string
}

variable "password" {
  default = "k3s-node"
}

variable "name" {}

module "lxc" {
  source   = "../modules/lxc"
  ip       = var.ip
  password = var.password
  name     = var.name
  memory   = 4096
}

resource "null_resource" "install" {
  connection {
    type = "ssh"
    host = var.ip
    user = "root"
  }
  depends_on = [module.lxc]

  provisioner "file" {
    source      = "./github-runner/scripts/docker.sh"
    destination = "/tmp/docker.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get install -y curl ca-certificates",
      "chmod +x /tmp/docker.sh",
      "/tmp/docker.sh",
      "curl -sfL https://get.k3s.io | sh -s - --docker"
    ]
  }
}
