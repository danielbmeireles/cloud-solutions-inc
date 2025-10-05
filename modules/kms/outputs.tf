output "eks_key_id" {
  description = "ID of the KMS key for EKS secrets encryption"
  value       = aws_kms_key.eks.key_id
}

output "eks_key_arn" {
  description = "ARN of the KMS key for EKS secrets encryption"
  value       = aws_kms_key.eks.arn
}

output "eks_key_alias" {
  description = "Alias of the KMS key for EKS secrets encryption"
  value       = aws_kms_alias.eks.name
}

output "ebs_key_id" {
  description = "ID of the KMS key for EBS volume encryption"
  value       = aws_kms_key.ebs.key_id
}

output "ebs_key_arn" {
  description = "ARN of the KMS key for EBS volume encryption"
  value       = aws_kms_key.ebs.arn
}

output "ebs_key_alias" {
  description = "Alias of the KMS key for EBS volume encryption"
  value       = aws_kms_alias.ebs.name
}
