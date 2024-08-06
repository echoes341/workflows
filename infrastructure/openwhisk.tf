resource "kubernetes_namespace" "openwhisk" {
  metadata {
    name = "openwhisk"
  }
}

resource "helm_release" "openwhisk" {
  chart     = "./openwhisk-deploy-kube/helm/openwhisk"
  namespace = kubernetes_namespace.openwhisk.metadata.0.name
  name      = "openwhisk"

  set {
    name  = "affinity.enabled"
    value = false
  }
  set {
    name  = "toleration.enabled"
    value = false
  }
  set {
    name  = "invoker.options"
    value = "-Dwhisk.kubernetes.user-pod-node-affinity.enabled=false"
  }

  set {
    name  = "whisk.ingress.type"
    value = "NodePort"
  }

  set {
    name  = "whisk.ingress.apiHostName"
    value = "openwhisk-nginx"
  }

  set {
    name  = "whisk.ingress.apiHostPort"
    value = "443"
  }

  set {
    name  = "whisk.ingress.useInternally"
    value = "false"
  }
}

resource "dns_a_record_set" "openwhisk" {
  zone      = "ross.in."
  name      = "openwhisk.k3s"
  addresses = [var.ip_k3s_1]
}

resource "kubernetes_ingress_v1" "openwhisk_k3s_ross_in" {
  depends_on = [helm_release.openwhisk]

  metadata {
    name      = "openwhisk-nginx-in"
    namespace = kubernetes_namespace.openwhisk.metadata.0.name
  }

  spec {
    tls {
      hosts = ["openwhisk.k3s.ross.in"]
    }
    rule {
      host = "openwhisk.k3s.ross.in"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "openwhisk-nginx"
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
  }
}
