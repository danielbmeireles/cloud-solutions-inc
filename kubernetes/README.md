# Kubernetes Infrastructure - Cloud Solutions Inc.

Production-ready Kubernetes infrastructure for AWS EKS with ArgoCD and AWS Load Balancer Controller.

## 🎯 Features

- ✅ **AWS Load Balancer Controller** - Automatic ALB/NLB provisioning
- ✅ **ArgoCD** - GitOps continuous delivery
- ✅ **AWS Certificate Manager (ACM)** - Free SSL/TLS certificates with automatic renewal
- ✅ **Automated Certificate Management** - ACM certificates created via Terraform
- ✅ **High Availability** - Multi-AZ deployment with pod anti-affinity
- ✅ **Infrastructure as Code** - 100% Terraform managed

## 📚 Documentation

For comprehensive documentation, see the main [docs](../docs/) directory:

- **[ArgoCD Custom Domain Setup](../docs/ARGOCD_CUSTOM_DOMAIN.md)** - Complete guide for setting up ArgoCD with custom domain and SSL/TLS via AWS ACM (RECOMMENDED)
- **[Quick Setup Guide](../docs/QUICK_SETUP_GUIDE.md)** - 30-minute quick start guide
- **[Architecture](../docs/ARCHITECTURE.md)** - Infrastructure components and design decisions
- **[EKS Documentation](../docs/EKS.md)** - EKS deployment, configuration, and operations
- **[Terraform Reference](../docs/TERRAFORM.md)** - Terraform module and variable reference

## Directory Structure

```
kubernetes/
├── main.tf                    # Main Terraform configuration (ALB Controller, ACM, ArgoCD)
├── data.tf                    # Data sources (remote state)
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output values (certificate info, ArgoCD URL)
├── iam.tf                     # IAM roles and policies
├── backend.tf                 # Terraform backend configuration
├── versions.tf                # Provider version constraints
├── policies/                  # IAM policy documents
├── charts/                    # Custom Helm charts
│   └── aws-load-balancer-controller/
├── environments/              # Environment-specific configurations
│   └── production/
│       ├── terraform.tfvars   # Production variables
│       └── tfbackend.hcl      # Backend configuration
└── scripts/                   # Helper scripts
    └── patch-argocd-ingress.sh
```

## Prerequisites

1. EKS cluster must be deployed (from root terraform configuration)
2. kubectl configured to access the cluster
3. Terraform >= 1.0
4. Helm >= 3.0

## Deployment

### Initialize Terraform

```bash
cd kubernetes
terraform init -backend-config=environments/production/tfbackend.hcl
```

### Plan and Apply

```bash
terraform plan -var-file=environments/production/terraform.tfvars
terraform apply -var-file=environments/production/terraform.tfvars
```

## AWS Load Balancer Controller

The AWS Load Balancer Controller is automatically installed when `install_aws_load_balancer_controller = true`.

### Features

- Automatic ALB/NLB provisioning for Kubernetes ingress resources
- Native AWS integration for better performance
- Support for advanced ALB features (target groups, listeners, etc.)

### Configuration

Edit `environments/production/terraform.tfvars`:

```hcl
install_aws_load_balancer_controller       = true
aws_load_balancer_controller_chart_version = "1.14.0"
```

## ArgoCD

ArgoCD is deployed as a Helm release for GitOps-based application delivery.

### Accessing ArgoCD

#### Option 1: Via AWS Load Balancer (Default)

After deployment, get the ALB URL:

```bash
kubectl get ingress argocd-server -n argocd
```

**Note**: By default, the ingress requires the hostname `argocd.local`. To access via the ALB URL directly, run the patch script:

```bash
./scripts/patch-argocd-ingress.sh
```

This removes the hostname requirement and allows access via the ALB URL directly.

#### Option 2: Port Forward

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

Then access at: http://localhost:8080

### Initial Login

Username: `admin`

Get the password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

**Important**: Change the admin password after first login and delete the initial secret:

```bash
kubectl delete secret argocd-initial-admin-secret -n argocd
```

### Configuration

Edit `environments/production/terraform.tfvars`:

```hcl
# ArgoCD Configuration
argocd_chart_version       = "8.5.10"
argocd_domain              = "argocd.local"       # Update for production use
argocd_server_insecure     = true                # Set to false when using SSL
argocd_server_service_type = "ClusterIP"

# ArgoCD Ingress
argocd_ingress_enabled    = true
argocd_ingress_class_name = "alb"

argocd_ingress_annotations = {
  "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
  "alb.ingress.kubernetes.io/target-type" = "ip"
}
```

### SSL/TLS Configuration with AWS Certificate Manager

For production use with custom domains, ArgoCD uses AWS Certificate Manager (ACM) for SSL/TLS certificates.

**See: [ArgoCD Custom Domain Setup](../docs/ARGOCD_CUSTOM_DOMAIN.md)** for complete step-by-step instructions.

#### Configuration Example

```hcl
# In terraform.tfvars
argocd_domain = "argocd.meireles.dev"

# Enable ACM certificate (created automatically by Terraform)
acm_certificate_enabled = true
acm_wait_for_validation = false  # Set to true after adding DNS validation records

# Ingress configuration (certificate ARN injected automatically)
argocd_ingress_annotations = {
  "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
  "alb.ingress.kubernetes.io/target-type"      = "ip"
  "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
  "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
  "alb.ingress.kubernetes.io/ssl-policy"       = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
}
```

#### Setup Steps

1. **Deploy with Terraform** - ACM certificate is created automatically
2. **Get validation records** - Run `terraform output acm_validation_records`
3. **Add DNS validation CNAME** - Add validation record to your DNS provider (e.g., Squarespace)
4. **Wait for validation** - Certificate status changes to "ISSUED" (5-30 minutes)
5. **Add ArgoCD CNAME** - Point your domain to the ALB DNS name
6. **Access ArgoCD** - Visit `https://argocd.your-domain.com`

**Benefits:**
- ✅ Free SSL certificates with automatic renewal
- ✅ Fully automated certificate creation via Terraform
- ✅ Modern TLS 1.3 support
- ✅ No cert-manager complexity
- ✅ Works with any DNS provider (Squarespace, GoDaddy, Route53, etc.)
- ✅ Production-ready and reliable

**Total additional cost: $0** (ACM certificates are free for ALB use)

## Helper Scripts

### patch-argocd-ingress.sh

Removes the hostname restriction from the ArgoCD ingress, allowing access via the ALB URL directly.

```bash
./scripts/patch-argocd-ingress.sh
```

**When to use:**
- After initial deployment
- After any Terraform apply that updates the ArgoCD ingress
- When the ALB returns 404 errors

## Troubleshooting

### ArgoCD Ingress Returns 404

If the ALB URL returns a 404 error, the ingress may have a hostname restriction. Run:

```bash
./scripts/patch-argocd-ingress.sh
```

### ArgoCD Pods Not Starting

Check cluster resources:

```bash
kubectl top nodes
kubectl describe nodes | grep -A 5 "Allocated resources:"
```

If nodes are resource-constrained, scale up to larger instance types (see `ARGOCD_TROUBLESHOOTING.txt`).

### Helm Release Failed

Check pod status and events:

```bash
kubectl get pods -n argocd
kubectl describe pod <pod-name> -n argocd
```

Clean up and redeploy:

```bash
helm uninstall argocd -n argocd
kubectl delete namespace argocd
terraform apply -var-file=environments/production/terraform.tfvars
```

## Outputs

After successful deployment:

```bash
terraform output
```

Available outputs:
- `argocd_namespace`: ArgoCD namespace
- `argocd_server_url`: ArgoCD server URL
- `aws_load_balancer_controller_installed`: ALB controller installation status
- `aws_load_balancer_controller_role_arn`: IAM role ARN for ALB controller
- `acm_certificate_arn`: ACM certificate ARN (if enabled)
- `acm_certificate_status`: Certificate validation status
- `acm_validation_records`: DNS validation records for Squarespace/DNS provider

## Related Documentation

- [ArgoCD Custom Domain Setup](../docs/ARGOCD_CUSTOM_DOMAIN.md) - Complete SSL/TLS setup guide
- [Quick Setup Guide](../docs/QUICK_SETUP_GUIDE.md) - 30-minute quick start
- [Architecture Documentation](../docs/ARCHITECTURE.md)
- [EKS Documentation](../docs/EKS.md)
- [Terraform Reference](../docs/TERRAFORM.md)
- [CI/CD Documentation](../docs/CICD.md)

## Cleanup

To destroy all resources:

```bash
terraform destroy -var-file=environments/production/terraform.tfvars
```

**Warning**: This will delete all Kubernetes resources managed by this configuration, including ingress resources and their associated ALBs.
