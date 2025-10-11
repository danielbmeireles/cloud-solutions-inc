# Production Environment Configuration

environment  = "production"
aws_region   = "eu-west-1"
state_bucket = "cloud-solutions-terraform-state"
project_name = "cloud-solutions"

# AWS Load Balancer Controller
install_aws_load_balancer_controller       = true
aws_load_balancer_controller_chart_version = "1.14.0"

# ArgoCD Configuration
argocd_chart_version       = "8.5.10"
argocd_domain              = "argocd.local"
argocd_server_insecure     = true # Set to false when using proper TLS
argocd_server_service_type = "ClusterIP"

# ArgoCD Ingress
argocd_ingress_enabled    = true
argocd_ingress_class_name = "alb"

argocd_ingress_annotations = {
  "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
  "alb.ingress.kubernetes.io/target-type" = "ip"
  # Add more annotations as needed:
  # "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:..."
  # "alb.ingress.kubernetes.io/ssl-policy" = "ELBSecurityPolicy-TLS-1-2-2017-01"
  # "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\":443}]"
}
