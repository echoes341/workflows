resource "proxmox_vm_qemu" "k3s-node-1" {
  automatic_reboot       = true
  balloon                = 0
  bios                   = "seabios"
  boot                   = "order=scsi0;net0"
  cores                  = 6
  cpu                    = "host"
  define_connection_info = false
  full_clone             = false
  hotplug                = "network,disk,usb"
  memory                 = 6144
  name                   = "K3S"
  onboot                 = true
  qemu_os                = "l26"
  scsihw                 = "virtio-scsi-single"
  tablet                 = true
  vcpus                  = 0
  vm_state               = "running"
  disks {
    scsi {
      scsi0 {
        disk {
          backup    = true
          cache     = null
          format    = "raw"
          iothread  = true
          readonly  = false
          replicate = true
          size      = "128G"
          storage   = "local-lvm"
        }
      }
    }
  }
  network {
    bridge    = "vmbr0"
    firewall  = true
    link_down = false
    macaddr   = "BC:24:11:55:00:98"
    model     = "virtio"
    mtu       = 0
    queues    = 0
    rate      = 0
    tag       = -1
  }
  smbios {
    uuid = "a26e7393-2fc7-496b-817c-578cedc60556"
  }
}

resource "dns_a_record_set" "k3s-node-1" {
  zone = "ross.in."
  name = "k3s-1"

  addresses = [var.ip_k3s_1]
}
