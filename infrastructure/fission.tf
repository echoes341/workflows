resource "kubernetes_namespace" "fission" {
  metadata {
    name = "fission"
  }
}

resource "kubernetes_namespace" "fission_functions" {
  metadata {
    name = "functions"
  }
}

data "kustomization" "fission_kustomize" {
  provider = kustomization

  path = "github.com/fission/fission/crds/v1?ref=v1.20.2"
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
  version    = "v1.20.2"
  depends_on = [kustomization_resource.fission_crds]

  set {
    name  = "serviceType"
    value = "NodePort"
  }
  set {
    name  = "routerServiceType"
    value = "NodePort"
  }
  set {
    name  = "defaultNamespace"
    value = kubernetes_namespace.fission_functions.metadata.0.name
  }
}
