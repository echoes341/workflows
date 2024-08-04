variable "ip" {
  type = string
}

variable "password" {
  default = "k3s-node"
}

variable "name" {}

resource "proxmox_vm_qemu" "k3s-vm" {
  name        = var.name
  target_node = "proxmox"
  bios        = "ovmf"
  onboot      = true
  memory      = 4096
  cores       = 4
  boot        = "order=ide2;scsi0"
  os_type     = "centos"
  agent       = 1

  network {
    bridge    = "vmbr0"
    firewall  = false
    link_down = false
    model     = "virtio"
  }

  ipconfig0 = "gw=192.168.1.254,ip=${var.ip}/24"

  disks {
    ide {
      ide2 {
        cdrom {
          iso = "Rocky-9-latest-x86_64-boot.iso"
        }
      }
    }
    scsi {
      scsi0 {
        cache      = "none"
        emulatessd = true
        size       = "20G"
        storage    = "local-lvm"
      }
    }
  }
}
