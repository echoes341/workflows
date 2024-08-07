resource "kubernetes_namespace" "fission" {
  metadata {
    name = "fission"
  }
}

data "kustomization" "fission_kustomize" {
  provider = kustomization

  path = "github.com/fission/fission/crds/v1?ref=v1.20.1"
}

resource "kustomization_resource" "fission_crds" {
  provider = kustomization
  for_each = data.kustomization.fission_kustomize.ids
  manifest = data.kustomization.fission_kustomize.manifests[each.value]
}

resource "helm_release" "fission" {
  name       = "fission"
  namespace  = kubernetes_namespace.fission.metadata.0.name
  repository = "https://fission.github.io/fission-charts/"
  chart      = "fission-all"

  set {
    name  = "serviceType"
    value = "NodePort"
  }
  set {
    name  = "routerServiceType"
    value = "NodePort"
  }
}
