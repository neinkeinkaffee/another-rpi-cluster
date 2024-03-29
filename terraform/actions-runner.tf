data "local_file" "github_app_private_key_file" {
  filename = var.github_app_private_key_file
}

resource "helm_release" "actions-runner" {
  name = "actions-runner-controller"
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart = "actions-runner-controller"
  namespace = "actions-runner-system"
  version = "0.23.2"
  create_namespace = true

  set {
    name = "authSecret.create"
    value = true
  }

  set {
    name  = "authSecret.github_app_id"
    value = var.github_app_id
  }

  set {
    name  = "authSecret.github_app_installation_id"
    value = var.github_app_installation_id
  }

  set {
    name = "authSecret.github_app_private_key"
    value = data.local_file.github_app_private_key_file.content
  }
}

resource "kubernetes_service_account" "actions_runner" {
  metadata {
    name = "actions-runner"
#    namespace = "actions-runner-system"
  }
}

resource "kubernetes_role" "actions_runner" {
  metadata {
    name = "actions-runner"
  }

  rule {
    api_groups     = [""]
    resources      = ["pods"]
    verbs          = ["get", "list", "create", "delete"]
  }

  rule {
    api_groups     = ["apps"]
    resources      = ["deployments"]
    verbs          = ["get", "list", "create", "patch", "delete"]
  }

  rule {
    api_groups     = [""]
    resources      = ["services"]
    verbs          = ["get", "list", "create", "patch", "delete"]
  }

  rule {
    api_groups     = ["networking.k8s.io"]
    resources      = ["ingresses"]
    verbs          = ["get", "list", "create", "patch", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["get", "create"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "create", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "create", "delete"]
  }
}

resource "kubernetes_role_binding" "actions_runner" {
  metadata {
    name = "actions-runner"
#    namespace = "actions-runner-system"
  }

  subject {
    kind = "ServiceAccount"
    name = "actions-runner"
    api_group = ""
  }

  role_ref {
    name      = "actions-runner"
    kind      = "Role"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_manifest" "net_prog_runner" {
  manifest = {
    "apiVersion" = "actions.summerwind.dev/v1alpha1"
    "kind" = "RunnerDeployment"
    "metadata" = {
      "name" = "net-prog-runner"
      "namespace" = "default"
    }
    "spec" = {
      "replicas" = 1
      "template" = {
        "spec" = {
          "automountServiceAccountToken" = true
          "serviceAccountName" = "actions-runner"
          "repository" = "neinkeinkaffee/net-prog"
        }
      }
    }
  }
}
