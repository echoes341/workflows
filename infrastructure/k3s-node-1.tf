# install is left to the user
resource "proxmox_vm_qemu" "k3s-node-1" {
  automatic_reboot       = true
  balloon                = 0
  bios                   = "seabios"
  agent                  = 1
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

# must have propagated ssh keys to the node
resource "null_resource" "k3s-node-1-traefik-config" {
  depends_on = [proxmox_vm_qemu.k3s-node-1, dns_a_record_set.k3s-node-1]
  connection {
    type = "ssh"
    host = var.ip_k3s_1
    user = "root"
  }

  provisioner "file" {
    content = yamlencode({
      apiVersion = "helm.cattle.io/v1"
      kind       = "HelmChartConfig"
      metadata = {
        name      = "traefik"
        namespace = "kube-system"
      }
      spec = {
        valuesContent = {
          globalArguments = [
            "--serversTransport.insecureSkipVerify=true"
          ]
        }
      }
    })

    destination = "/var/lib/rancher/k3s/server/manifests/traefik-config.yaml"
  }
}

resource "tls_private_key" "k3s-node-1" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "k3s-node-1" {
  private_key_pem = tls_private_key.k3s-node-1.private_key_pem

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  validity_period_hours = 8760 # 1 year
  early_renewal_hours   = 720  # 30 days

  dns_names = ["${dns_a_record_set.k3s-node-1.name}.ross.in", "*.k3s.ross.in"]
  subject {
    common_name  = "${dns_a_record_set.k3s-node-1.name}.ross.in"
    organization = "Ross"
  }
}

resource "kubernetes_secret_v1" "k3s-traefik-cert" {
  metadata {
    name      = "ross-in-cert"
    namespace = "kube-system"
  }

  data = {
    "tls.crt" = tls_self_signed_cert.k3s-node-1.cert_pem
    "tls.key" = tls_private_key.k3s-node-1.private_key_pem
  }

  type = "kubernetes.io/tls"
}

resource "kubernetes_manifest" "k3s-traefik-cert-config" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "TLSStore"
    metadata = {
      name      = "default"
      namespace = "kube-system"
    }

    spec = {
      defaultCertificate = {
        secretName = kubernetes_secret_v1.k3s-traefik-cert.metadata[0].name
      }
    }
  }
}
