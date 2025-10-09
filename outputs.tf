output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "eks_cluster_id" {
  description = "ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "eks_cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.eks.cluster_arn
  sensitive   = true
}

output "eks_oidc_provider_arn" {
  description = "ARN of the OIDC Provider for EKS"
  value       = module.eks.oidc_provider_arn
  sensitive   = true
}

output "eks_node_group_id" {
  description = "ID of the EKS node group"
  value       = module.eks.node_group_id
}

output "eks_node_group_role_arn" {
  description = "IAM role ARN of the EKS node group"
  value       = module.eks.node_group_role_arn
  sensitive   = true
}

output "aws_load_balancer_controller_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller"
  value       = module.eks.aws_load_balancer_controller_role_arn
  sensitive   = true
}

output "ebs_csi_driver_role_arn" {
  description = "IAM role ARN for EBS CSI Driver"
  value       = module.eks.ebs_csi_driver_role_arn
  sensitive   = true
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.storage.s3_bucket_name
}

output "efs_id" {
  description = "ID of the EFS file system"
  value       = module.storage.efs_id
}

output "cloudwatch_log_group" {
  description = "Name of the CloudWatch log group"
  value       = module.monitoring.log_group_name
}

output "kubeconfig" {
  description = "kubectl config for accessing the EKS cluster"
  value       = module.eks.kubeconfig
  sensitive   = true
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "eks_kms_key_id" {
  description = "ID of the KMS key used for EKS secrets encryption"
  value       = module.kms.eks_key_id
}

output "eks_kms_key_arn" {
  description = "ARN of the KMS key used for EKS secrets encryption"
  value       = module.kms.eks_key_arn
  sensitive   = true
}

output "ebs_kms_key_id" {
  description = "ID of the KMS key used for EBS volume encryption"
  value       = module.kms.ebs_key_id
}

output "ebs_kms_key_arn" {
  description = "ARN of the KMS key used for EBS volume encryption"
  value       = module.kms.ebs_key_arn
  sensitive   = true
}

output "argocd_namespace" {
  description = "Namespace where ArgoCD is deployed"
  value       = module.argocd.namespace
}

output "argocd_server_service_name" {
  description = "ArgoCD server service name"
  value       = module.argocd.argocd_server_service_name
}

output "argocd_port_forward_command" {
  description = "Command to port-forward to ArgoCD server"
  value       = "kubectl port-forward svc/${module.argocd.argocd_server_service_name} -n ${module.argocd.namespace} 8080:443"
}

output "argocd_initial_password_command" {
  description = "Command to retrieve ArgoCD initial admin password"
  value       = "kubectl -n ${module.argocd.namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "argocd_ingress_url_command" {
  description = "Command to get ArgoCD ingress URL"
  value       = "kubectl get ingress -n ${module.argocd.namespace} argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}
