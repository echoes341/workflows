resource "kubernetes_namespace" "registry" {
  metadata {
    name = "registry"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "registry" {
  metadata {
    name      = "registry-pvc"
    namespace = kubernetes_namespace.registry.metadata.0.name
  }
  wait_until_bound = false
  spec {
    access_modes = ["ReadWriteOnce"]
    volume_mode  = "Filesystem"
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "helm_release" "registry" {
  name       = "registry"
  repository = "https://helm.twun.io"
  chart      = "docker-registry"
  namespace  = kubernetes_namespace.registry.metadata.0.name
  values = [yamlencode({
    ingress = {
      enabled   = true
      className = "traefik"
      hosts     = ["registry.k3s.ross.in"]
    }
    persistence = {
      deleteEnabled = true
      enabled       = true
      existingClaim = kubernetes_persistent_volume_claim_v1.registry.metadata.0.name
      size          = "10Gi"
    }
  })]
}

resource "dns_a_record_set" "k3s-registry" {
  zone      = "ross.in."
  name      = "registry.k3s"
  addresses = [var.ip_k3s_1]
}
