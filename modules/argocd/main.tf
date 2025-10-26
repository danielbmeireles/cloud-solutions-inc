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

      # Application Controller Configuration
      controller = {
        replicas  = var.controller_replicas
        resources = var.controller_resources

        # Pod anti-affinity for HA
        affinity = var.enable_ha ? {
          podAntiAffinity = {
            preferredDuringSchedulingIgnoredDuringExecution = [
              {
                weight = 100
                podAffinityTerm = {
                  labelSelector = {
                    matchLabels = {
                      "app.kubernetes.io/name" = "argocd-application-controller"
                    }
                  }
                  topologyKey = "kubernetes.io/hostname"
                }
              }
            ]
          }
        } : {}

        # Pod disruption budget - only enable if HA is enabled AND we have multiple replicas
        pdb = var.enable_ha && var.controller_replicas > 1 ? {
          enabled        = true
          minAvailable   = 1
          maxUnavailable = null
          } : {
          enabled        = false
          minAvailable   = null
          maxUnavailable = null
        }
      }

      # Repo Server Configuration
      repoServer = {
        replicas  = var.repo_server_replicas
        resources = var.repo_server_resources

        # Pod anti-affinity for HA
        affinity = var.enable_ha ? {
          podAntiAffinity = {
            preferredDuringSchedulingIgnoredDuringExecution = [
              {
                weight = 100
                podAffinityTerm = {
                  labelSelector = {
                    matchLabels = {
                      "app.kubernetes.io/name" = "argocd-repo-server"
                    }
                  }
                  topologyKey = "kubernetes.io/hostname"
                }
              }
            ]
          }
        } : {}

        # Pod disruption budget - only enable if HA is enabled AND we have multiple replicas
        pdb = var.enable_ha && var.repo_server_replicas > 1 ? {
          enabled        = true
          minAvailable   = 1
          maxUnavailable = null
          } : {
          enabled        = false
          minAvailable   = null
          maxUnavailable = null
        }
      }

      # Server Configuration
      server = {
        replicas = var.server_replicas

        service = {
          type = var.server_service_type
        }

        ingress = {
          enabled          = var.ingress_enabled
          ingressClassName = var.ingress_class_name
          annotations      = var.ingress_annotations
        }

        resources = var.server_resources

        # Pod anti-affinity for HA
        affinity = var.enable_ha ? {
          podAntiAffinity = {
            preferredDuringSchedulingIgnoredDuringExecution = [
              {
                weight = 100
                podAffinityTerm = {
                  labelSelector = {
                    matchLabels = {
                      "app.kubernetes.io/name" = "argocd-server"
                    }
                  }
                  topologyKey = "kubernetes.io/hostname"
                }
              }
            ]
          }
        } : {}

        # Pod disruption budget - only enable if HA is enabled AND we have multiple replicas
        pdb = var.enable_ha && var.server_replicas > 1 ? {
          enabled        = true
          minAvailable   = 1
          maxUnavailable = null
          } : {
          enabled        = false
          minAvailable   = null
          maxUnavailable = null
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}
