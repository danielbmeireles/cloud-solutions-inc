# ☸️ EKS Configuration Guide <!-- omit in toc -->

This document cover the most important aspects related to Amazon EKS configuration, deployment, and management.

## 📑 Table of Contents <!-- omit in toc -->

- [⚙️ Configuration Options](#️-configuration-options)
- [🔌 Accessing the EKS Cluster](#-accessing-the-eks-cluster)
- [🌐 Exposing Applications with Load Balancers](#-exposing-applications-with-load-balancers)
- [📊 Monitoring and Operations](#-monitoring-and-operations)
- [🧹 Cleanup](#-cleanup)
- [🔧 Troubleshooting](#-troubleshooting)
- [✨ Best Practices](#-best-practices)

## ⚙️ Configuration Options

### 🎛️ EKS Cluster Configuration

```hcl
kubernetes_version = "1.34"  # Supported: 1.31, 1.32, 1.33, 1.34

# Restrict API server access (recommended for production)
cluster_endpoint_public_access_cidrs = ["YOUR_IP/32"]

# Control plane logging
cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
```

### 🖥️ Node Group Configuration

```hcl
# Instance types (can specify multiple for mixed instances)
node_instance_types = ["t3.medium"]  # Options: t3.small, t3.medium, t3.large, m5.large, etc.

# Capacity type
capacity_type = "ON_DEMAND"  # ON_DEMAND or SPOT (SPOT is ~70% cheaper)

# Disk size
node_disk_size = 20  # Size in GiB

# Scaling configuration
desired_size = 2  # Initial number of nodes
min_size     = 1  # Minimum nodes
max_size     = 4  # Maximum nodes
```

### 💰 Cost Optimization with Spot Instances

```hcl
capacity_type       = "SPOT"
node_instance_types = ["t3.medium", "t3a.medium", "t2.medium"]  # Multiple types for better availability
```

### 🌍 Region and AZ Configuration

```hcl
aws_region         = "eu-west-1"
availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
```

## 🔌 Accessing the EKS Cluster

### 🔧 Configure kubectl

```bash
# Using AWS CLI
aws eks update-kubeconfig --region eu-west-1 --name cloud-solutions-production-cluster

# Or using Terraform output
terraform output -raw configure_kubectl | bash
```

### ✅ Verify Access

```bash
kubectl cluster-info
kubectl get nodes
kubectl get all --all-namespaces
```

### 🔐 Sensitive Outputs

```bash
# View all outputs including sensitive ones
terraform output -json

# Get specific sensitive output
terraform output -raw eks_cluster_arn
terraform output -raw eks_oidc_provider_arn
terraform output -raw kubeconfig
```

### 🔑 Using IRSA (IAM Roles for Service Accounts)

Pre-configured IAM roles are available for:

1. **AWS Load Balancer Controller**:
   ```bash
   terraform output -raw aws_load_balancer_controller_role_arn
   ```

2. **EBS CSI Driver**:
   ```bash
   terraform output -raw ebs_csi_driver_role_arn
   ```

Example: Create a Service Account with IAM role:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME
```

## 🌐 Exposing Applications with Load Balancers

EKS applications can be exposed to the internet using the AWS Load Balancer Controller, which automatically creates and manages AWS Application Load Balancers (ALB) or Network Load Balancers (NLB).

### 📦 Install AWS Load Balancer Controller

The Terraform configuration has already created the necessary IAM role. Now install the controller:

```bash
# Get required values from Terraform
CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
REGION=eu-west-1  # or your region
VPC_ID=$(terraform output -raw vpc_id)
ROLE_ARN=$(terraform output -raw aws_load_balancer_controller_role_arn)

# Create ServiceAccount with IAM role
kubectl apply -f - <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: ${ROLE_ARN}
YAML

# Add Helm repository
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install AWS Load Balancer Controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=${CLUSTER_NAME} \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=${REGION} \
  --set vpcId=${VPC_ID}

# Verify installation
kubectl get deployment -n kube-system aws-load-balancer-controller
```

### 🚀 Deploy Sample Application with ALB

```bash
# Deploy sample nginx app with Ingress
kubectl apply -f manifests/sample-app-with-ingress.yaml

# Watch for ALB to be provisioned
kubectl get ingress -n sample-app nginx-ingress -w

# Get the ALB DNS name
kubectl get ingress -n sample-app nginx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

### 🔗 Access Your Application

Once the Ingress shows an ADDRESS, you can access your application:

```bash
# Get the URL
ALB_URL=$(kubectl get ingress -n sample-app nginx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Application URL: http://${ALB_URL}"

# Test it
curl http://${ALB_URL}
```

### 📡 Exposing Your Own Applications

#### 🔀 Option 1: Using Ingress (Recommended for HTTP/HTTPS)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    # For HTTPS:
    # alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    # alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:region:account:certificate/xxxxx
spec:
  ingressClassName: alb
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```

#### ⚖️ Option 2: Using LoadBalancer Service (Creates NLB)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "external"
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
spec:
  type: LoadBalancer
  selector:
    app: my-app
  ports:
    - port: 80
      targetPort: 8080
```

### 🔒 HTTPS/SSL Configuration

To enable HTTPS, you need an ACM certificate:

1. **Request a certificate in ACM**:
   ```bash
   aws acm request-certificate \
     --domain-name example.com \
     --validation-method DNS \
     --region eu-west-1
   ```

2. **Add to your Ingress**:
   ```yaml
   annotations:
     alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
     alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:eu-west-1:123456789012:certificate/xxxxx
     alb.ingress.kubernetes.io/ssl-redirect: '443'  # Redirect HTTP to HTTPS
   ```

## 📊 Monitoring and Operations

### 📈 CloudWatch Dashboard

Access the dashboard via AWS Console or CLI:

```bash
aws cloudwatch get-dashboard --dashboard-name cloud-solutions-production-dashboard
```

### 📝 View Logs

```bash
# EKS control plane logs
aws logs tail /aws/eks/cloud-solutions-production/cluster --follow

# View specific log types
aws logs tail /aws/eks/cloud-solutions-production-cluster/kube-apiserver --follow
```

### 📏 Scaling Nodes Manually

```bash
# Scale the node group
aws eks update-nodegroup-config \
  --cluster-name cloud-solutions-production-cluster \
  --nodegroup-name cloud-solutions-production-node-group \
  --scaling-config desiredSize=3
```

### 🔄 Cluster Autoscaler

To enable automatic pod-based scaling, install the Cluster Autoscaler:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```

### 🧪 Deploy Sample Application (Optional)

```bash
# Create a simple nginx deployment
kubectl create deployment nginx --image=nginx:latest
kubectl expose deployment nginx --port=80 --type=LoadBalancer
kubectl get services
```

## 🧹 Cleanup

To destroy all Kubernetes resources:

```bash
# First, delete all Kubernetes resources that created AWS resources
kubectl delete svc --all
kubectl delete pvc --all

# Then, destroy everything inside the namespace
kubectl api-resources --verbs=list --namespaced -o name | \
  xargs -n 1 kubectl delete --all -n <namespace>
```

## 🔧 Troubleshooting

### ⚠️ Common Issues

#### 🚫 Unable to connect to cluster

```bash
# Check AWS credentials
aws sts get-caller-identity

# Update kubeconfig
aws eks update-kubeconfig --region <region> --name <cluster-name>

# Verify kubectl context
kubectl config current-context
```

#### 🖥️ Nodes not joining cluster

```bash
# Check node group status
aws eks describe-nodegroup \
  --cluster-name <cluster-name> \
  --nodegroup-name <nodegroup-name>

# Check CloudWatch logs
aws logs tail /aws/eks/<cluster-name>/cluster --follow
```

#### 📦 Pods not scheduling

```bash
# Check node resources
kubectl describe nodes

# Check pod events
kubectl describe pod <pod-name>

# Check cluster autoscaler logs
kubectl logs -n kube-system deployment/cluster-autoscaler
```

#### 🌐 ALB not creating

```bash
# Check Load Balancer Controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Check Ingress events
kubectl describe ingress <ingress-name>

# Verify IAM role
aws iam get-role --role-name <load-balancer-controller-role>
```

## ✨ Best Practices

### 📊 Resource Quotas

Set resource quotas for namespaces:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
```

### 🛡️ Pod Security

Use Pod Security Standards:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

### 🌐 Network Policies

Implement network policies to control pod-to-pod traffic:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### 🎯 Resource Requests and Limits

Always set resource requests and limits:

```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

---

**Built with ❤️ for Cloud Solutions Inc.**
