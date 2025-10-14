# AWS Load Balancer Controller (using custom Helm chart)
resource "helm_release" "aws_load_balancer_controller" {
  count = var.install_aws_load_balancer_controller ? 1 : 0

  name      = "aws-load-balancer-controller"
  chart     = "${path.module}/charts/aws-load-balancer-controller"
  namespace = "kube-system"

  # Important: Update dependencies before install
  dependency_update = true
  timeout           = 600
  atomic            = true

  values = [
    yamlencode({
      # ServiceAccount configuration with IRSA
      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller[0].arn
        }
      }

      # Controller configuration (passed to upstream chart)
      controller = {
        clusterName = data.terraform_remote_state.infra.outputs.eks_cluster_name
        region      = var.aws_region
        vpcId       = data.terraform_remote_state.infra.outputs.vpc_id

        # Service account (uses the one we create above)
        serviceAccount = {
          create = false
          name   = "aws-load-balancer-controller"
        }

        # Resource configuration
        resources = {
          limits = {
            cpu    = "200m"
            memory = "500Mi"
          }
          requests = {
            cpu    = "100m"
            memory = "200Mi"
          }
        }

        # High availability
        replicaCount = 2

        # Pod anti-affinity for HA
        affinity = {
          podAntiAffinity = {
            preferredDuringSchedulingIgnoredDuringExecution = [
              {
                weight = 100
                podAffinityTerm = {
                  labelSelector = {
                    matchExpressions = [
                      {
                        key      = "app.kubernetes.io/name"
                        operator = "In"
                        values   = ["aws-load-balancer-controller"]
                      }
                    ]
                  }
                  topologyKey = "kubernetes.io/hostname"
                }
              }
            ]
          }
        }

        # Logging
        logLevel = "info"

        # Features
        enableShield = false
        enableWaf    = false
        enableWafv2  = false

        # Pod disruption budget
        podDisruptionBudget = {
          maxUnavailable = 1
        }
      }
    })
  ]

  depends_on = [
    aws_iam_role_policy.aws_load_balancer_controller
  ]
}

# cert-manager for SSL/TLS certificate management
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.16.2"
  namespace        = "cert-manager"
  create_namespace = true

  timeout = 600
  atomic  = true

  values = [
    yamlencode({
      crds = {
        enabled = true
        keep    = true
      }
    })
  ]
}

# Let's Encrypt ClusterIssuers (apply after cert-manager is ready)
resource "kubernetes_manifest" "letsencrypt_prod" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = "cloud-solutions@meireles.dev"
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [{
          http01 = {
            ingress = {
              ingressClassName = "alb"
            }
          }
        }]
      }
    }
  }

  depends_on = [helm_release.cert_manager]
}

resource "kubernetes_manifest" "letsencrypt_staging" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-staging"
    }
    spec = {
      acme = {
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        email  = "cloud-solutions@meireles.dev"
        privateKeySecretRef = {
          name = "letsencrypt-staging"
        }
        solvers = [{
          http01 = {
            ingress = {
              ingressClassName = "alb"
            }
          }
        }]
      }
    }
  }

  depends_on = [helm_release.cert_manager]
}

# ArgoCD Module
module "argocd" {
  source = "../modules/argocd"

  namespace            = "argocd"
  argocd_chart_version = var.argocd_chart_version
  argocd_domain        = var.argocd_domain
  server_insecure      = var.argocd_server_insecure
  server_service_type  = var.argocd_server_service_type
  ingress_enabled      = var.argocd_ingress_enabled
  ingress_class_name   = var.argocd_ingress_class_name
  ingress_annotations  = var.argocd_ingress_annotations
  enable_certificate   = var.argocd_enable_certificate
  certificate_issuer   = var.argocd_certificate_issuer

  depends_on = [
    helm_release.cert_manager,
    kubernetes_manifest.letsencrypt_prod
  ]
}
