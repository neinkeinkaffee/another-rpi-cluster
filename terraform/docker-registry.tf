resource "kubernetes_namespace" "docker_registry" {
  metadata {
    name = "registry"
  }
}

resource "kubernetes_persistent_volume_claim" "docker_registry" {
  metadata {
    name = "registry"
    namespace = kubernetes_namespace.docker_registry.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "longhorn"
  }
}

resource "kubernetes_deployment" "docker_registry" {
  metadata {
    name = "registry"
    namespace = kubernetes_namespace.docker_registry.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "registry"
      }
    }

    template {
      metadata {
        labels = {
          app = "registry"
          name = "registry"
        }
      }

      spec {
        container {
          image = "registry:2"
          name  = "registry"
          port {
            container_port = 5000
          }
          volume_mount {
            mount_path = "/var/lib/registry"
            sub_path = "registry"
            name       = "registry"
          }
        }

        volume {
          name = "registry"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.docker_registry.metadata[0].name
          }
        }
      }
    }
  }
}



resource "kubernetes_service_v1" "registry" {
  metadata {
    name = "registry"
    namespace = kubernetes_namespace.docker_registry.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment.docker_registry.spec[0].template[0].metadata[0].labels.app
    }
    port {
      port = 5000
    }
  }
}

resource "kubernetes_ingress_v1" "docker_registry" {
  metadata {
    name = "registry"
    annotations = {
      ingress_class_name = "traefik"
    }
    namespace = kubernetes_namespace.docker_registry.metadata[0].name
  }
  spec {
    rule {
      host = "registry.otherthings.local"
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service_v1.registry.metadata[0].name
              port {
                number = kubernetes_service_v1.registry.spec[0].port[0].port
              }
            }
          }
        }
      }
    }
  }
}
