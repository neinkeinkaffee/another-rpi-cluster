resource "helm_release" "longhorn" {
  name = "longhorn"
  repository = "https://charts.longhorn.io"
  chart = "longhorn"
  namespace = "longhorn"

  set {
    name = "defaultSettings.defaultDataPath"
    value = "/vol"
  }
}

resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = "longhorn"
  }
}

resource "kubernetes_ingress_v1" "longhorn" {
  metadata {
    name = "longhorn"
    namespace = "longhorn"
    annotations = {
      ingress_class_name = "traefik"
    }
  }
  spec {
    rule {
      host = "longhorn.otherthings.local"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "longhorn-frontend"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}