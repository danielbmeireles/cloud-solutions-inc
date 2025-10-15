# Production Environment Configuration
environment  = "production"
aws_region   = "eu-west-1"
state_bucket = "cloud-solutions-terraform-state"
project_name = "cloud-solutions"

# AWS Load Balancer Controller
install_aws_load_balancer_controller       = true
aws_load_balancer_controller_chart_version = "1.14.0"

# ArgoCD Configuration with Custom Domain & SSL/TLS
argocd_chart_version = "8.5.10"

# Domain configuration
# Your custom domain for ArgoCD
argocd_domain = "argocd.meireles.dev"

# Server configuration
# Disable insecure mode to enable TLS at ALB level
argocd_server_insecure     = true # Keep insecure at pod level (TLS terminates at ALB)
argocd_server_service_type = "ClusterIP"

# Ingress configuration with SSL/TLS via AWS Certificate Manager (ACM)
argocd_ingress_enabled    = true
argocd_ingress_class_name = "alb"

argocd_ingress_annotations = {
  "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
  "alb.ingress.kubernetes.io/target-type" = "ip"
  "alb.ingress.kubernetes.io/group.name"  = "argocd"

  # SSL/TLS Configuration via ACM
  # Certificate ARN will be automatically injected by the ACM module below

  # Enable HTTPS and redirect HTTP to HTTPS
  "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
  "alb.ingress.kubernetes.io/ssl-redirect"    = "443"

  # Use modern TLS policy
  "alb.ingress.kubernetes.io/ssl-policy" = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  # Backend protocol (HTTP since TLS terminates at ALB)
  "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
}

# ACM Certificate Configuration (Automated via Terraform)
# Enable ACM certificate creation via Terraform
acm_certificate_enabled = true

# Wait for certificate validation (requires DNS records to be added to Squarespace)
# Set to false for initial apply, then true for subsequent applies after adding DNS records
# When false: Terraform creates certificate but doesn't wait for validation
# When true: Terraform waits for validation to complete (requires CNAME records in DNS)
acm_wait_for_validation = false

# Optional: Add additional domain names (e.g., wildcard or multiple subdomains)
# acm_subject_alternative_names = ["*.meireles.dev"]
