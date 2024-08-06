resource "kubernetes_namespace" "kafka" {
  metadata {
    name = "kafka"
  }
}

resource "helm_release" "kafka" {
  name = "kafka"

  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "kafka"
  namespace  = kubernetes_namespace.kafka.metadata.0.name
  version    = "30.0.0"

  set {
    name  = "listeners.client.protocol"
    value = "PLAINTEXT"
  }

  set {
    name  = "controller.replicaCount"
    value = "1"
  }
}

resource "kubernetes_deployment" "kafka-ui" {
  metadata {
    name      = "kafka-ui"
    namespace = kubernetes_namespace.kafka.metadata.0.name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "kafka-ui"
      }
    }
    template {
      metadata {
        labels = {
          app = "kafka-ui"
        }
      }
      spec {
        container {
          image = "provectuslabs/kafka-ui:latest"
          name  = "kafka-ui"
          port {
            container_port = 8080
          }
          env {
            name  = "DYNAMIC_CONFIG_ENABLED"
            value = "true"
          }
          env {
            name  = "KAFKA_CLUSTERS_0_NAME"
            value = "kafka"
          }
          env {
            name  = "KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS"
            value = "kafka:9092"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "kafka-ui" {
  metadata {
    name      = "kafka-ui"
    namespace = kubernetes_namespace.kafka.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.kafka-ui.spec.0.template.0.metadata.0.labels.app
    }
    type = "ClusterIP"
    port {
      port        = 8080
      target_port = 8080
    }
  }
}
