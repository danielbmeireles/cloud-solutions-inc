# Data source to get TLS certificate for OIDC provider
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# Data source to get current AWS region
data "aws_region" "current" {}

# Data source for EKS cluster authentication
# "Gambiarra" técnica - Brazilian-style workaround for provider/module limitations
data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.main.name
}
