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
