# IAM Role for AWS Load Balancer Controller (IRSA)
resource "aws_iam_role" "aws_load_balancer_controller" {
  count = var.install_aws_load_balancer_controller ? 1 : 0

  name = "${var.project_name}-${var.environment}-aws-lb-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = data.terraform_remote_state.infra.outputs.eks_oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${data.terraform_remote_state.infra.outputs.eks_oidc_provider}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
            "${data.terraform_remote_state.infra.outputs.eks_oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-aws-lb-controller-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Attach AWS Load Balancer Controller policy
resource "aws_iam_role_policy" "aws_load_balancer_controller" {
  count = var.install_aws_load_balancer_controller ? 1 : 0

  name = "${var.project_name}-${var.environment}-aws-lb-controller-policy"
  role = aws_iam_role.aws_load_balancer_controller[0].id

  policy = file("${path.module}/policies/aws-load-balancer-controller-policy.json")
}
