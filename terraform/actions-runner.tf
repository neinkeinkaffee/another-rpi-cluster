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
          "repository" = "neinkeinkaffee/net-prog"
        }
      }
    }
  }
}
