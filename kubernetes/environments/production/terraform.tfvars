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
argocd_domain              = "argocd-dbm.duckdns.org"
argocd_server_insecure     = false # TLS enabled via cert-manager
argocd_server_service_type = "ClusterIP"

# ArgoCD Ingress
argocd_ingress_enabled    = true
argocd_ingress_class_name = "alb"

argocd_ingress_annotations = {
  "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
  "alb.ingress.kubernetes.io/target-type" = "ip"
  # Force HTTPS/SSL
  "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
  "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
  "alb.ingress.kubernetes.io/backend-protocol" = "HTTPS"
}

# SSL/TLS Certificate via cert-manager
argocd_enable_certificate  = true
argocd_certificate_issuer  = "letsencrypt-prod"
