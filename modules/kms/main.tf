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

# Separate policy resource to avoid circular dependency
resource "aws_kms_key_policy" "eks" {
  key_id = aws_kms_key.eks.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Sid    = "Enable IAM policies"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Auto Scaling to use the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        }
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow attachment of persistent resources"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        }
        Action   = "kms:CreateGrant"
        Resource = "*"
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = "true"
          }
        }
      }
      ],
      var.node_group_arn != "" ? [{
        Sid    = "Allow Node Group Role"
        Effect = "Allow"
        Principal = {
          AWS = var.node_group_arn
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }] : []
    )
  })
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

# Separate policy resource to avoid circular dependency
resource "aws_kms_key_policy" "ebs" {
  key_id = aws_kms_key.ebs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Sid    = "Enable IAM policies"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Auto Scaling to use the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        }
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow attachment of persistent resources"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        }
        Action   = "kms:CreateGrant"
        Resource = "*"
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = "true"
          }
        }
      },
      {
        Sid    = "Allow EC2 Service"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "ec2.${data.aws_region.current.region}.amazonaws.com"
          }
        }
      }
      ],
      var.node_group_arn != "" ? [{
        Sid    = "Allow Node Group Role"
        Effect = "Allow"
        Principal = {
          AWS = var.node_group_arn
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
      }] : []
    )
  })
}

resource "aws_kms_alias" "ebs" {
  name          = "alias/${var.project_name}-${var.environment}-ebs"
  target_key_id = aws_kms_key.ebs.key_id
}
