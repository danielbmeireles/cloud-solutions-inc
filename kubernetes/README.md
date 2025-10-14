# Kubernetes Configuration

This directory contains Kubernetes-related Terraform configurations for deploying additional components to the EKS cluster.

## Components

- **cert-manager**: Automatic SSL/TLS certificate management via Let's Encrypt
- **AWS Load Balancer Controller**: Manages ALB/NLB for ingress resources
- **ArgoCD**: GitOps continuous delivery tool with SSL/TLS support

## Directory Structure

```
kubernetes/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output values
├── iam.tf                     # IAM roles and policies
├── backend.tf                 # Terraform backend configuration
├── versions.tf                # Provider version constraints
├── policies/                  # IAM policy documents
├── charts/                    # Custom Helm charts
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

### SSL/TLS Configuration

#### Option 1: Using cert-manager with Let's Encrypt (Recommended for DuckDNS)

**See: [DuckDNS Setup Guide](../docs/DUCKDNS_SETUP.md)** for complete step-by-step instructions.

The infrastructure includes cert-manager for automatic SSL/TLS certificates via Let's Encrypt:

```hcl
# In environments/production/terraform.tfvars
argocd_domain              = "argocd-dbm.duckdns.org"
argocd_server_insecure     = false
argocd_enable_certificate  = true
argocd_certificate_issuer  = "letsencrypt-prod"

argocd_ingress_annotations = {
  "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
  "alb.ingress.kubernetes.io/target-type"      = "ip"
  "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
  "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
  "alb.ingress.kubernetes.io/backend-protocol" = "HTTPS"
}
```

Benefits:
- Free SSL certificates
- Automatic renewal every 90 days
- No AWS ACM required
- Works with DuckDNS free domains

#### Option 2: Using ACM Certificate (For Custom Domains)

For production use with custom domains, configure SSL/TLS via AWS Certificate Manager:

1. Request/import certificate in AWS Certificate Manager (ACM)
2. Update ingress annotations:

```hcl
argocd_ingress_annotations = {
  "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
  "alb.ingress.kubernetes.io/target-type"      = "ip"
  "alb.ingress.kubernetes.io/certificate-arn"  = "arn:aws:acm:REGION:ACCOUNT:certificate/CERT_ID"
  "alb.ingress.kubernetes.io/ssl-policy"       = "ELBSecurityPolicy-TLS-1-2-2017-01"
  "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTPS\":443}]"
  "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
}
```

3. Update domain and disable insecure mode:

```hcl
argocd_domain          = "argocd.example.com"
argocd_server_insecure = false
```

4. Create DNS record pointing to ALB

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

## Related Documentation

- [ArgoCD Troubleshooting Guide](ARGOCD_TROUBLESHOOTING.txt)
- [Terraform Configuration Guide](TERRAFORM.md)
- [EKS Documentation](../docs/EKS.md)
- [CI/CD Documentation](../docs/CICD.md)

## Cleanup

To destroy all resources:

```bash
terraform destroy -var-file=environments/production/terraform.tfvars
```

**Warning**: This will delete all Kubernetes resources managed by this configuration, including ingress resources and their associated ALBs.
