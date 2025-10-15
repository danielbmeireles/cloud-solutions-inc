output "namespace" {
  description = "ArgoCD namespace"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_server_service_name" {
  description = "ArgoCD server service name"
  value       = "argocd-server"
}

output "argocd_version" {
  description = "ArgoCD Helm chart version"
  value       = var.argocd_chart_version
}

output "argocd_domain" {
  description = "ArgoCD domain (if ingress enabled)"
  value       = var.argocd_domain
}

output "alb_hostname" {
  description = "ALB hostname from ingress (if enabled)"
  value       = var.ingress_enabled ? try(one(data.kubernetes_ingress_v1.argocd_ingress[*].status[0].load_balancer[0].ingress[0].hostname), "") : ""
}

# Data source to get ingress status
data "kubernetes_ingress_v1" "argocd_ingress" {
  count = var.ingress_enabled ? 1 : 0

  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  depends_on = [helm_release.argocd]
}
