# 🚀 ArgoCD Deployment Guide <!-- omit in toc -->

Complete guide to deploy and access ArgoCD on Amazon EKS with optional custom domain and SSL/TLS support via AWS Certificate Manager.

## 📑 Table of Contents <!-- omit in toc -->

- [🏗️ Overview](#️-overview)
- [🏛️ Architecture](#️-architecture)
- [📋 Prerequisites](#-prerequisites)
- [⚙️ Deployment](#️-deployment)
- [🔐 Accessing ArgoCD](#-accessing-argocd)
- [🌐 Custom Domain Setup with SSL/TLS](#-custom-domain-setup-with-ssltls)
- [🔒 Post-Deployment Security](#-post-deployment-security)
- [🔧 Troubleshooting](#-troubleshooting)
- [📝 Configuration Reference](#-configuration-reference)
- [💰 Cost](#-cost)
- [🔄 Maintenance](#-maintenance)
- [External Resources](#external-resources)

## 🏗️ Overview

This deployment provides ArgoCD as a GitOps continuous delivery platform for Kubernetes with the following features:

- **GitOps Platform**: Declarative continuous deployment for Kubernetes applications
- **AWS Integration**: Native ALB ingress via AWS Load Balancer Controller
- **SSL/TLS Support**: Optional custom domain with AWS Certificate Manager (free, auto-renewing)
- **High Availability**: Multi-replica deployment with pod anti-affinity
- **Multiple Access Methods**: Port-forward, HTTP via ALB, or HTTPS via custom domain

## 🏛️ Architecture

### Basic HTTP Setup

```
User → AWS ALB (HTTP) → ArgoCD Server (ClusterIP)
```

### Custom Domain with SSL/TLS

```
User (HTTPS) → DNS Provider (CNAME) → AWS ALB (SSL Termination) → ArgoCD Server (HTTP)
                                          ↑
                                   ACM Certificate
```

**Components:**

1. **ArgoCD**: Deployed via Helm in `argocd` namespace
2. **AWS Load Balancer Controller**: Provisions ALB automatically from Kubernetes Ingress
3. **AWS Certificate Manager (ACM)**: Optional SSL/TLS certificate (free, auto-renewing)
4. **DNS**: CNAME record pointing to ALB (for custom domain setup)

## 📋 Prerequisites

### Required Infrastructure

- EKS cluster deployed (from infrastructure layer)
- VPC with public/private subnets
- kubectl configured with cluster access
- Terraform >= 1.0

### Optional (for Custom Domain)

- Custom domain name (e.g., from Squarespace, Route53, GoDaddy, etc.)
- Access to DNS management for the domain

## ⚙️ Deployment

### Step 1: Configure Variables

Edit `kubernetes/environments/production/terraform.tfvars`:

**Basic HTTP Setup:**
```hcl
# ArgoCD Configuration
argocd_chart_version       = "8.5.10"
argocd_server_insecure     = true
argocd_ingress_enabled     = true
argocd_ingress_class_name  = "alb"

# High Availability (optional - set to 1 for single replica)
argocd_server_replicas      = 2
argocd_repo_server_replicas = 2
argocd_controller_replicas  = 1
argocd_enable_ha            = true

argocd_ingress_annotations = {
  "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
  "alb.ingress.kubernetes.io/target-type" = "ip"
  "alb.ingress.kubernetes.io/group.name"  = "argocd"
  "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}]"
}

# Disable ACM certificate
acm_certificate_enabled = false
```

**Custom Domain with SSL/TLS:**
```hcl
# ArgoCD Configuration
argocd_domain              = "argocd.yourdomain.com"
argocd_chart_version       = "8.5.10"
argocd_server_insecure     = true  # TLS terminates at ALB
argocd_ingress_enabled     = true
argocd_ingress_class_name  = "alb"

# High Availability (optional - set to 1 for single replica)
argocd_server_replicas      = 2
argocd_repo_server_replicas = 2
argocd_controller_replicas  = 1
argocd_enable_ha            = true

argocd_ingress_annotations = {
  "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
  "alb.ingress.kubernetes.io/target-type"      = "ip"
  "alb.ingress.kubernetes.io/group.name"       = "argocd"
  "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
  "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
  "alb.ingress.kubernetes.io/ssl-policy"       = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
}

# Enable ACM certificate (created automatically by Terraform)
acm_certificate_enabled = true
acm_wait_for_validation = false  # Set to true after adding DNS validation records
```

### Step 2: Deploy with Terraform

```bash
cd kubernetes
terraform init -backend-config=environments/production/tfbackend.hcl
terraform plan -var-file=environments/production/terraform.tfvars
terraform apply -var-file=environments/production/terraform.tfvars
```

This will:
1. Deploy AWS Load Balancer Controller
2. Create ACM certificate (if enabled)
3. Deploy ArgoCD with Helm
4. Create ALB via Ingress resource
5. Automatically inject certificate ARN into ingress annotations (if ACM enabled)

### Step 3: Verify Deployment

```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Check ingress and ALB
kubectl get ingress -n argocd

# Check certificate (if using custom domain)
terraform output acm_certificate_status
```

## 🔐 Accessing ArgoCD

### Method 1: Port Forward (Recommended for Development)

**Most secure method** - no internet exposure required.

```bash
# Start port forward
kubectl port-forward svc/argocd-server -n argocd 8080:80

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo

# Access ArgoCD
# URL: http://localhost:8080
# Username: admin
# Password: (from above command)
```

**Advantages:**
- ✅ Secure (no internet exposure)
- ✅ No domain/SSL setup needed
- ✅ Works immediately
- ✅ Recommended for day-to-day access

**Disadvantages:**
- ❌ Requires kubectl access
- ❌ Terminal must stay open
- ❌ Only accessible from your machine

### Method 2: HTTP via ALB

**For external access** or when webhooks are needed.

```bash
# Get ALB URL
kubectl get ingress argocd-server -n argocd \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' && echo

# Access ArgoCD
# URL: http://<ALB-DNS-NAME>
# Username: admin
# Password: (same as Method 1)
```

**Advantages:**
- ✅ Accessible from anywhere
- ✅ No port-forwarding needed
- ✅ Webhooks work (for Git integrations)

**Disadvantages:**
- ⚠️ HTTP only (not encrypted) - not suitable for production with sensitive data
- ⚠️ Internet-facing endpoint

### Method 3: HTTPS via Custom Domain

**For production use** - see Custom Domain Setup section below.

## 🌐 Custom Domain Setup with SSL/TLS

This setup uses AWS Certificate Manager (ACM) for free SSL/TLS certificates with automatic renewal.

### Architecture Flow

1. Terraform creates ACM certificate for your domain
2. You add DNS validation CNAME to your DNS provider
3. ACM validates ownership and issues certificate
4. You add ArgoCD CNAME pointing to ALB
5. ALB terminates SSL/TLS and forwards to ArgoCD pods

### Step 1: Deploy with ACM Enabled

Ensure `acm_certificate_enabled = true` in your `terraform.tfvars` and deploy:

```bash
terraform apply -var-file=environments/production/terraform.tfvars
```

### Step 2: Get DNS Validation Records

After deployment, get the validation records:

```bash
terraform output acm_validation_records
```

Example output:
```json
[
  {
    "domain" = "argocd.yourdomain.com"
    "name" = "_abc123xyz.argocd.yourdomain.com."
    "type" = "CNAME"
    "value" = "_def456uvw.acm-validations.aws."
  }
]
```

### Step 3: Add Validation CNAME to DNS

Add the validation CNAME record to your DNS provider:

**For Squarespace:**
```
Type: CNAME
Host: _abc123xyz.argocd        (remove .yourdomain.com suffix)
Data: _def456uvw.acm-validations.awsm (remove trailing dot)
```

**For Route53/Other DNS:**
```
Type: CNAME
Name: _abc123xyz.argocd.yourdomain.com
Value: _def456uvw.acm-validations.aws.
```

### Step 4: Wait for Certificate Validation

Check validation status:

```bash
terraform output acm_certificate_status
```

- Status will change from "PENDING_VALIDATION" to "ISSUED"
- Usually takes 5-30 minutes
- You can proceed to Step 5 while waiting

### Step 5: Get ALB DNS Name

```bash
kubectl get ingress argocd-server -n argocd \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' && echo
```

Example: `k8s-argocd-argocdse-abc123456.eu-west-1.elb.amazonaws.com`

### Step 6: Add ArgoCD CNAME to DNS

Add a CNAME record pointing your domain to the ALB:

**For Squarespace:**
```
Type: CNAME
Host: argocd
Data: k8s-argocd-argocdse-abc123456.eu-west-1.elb.amazonaws.com
```

**For Route53/Other DNS:**
```
Type: CNAME
Name: argocd.yourdomain.com
Value: k8s-argocd-argocdse-abc123456.eu-west-1.elb.amazonaws.com
```

### Step 7: Access ArgoCD via HTTPS

Wait 5-10 minutes for DNS propagation, then access:

```bash
# Verify DNS resolution
nslookup argocd.yourdomain.com

# Access ArgoCD
# URL: https://argocd.yourdomain.com
# Username: admin
# Password: (from kubectl command)
```

**Features:**
- ✅ Valid SSL certificate (green padlock)
- ✅ Automatic HTTP → HTTPS redirect
- ✅ TLS 1.3 encryption
- ✅ Free certificate with auto-renewal
- ✅ Production-ready

## 🔒 Post-Deployment Security

### 1. Change Admin Password

**Critical:** Change the default password immediately after first login.

```bash
# Via ArgoCD CLI
argocd login <argocd-url> --grpc-web
argocd account update-password

# Or via Web UI
# User Info → Update Password
```

### 2. Delete Initial Secret

After changing the password:

```bash
kubectl delete secret argocd-initial-admin-secret -n argocd
```

### 3. Configure Additional Users

Create additional users with appropriate RBAC permissions instead of sharing the admin account.

### 4. Optional: IP Whitelisting

Restrict ALB access to specific IPs:

```hcl
argocd_ingress_annotations = {
  # ... existing annotations ...
  "alb.ingress.kubernetes.io/inbound-cidrs" = "203.0.113.0/32"  # Your IP
}
```

## 🔧 Troubleshooting

### ArgoCD Pods Not Starting

**Diagnostics:**
```bash
# Check pod status
kubectl get pods -n argocd

# Check pod events
kubectl describe pod -n argocd -l app.kubernetes.io/name=argocd-server

# Check pod logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

**Common Issues:**
- Resource constraints (CPU/memory)
- Image pull errors
- Configuration errors

### ALB Not Created

**Diagnostics:**
```bash
# Check ingress
kubectl get ingress -n argocd
kubectl describe ingress argocd-server -n argocd

# Check ALB controller logs
kubectl logs -n kube-system \
  -l app.kubernetes.io/name=aws-load-balancer-controller --tail=50

# Check events
kubectl get events -n argocd --sort-by='.lastTimestamp'
```

**Common Issues:**
- AWS Load Balancer Controller not running
- IAM permissions missing
- Subnets missing required tags
- Security groups blocking traffic

### Certificate Not Validated

**Symptoms:** Certificate status stuck in "PENDING_VALIDATION"

**Diagnostics:**
```bash
# Check certificate status
terraform output acm_certificate_status

# Check DNS record
dig _abc123.argocd.yourdomain.com CNAME
```

**Solutions:**
1. Verify CNAME record is correct in DNS
2. Ensure no typos in record name or value
3. Wait 30 minutes for DNS propagation
4. Certificate must be in same region as ALB (eu-west-1)

### Cannot Access via Custom Domain

**Diagnostics:**
```bash
# Check DNS resolution
nslookup argocd.yourdomain.com

# Check certificate status
terraform output acm_certificate_status

# Check ALB is healthy
kubectl get ingress argocd-server -n argocd -o yaml
```

**Solutions:**
1. Ensure DNS resolves to ALB DNS name
2. Verify certificate status is "ISSUED"
3. Wait for DNS propagation (5-30 minutes)
4. Clear browser cache / try incognito mode
5. Use `https://` not `http://`

### ArgoCD CLI Connection Issues

**Problem:** `argocd login` fails or has SSL/TLS errors

**Solution:** Use `--grpc-web` flag:
```bash
argocd login argocd.yourdomain.com --grpc-web
```

ArgoCD uses gRPC which can have issues with some ALBs. The `--grpc-web` flag uses HTTP/1.1 instead.

## 📝 Configuration Reference

### ArgoCD Variables

| Variable                     | Description              | Default        | Example                 |
| ---------------------------- | ------------------------ | -------------- | ----------------------- |
| `argocd_chart_version`       | Helm chart version       | `8.5.10`       | `8.5.10`                |
| `argocd_domain`              | Custom domain name       | `argocd.local` | `argocd.yourdomain.com` |
| `argocd_server_insecure`     | Disable TLS at pod level | `true`         | `true` (TLS at ALB)     |
| `argocd_server_service_type` | Service type             | `ClusterIP`    | `ClusterIP`             |
| `argocd_ingress_enabled`     | Enable ingress           | `true`         | `true`                  |
| `argocd_ingress_class_name`  | Ingress class            | `alb`          | `alb`                   |

### High Availability Variables

| Variable                        | Description                            | Default | Example |
| ------------------------------- | -------------------------------------- | ------- | ------- |
| `argocd_server_replicas`        | Number of ArgoCD server replicas       | `2`     | `2`     |
| `argocd_repo_server_replicas`   | Number of repo server replicas         | `2`     | `2`     |
| `argocd_controller_replicas`    | Number of controller replicas          | `1`     | `1`     |
| `argocd_enable_ha`              | Enable HA features (anti-affinity/PDB) | `true`  | `true`  |

### ACM Certificate Variables

| Variable                        | Description            | Default | Example                               |
| ------------------------------- | ---------------------- | ------- | ------------------------------------- |
| `acm_certificate_enabled`       | Enable ACM certificate | `false` | `true`                                |
| `acm_wait_for_validation`       | Wait for validation    | `false` | `false` (initial), `true` (after DNS) |
| `acm_subject_alternative_names` | Additional domains     | `[]`    | `["*.yourdomain.com"]`                |

### Ingress Annotations

**Basic HTTP:**
```hcl
argocd_ingress_annotations = {
  "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
  "alb.ingress.kubernetes.io/target-type" = "ip"
  "alb.ingress.kubernetes.io/group.name"  = "argocd"
  "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}]"
}
```

**HTTPS with ACM:**
```hcl
argocd_ingress_annotations = {
  "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
  "alb.ingress.kubernetes.io/target-type"      = "ip"
  "alb.ingress.kubernetes.io/group.name"       = "argocd"
  "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
  "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
  "alb.ingress.kubernetes.io/ssl-policy"       = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
  # Certificate ARN is automatically injected by Terraform when ACM is enabled
}
```

### Terraform Outputs

```bash
# ArgoCD namespace
terraform output argocd_namespace

# ArgoCD URL
terraform output argocd_server_url

# ALB Controller IAM role
terraform output aws_load_balancer_controller_role_arn

# ACM certificate ARN (if enabled)
terraform output acm_certificate_arn

# ACM certificate status
terraform output acm_certificate_status

# DNS validation records
terraform output acm_validation_records
```

### Common Commands

```bash
# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo

# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:80

# Get ALB URL
kubectl get ingress argocd-server -n argocd \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' && echo

# Check ArgoCD status
kubectl get all -n argocd

# ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server --tail=100

# Restart ArgoCD
kubectl rollout restart deployment argocd-server -n argocd

# Add EKS cluster to ArgoCD
argocd cluster add $(kubectl config current-context)
```

## 💰 Cost

- **ACM Certificate**: $0/month (free for ALB use)
- **ALB**: ~$18-25/month (existing infrastructure cost)
- **Domain**: Your existing domain cost
- **DNS Records**: Included with domain

**Total Additional Cost for SSL/TLS: $0**

## 🔄 Maintenance

### Certificate Renewal

- ACM certificates **automatically renew** before expiration
- No manual intervention required
- AWS handles renewal using the validation CNAME record
- **Important:** Do not delete the validation CNAME record

### Updating ArgoCD

```bash
# Update version in terraform.tfvars
argocd_chart_version = "8.6.0"

# Apply changes
terraform apply -var-file=environments/production/terraform.tfvars
```

### Backup ArgoCD Configuration

```bash
# Export applications
kubectl get applications -n argocd -o yaml > argocd-apps-backup.yaml

# Export projects
kubectl get appprojects -n argocd -o yaml > argocd-projects-backup.yaml
```

##  External Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [AWS Certificate Manager](https://docs.aws.amazon.com/acm/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [ALB TLS Policies](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies)

---

**Built with ❤️ for Cloud Solutions Inc.**
