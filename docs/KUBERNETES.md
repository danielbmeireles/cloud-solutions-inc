# ☸️ Kubernetes Infrastructure <!-- omit in toc -->

Production-ready Kubernetes infrastructure for AWS EKS with ArgoCD and AWS Load Balancer Controller.

## 📑 Table of Contents <!-- omit in toc -->

- [🎯 Features](#-features)
- [📚 Documentation](#-documentation)
- [� Prerequisites](#-prerequisites)
- [⚙️ Deployment](#️-deployment)
- [🔌 AWS Load Balancer Controller](#-aws-load-balancer-controller)
- [🚀 ArgoCD](#-argocd)
- [🔧 Helper Scripts](#-helper-scripts)
- [🔧 Troubleshooting](#-troubleshooting)
- [📝 Outputs](#-outputs)
- [📊 Monitoring](#-monitoring)
- [📚 Related Documentation](#-related-documentation)
- [🧹 Cleanup](#-cleanup)
- [💡 Practical Examples](#-practical-examples)

## 🎯 Features

- ✅ **AWS Load Balancer Controller** - Automatic ALB/NLB provisioning
- ✅ **ArgoCD** - GitOps continuous delivery
- ✅ **AWS Certificate Manager (ACM)** - Free SSL/TLS certificates with automatic renewal
- ✅ **Automated Certificate Management** - ACM certificates created via Terraform
- ✅ **High Availability** - Multi-AZ deployment with pod anti-affinity
- ✅ **Infrastructure as Code** - 100% Terraform managed

## 📚 Documentation

For comprehensive documentation, see the main docs directory:

- **[ArgoCD Deployment Guide](ARGOCD.md)** - Complete guide for deploying and accessing ArgoCD with optional custom domain and SSL/TLS via AWS ACM
- **[Architecture](ARCHITECTURE.md)** - Infrastructure components and design decisions
- **[EKS Documentation](EKS.md)** - EKS deployment, configuration, and operations
- **[Terraform Reference](TERRAFORM.md)** - Terraform module and variable reference

## 📋 Prerequisites

1. EKS cluster must be deployed (from root terraform configuration)
2. kubectl configured to access the cluster
3. Terraform >= 1.0
4. Helm >= 3.0

## ⚙️ Deployment

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

## 🔌 AWS Load Balancer Controller

The AWS Load Balancer Controller is automatically installed when `install_aws_load_balancer_controller = true`.

### Features

- Automatic ALB/NLB provisioning for Kubernetes ingress resources
- Native AWS integration for better performance
- Support for advanced ALB features (target groups, listeners, etc.)

### ⚙️ Configuration

Edit `environments/production/terraform.tfvars`:

```hcl
install_aws_load_balancer_controller       = true
aws_load_balancer_controller_chart_version = "1.14.0"
```

## 🚀 ArgoCD

ArgoCD is deployed as a Helm release for GitOps-based application delivery.

### 🔐 Accessing ArgoCD

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

### ⚙️ Configuration

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

### 🔒 SSL/TLS Configuration with AWS Certificate Manager

For production use with custom domains, see the **[ArgoCD Deployment Guide](ARGOCD.md#-custom-domain-setup-with-ssltls)** for complete SSL/TLS setup instructions.

## 🔧 Helper Scripts

### patch-argocd-ingress.sh

Removes the hostname restriction from the ArgoCD ingress, allowing access via the ALB URL directly.

```bash
./scripts/patch-argocd-ingress.sh
```

**When to use:**
- After initial deployment
- After any Terraform apply that updates the ArgoCD ingress
- When the ALB returns 404 errors

## 🔧 Troubleshooting

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

If nodes are resource-constrained, scale up to larger instance types.

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

## 📝 Outputs

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

## 📊 Monitoring

### Kubernetes Resource Monitoring

Monitor the Kubernetes layer components:

**ArgoCD Monitoring:**
```bash
# Check ArgoCD application health
kubectl get applications -n argocd

# Monitor ArgoCD pods
kubectl top pods -n argocd

# Check ArgoCD metrics
kubectl port-forward svc/argocd-metrics -n argocd 8082:8082
# Visit: http://localhost:8082/metrics
```

**AWS Load Balancer Controller Monitoring:**
```bash
# Check controller pods
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# View controller logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller --tail=100

# Monitor ALB creation
kubectl get ingress --all-namespaces -w
```

### CloudWatch Integration

Kubernetes layer metrics are collected via CloudWatch:

**Key Metrics:**
- Helm release status
- Ingress controller performance
- ALB target health
- Certificate validation status
- Pod resource utilization

**Access Metrics:**
```bash
# Via Terraform outputs
terraform output | grep -i metric

# Via AWS CLI
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --dimensions Name=LoadBalancer,Value=<alb-name> \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

### Monitoring Best Practices

1. **Set Up Alerts:**
   - ArgoCD sync failures
   - Ingress controller errors
   - ALB unhealthy targets
   - Certificate expiration warnings

2. **Regular Health Checks:**
   ```bash
   # Daily health check script
   kubectl get pods --all-namespaces | grep -v Running
   kubectl get ingress --all-namespaces
   terraform output acm_certificate_status
   ```

3. **Log Aggregation:**
   - Configure ArgoCD to send logs to CloudWatch
   - Enable ALB access logs to S3
   - Set appropriate log retention policies

### Related Monitoring Documentation

- [Architecture Monitoring](ARCHITECTURE.md#monitoring-and-logging) - Infrastructure-wide monitoring
- [EKS Monitoring](EKS.md#-monitoring-and-operations) - Cluster-level monitoring

## 🧹 Cleanup

To destroy all resources:

```bash
terraform destroy -var-file=environments/production/terraform.tfvars
```

**Warning**: This will delete all Kubernetes resources managed by this configuration, including ingress resources and their associated ALBs.

## 💡 Practical Examples

### Example 1: Complete ArgoCD Application Deployment with GitOps

Deploy a complete application using ArgoCD's GitOps workflow:

**1. Create Git repository structure:**

```bash
# Your Git repository structure
my-app-repo/
├── apps/
│   └── production/
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── ingress.yaml
│       └── kustomization.yaml
└── argocd/
    └── application.yaml
```

**2. Define Kubernetes manifests (apps/production/deployment.yaml):**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-web-app
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-web-app
  template:
    metadata:
      labels:
        app: my-web-app
    spec:
      containers:
      - name: web
        image: my-docker-registry/my-web-app:v1.0.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

**3. Create service and ingress (apps/production/service.yaml):**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-web-app
  namespace: production
spec:
  selector:
    app: my-web-app
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-web-app
  namespace: production
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:eu-west-1:123456789012:certificate/xxxxx
    alb.ingress.kubernetes.io/ssl-redirect: '443'
spec:
  ingressClassName: alb
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-web-app
            port:
              number: 80
```

**4. Create ArgoCD Application manifest (argocd/application.yaml):**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-web-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/myorg/my-app-repo.git
    targetRevision: main
    path: apps/production
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
    - CreateNamespace=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
```

**5. Deploy using ArgoCD:**

```bash
# Apply the ArgoCD Application
kubectl apply -f argocd/application.yaml

# Watch the sync progress
kubectl get applications -n argocd -w

# Check application details
kubectl describe application my-web-app -n argocd

# Access ArgoCD UI to visualize deployment
kubectl port-forward svc/argocd-server -n argocd 8080:80
# Visit: http://localhost:8080
```

**6. Verify deployment:**

```bash
# Check pods
kubectl get pods -n production

# Check service
kubectl get svc -n production

# Check ingress and get ALB URL
kubectl get ingress -n production
ALB_URL=$(kubectl get ingress my-web-app -n production -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Application URL: https://${ALB_URL}"

# Test the application
curl https://myapp.example.com
```

### Example 2: Multi-Environment Deployment with ArgoCD

Manage multiple environments (dev, staging, production) with ArgoCD:

**1. Git repository structure:**

```bash
my-app-repo/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
├── overlays/
│   ├── development/
│   │   ├── kustomization.yaml
│   │   └── patches.yaml
│   ├── staging/
│   │   ├── kustomization.yaml
│   │   └── patches.yaml
│   └── production/
│       ├── kustomization.yaml
│       └── patches.yaml
└── argocd/
    ├── app-dev.yaml
    ├── app-staging.yaml
    └── app-prod.yaml
```

**2. Base configuration (base/kustomization.yaml):**

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
commonLabels:
  app: my-web-app
```

**3. Environment-specific overlay (overlays/production/kustomization.yaml):**

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: production
bases:
  - ../../base
patchesStrategicMerge:
  - patches.yaml
replicas:
  - name: my-web-app
    count: 5
images:
  - name: my-docker-registry/my-web-app
    newTag: v1.2.3
```

**4. Environment patches (overlays/production/patches.yaml):**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-web-app
spec:
  template:
    spec:
      containers:
      - name: web
        resources:
          requests:
            cpu: 500m
            memory: 512Mi
          limits:
            cpu: 1000m
            memory: 1Gi
        env:
        - name: ENVIRONMENT
          value: production
        - name: LOG_LEVEL
          value: info
```

**5. Create ArgoCD Application for each environment:**

```bash
# Deploy all environments
kubectl apply -f argocd/app-dev.yaml
kubectl apply -f argocd/app-staging.yaml
kubectl apply -f argocd/app-prod.yaml

# View all applications
kubectl get applications -n argocd

# Check sync status
argocd app list
argocd app get my-web-app-prod
```

### Example 3: ACM Certificate Management and Custom Domain Setup

Complete workflow for setting up a custom domain with SSL/TLS:

**1. Deploy ACM certificate via Terraform:**

```hcl
# kubernetes/environments/production/terraform.tfvars
argocd_domain = "argocd.example.com"

# Enable ACM certificate
acm_certificate_enabled = true
acm_wait_for_validation = false  # Set to true after DNS validation
```

```bash
cd kubernetes
terraform apply -var-file=environments/production/terraform.tfvars
```

**2. Get validation records:**

```bash
# Get DNS validation records
terraform output acm_validation_records

# Output example:
# [
#   {
#     "name": "_abc123.argocd.example.com.",
#     "type": "CNAME",
#     "value": "_xyz456.acm-validations.aws."
#   }
# ]
```

**3. Add DNS validation CNAME to your DNS provider:**

For Squarespace, GoDaddy, Route53, or any DNS provider:
```
Type: CNAME
Host: _abc123.argocd.example.com
Value: _xyz456.acm-validations.aws.
TTL: 3600
```

**4. Wait for validation and update terraform:**

```bash
# Check certificate status (wait 5-30 minutes)
terraform output acm_certificate_status
# Should show: ISSUED

# Once validated, update terraform to wait for validation
# kubernetes/environments/production/terraform.tfvars
acm_wait_for_validation = true

# Re-apply to inject certificate into ingress
terraform apply -var-file=environments/production/terraform.tfvars
```

**5. Add CNAME for ArgoCD domain:**

```
Type: CNAME
Host: argocd
Value: k8s-argocd-abcd1234-567890123.eu-west-1.elb.amazonaws.com
TTL: 3600
```

Get ALB DNS name:
```bash
kubectl get ingress argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

**6. Verify SSL/TLS setup:**

```bash
# Test DNS resolution
nslookup argocd.example.com

# Test SSL certificate
curl -vI https://argocd.example.com

# Check certificate details
openssl s_client -connect argocd.example.com:443 -servername argocd.example.com < /dev/null 2>/dev/null | openssl x509 -noout -text | grep -A 2 "Subject:"
```

### Example 4: Helm Chart Customization for AWS Load Balancer Controller

Customize the AWS Load Balancer Controller deployment:

**1. View current Helm values:**

```bash
# Get deployed values
helm get values aws-load-balancer-controller -n kube-system

# Get all available values from chart
helm show values kubernetes/charts/aws-load-balancer-controller
```

**2. Customize via Terraform:**

```hcl
# kubernetes/main.tf - Add custom values
module "aws_load_balancer_controller" {
  source = "./charts/aws-load-balancer-controller"

  # ... existing config ...

  additional_helm_values = {
    "replicaCount" = 2
    "resources" = {
      "requests" = {
        "cpu"    = "100m"
        "memory" = "128Mi"
      }
      "limits" = {
        "cpu"    = "200m"
        "memory" = "256Mi"
      }
    }
    "podDisruptionBudget" = {
      "maxUnavailable" = 1
    }
    "enableShield"      = false
    "enableWaf"         = false
    "enableWafv2"       = true
  }
}
```

**3. Update deployment:**

```bash
terraform apply -var-file=environments/production/terraform.tfvars

# Verify changes
kubectl get deployment aws-load-balancer-controller -n kube-system -o yaml
```

### Example 5: Troubleshooting ALB Creation Issues

Debug common ALB provisioning problems:

**Problem: Ingress created but ALB not provisioning**

```bash
# Step 1: Check ingress status
kubectl get ingress -n production
kubectl describe ingress my-app-ingress -n production

# Look for events like:
# Warning  FailedBuildModel  Subnets not found
```

**Step 2: Verify AWS Load Balancer Controller is running:**

```bash
# Check controller pods
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Check controller logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller --tail=100 -f

# Look for errors like:
# "failed to build LoadBalancer configuration due to unable to resolve at least 2 subnets"
```

**Step 3: Verify IAM role and IRSA:**

```bash
# Check ServiceAccount has IAM role annotation
kubectl get sa aws-load-balancer-controller -n kube-system -o yaml | grep role-arn

# Should show:
# eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/cloud-solutions-production-alb-controller

# Verify IAM role exists
terraform output -raw aws_load_balancer_controller_role_arn
```

**Step 4: Check subnet tags:**

```bash
# Subnets must have specific tags for ALB controller
# For public subnets (internet-facing ALBs):
terraform output public_subnet_ids

aws ec2 describe-subnets --subnet-ids subnet-xxx --query 'Subnets[0].Tags'
# Should include:
# {
#   "Key": "kubernetes.io/role/elb",
#   "Value": "1"
# }

# For private subnets (internal ALBs):
# {
#   "Key": "kubernetes.io/role/internal-elb",
#   "Value": "1"
# }
```

**Step 5: Fix missing tags:**

```hcl
# In VPC module or main.tf
resource "aws_subnet" "public" {
  # ... existing config ...

  tags = merge(
    local.common_tags,
    {
      "kubernetes.io/role/elb"                    = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}
```

**Step 6: Verify security groups:**

```bash
# Check if security group allows traffic
terraform output alb_security_group_id

aws ec2 describe-security-groups --group-ids sg-xxxxx
```

### Example 6: Implementing Progressive Delivery with ArgoCD Rollouts

Set up blue-green and canary deployments:

**1. Install Argo Rollouts:**

```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

# Install kubectl plugin
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
chmod +x kubectl-argo-rollouts-linux-amd64
sudo mv kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
```

**2. Create canary rollout:**

```yaml
# rollout-canary.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: my-web-app
  namespace: production
spec:
  replicas: 5
  strategy:
    canary:
      steps:
      - setWeight: 20
      - pause: {duration: 5m}
      - setWeight: 40
      - pause: {duration: 5m}
      - setWeight: 60
      - pause: {duration: 5m}
      - setWeight: 80
      - pause: {duration: 5m}
  selector:
    matchLabels:
      app: my-web-app
  template:
    metadata:
      labels:
        app: my-web-app
    spec:
      containers:
      - name: web
        image: my-docker-registry/my-web-app:v2.0.0
        ports:
        - containerPort: 8080
```

**3. Deploy and monitor rollout:**

```bash
kubectl apply -f rollout-canary.yaml

# Watch rollout progress
kubectl argo rollouts get rollout my-web-app -n production --watch

# Promote manually if auto-promotion is disabled
kubectl argo rollouts promote my-web-app -n production

# Abort rollout if issues detected
kubectl argo rollouts abort my-web-app -n production
```

### Example 7: Monitoring and Alerting Integration

Set up comprehensive monitoring for the Kubernetes layer:

**1. Deploy Prometheus and Grafana:**

```bash
# Add Helm repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
```

**2. Create ServiceMonitor for ArgoCD:**

```yaml
# argocd-servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: argocd-metrics
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-metrics
  endpoints:
  - port: metrics
```

**3. Create alerts for ArgoCD sync failures:**

```yaml
# argocd-alerts.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: argocd-alerts
  namespace: monitoring
spec:
  groups:
  - name: argocd
    interval: 30s
    rules:
    - alert: ArgoCDSyncFailed
      expr: argocd_app_sync_total{phase="Failed"} > 0
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "ArgoCD sync failed for {{ $labels.name }}"
        description: "Application {{ $labels.name }} has failed to sync for the last 5 minutes"

    - alert: ArgoCDAppUnhealthy
      expr: argocd_app_health_status{health_status!="Healthy"} == 1
      for: 10m
      labels:
        severity: critical
      annotations:
        summary: "ArgoCD application unhealthy: {{ $labels.name }}"
        description: "Application {{ $labels.name }} health status is {{ $labels.health_status }}"
```

**4. Access Grafana dashboard:**

```bash
# Port forward Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80

# Get admin password
kubectl get secret -n monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode

# Visit: http://localhost:3000
# Username: admin
# Import ArgoCD dashboard ID: 14584
```

---

**Built with ❤️ for Cloud Solutions Inc.**
