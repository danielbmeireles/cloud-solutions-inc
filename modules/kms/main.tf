# KMS Key for EKS Cluster Secrets Encryption
resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key for ${var.project_name}-${var.environment}"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-key"
    Purpose     = "EKS Secrets Encryption"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${var.project_name}-${var.environment}-eks"
  target_key_id = aws_kms_key.eks.key_id
}

# KMS Key for EBS Volume Encryption
resource "aws_kms_key" "ebs" {
  description             = "EBS Volume Encryption Key for ${var.project_name}-${var.environment}"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-ebs-key"
    Purpose     = "EBS Volume Encryption"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_kms_alias" "ebs" {
  name          = "alias/${var.project_name}-${var.environment}-ebs"
  target_key_id = aws_kms_key.ebs.key_id
}
