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

output "eks_oidc_provider" {
  description = "OIDC provider URL without https://"
  value       = module.eks.oidc_provider
}

output "eks_cluster_certificate_authority" {
  description = "Base64 encoded certificate data for the cluster"
  value       = module.eks.cluster_certificate_authority_data
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

output "ebs_csi_driver_role_arn" {
  description = "IAM role ARN for EBS CSI Driver"
  value       = module.eks.ebs_csi_driver_role_arn
  sensitive   = true
}

output "efs_csi_driver_role_arn" {
  description = "IAM role ARN for EFS CSI Driver"
  value       = module.eks.efs_csi_driver_role_arn
  sensitive   = true
}

output "efs_id" {
  description = "ID of the EFS file system"
  value       = module.efs.efs_id
}

output "cloudwatch_log_group" {
  description = "Name of the CloudWatch log group"
  value       = module.cloudwatch.log_group_name
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
