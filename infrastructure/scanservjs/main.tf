variable "ip" {
  description = "IP address of the lxc"
  type        = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "name" {
  description = "Name of the lxc"
  type        = string
}

module "lxc" {
  source   = "../modules/lxc"
  ip       = var.ip
  password = var.password
  name     = var.name
}

resource "null_resource" "install" {
  connection {
    type = "ssh"
    host = var.ip
    user = "root"
  }
  depends_on = [module.lxc]

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get install -y curl ca-certificates",
      "curl -s https://raw.githubusercontent.com/sbs20/scanservjs/master/bootstrap.sh | bash -s -- -v latest",
      "apt-get install avahi-daemon -y",
      "setcap CAP_NET_BIND_SERVICE=+eip /usr/bin/node"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/config.local.js"
    destination = "/etc/scanservjs/config.local.js"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl restart scanservjs.service"
    ]
  }
}
