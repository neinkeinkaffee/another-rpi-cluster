resource "helm_release" "longhorn" {
  name = "longhorn"
  repository = "https://charts.longhorn.io"
  chart = "longhorn"
  namespace = "longhorn"

  set {
    name = "defaultSettings.defaultDataPath"
    value = "/storage"
  }
}

resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = "longhorn"
  }
}
