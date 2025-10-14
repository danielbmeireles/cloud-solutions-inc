output "argocd_namespace" {
  description = "ArgoCD namespace"
  value       = module.argocd.namespace
}

output "argocd_server_url" {
  description = "ArgoCD server URL"
  value       = "https://${var.argocd_domain}"
}

output "aws_load_balancer_controller_installed" {
  description = "Whether AWS Load Balancer Controller was installed"
  value       = var.install_aws_load_balancer_controller
}

output "aws_load_balancer_controller_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller"
  value       = var.install_aws_load_balancer_controller ? aws_iam_role.aws_load_balancer_controller[0].arn : null
  sensitive   = true
}
