# ArgoCD Namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace

    labels = {
      name = var.namespace
    }
  }
}

# ArgoCD Helm Release
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    yamlencode({
      global = {
        domain = var.argocd_domain
      }

      configs = {
        params = {
          "server.insecure" = var.server_insecure
        }
      }

      # Resource limits
      controller = {
        resources = var.controller_resources
      }

      repoServer = {
        resources = var.repo_server_resources
      }

      server = {
        service = {
          type = var.server_service_type
        }

        ingress = {
          enabled          = var.ingress_enabled
          ingressClassName = var.ingress_class_name
          annotations      = var.ingress_annotations
        }

        resources = var.server_resources
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}
