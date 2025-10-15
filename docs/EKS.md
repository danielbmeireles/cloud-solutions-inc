# ☸️ EKS Configuration Guide <!-- omit in toc -->

This document covers the most important aspects related to Amazon EKS configuration, deployment, and management.

## 📑 Table of Contents <!-- omit in toc -->

- [⚙️ Configuration Options](#️-configuration-options)
- [🔌 Accessing the EKS Cluster](#-accessing-the-eks-cluster)
- [🌐 Exposing Applications with Load Balancers](#-exposing-applications-with-load-balancers)
- [📊 Monitoring and Operations](#-monitoring-and-operations)
- [🧹 Cleanup](#-cleanup)
- [🔧 Troubleshooting](#-troubleshooting)
- [✨ Best Practices](#-best-practices)
- [💡 Practical Examples](#-practical-examples)

## ⚙️ Configuration Options

### EKS Cluster Configuration

```hcl
kubernetes_version = "1.34"  # Supported: 1.31, 1.32, 1.33, 1.34

# Restrict API server access (recommended for production)
cluster_endpoint_public_access_cidrs = ["YOUR_IP/32"]

# Control plane logging
cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
```

### Node Group Configuration

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

### Cost Optimization with Spot Instances

```hcl
capacity_type       = "SPOT"
node_instance_types = ["t3.medium", "t3a.medium", "t2.medium"]  # Multiple types for better availability
```

### Region and AZ Configuration

```hcl
aws_region         = "eu-west-1"
availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
```

## 🔌 Accessing the EKS Cluster

### Granting SSO User Access to EKS Cluster

If you're using AWS IAM Identity Center (SSO), you'll need to grant access to the cluster after it's created. SSO roles have a special ARN format that includes the region and session information.

#### Step 1: Get Your SSO Role ARN

First, determine your SSO role ARN. When you assume an SSO role, it has this format:
```
arn:aws:iam::ACCOUNT_ID:role/aws-reserved/sso.amazonaws.com/REGION/AWSReservedSSO_PermissionSetName_UniqueID
```

You can find this by running:
```bash
aws sts get-caller-identity
```

#### Step 2: Create Access Entry

Use the `eks-access.sh` script provided in the `scripts/` directory to create the access entry:

```bash
# Set the required environment variables
export EKS_CLUSTER_NAME="cloud-solutions-production-cluster"
export EKS_SSO_ROLE_ARN="arn:aws:iam::123456789012:role/aws-reserved/sso.amazonaws.com/eu-west-1/AWSReservedSSO_AdminAccess_xxxxx"
export AWS_REGION="eu-west-1"

# Run the script
./scripts/eks-access.sh
```

#### Step 3: Verify Access

```bash
# Test access
kubectl get nodes
kubectl get all --all-namespaces
```

#### Alternative: Using AWS Console

You can also grant access via the AWS Console:
1. Navigate to EKS → Your Cluster → **Access** tab
2. Click **Create access entry**
3. Select your SSO role from the IAM principal dropdown
4. Choose **AmazonEKSClusterAdminPolicy** or another appropriate policy
5. Click **Add**

#### Important Notes

- **SSO roles cannot be managed in Terraform** directly due to their session-based nature
- Each SSO user who needs cluster access must have their session role added
- For production environments, consider using **IAM roles** that SSO users can assume, rather than SSO session roles directly
- The access entry only needs to be created once per IAM principal

### Using IRSA (IAM Roles for Service Accounts)

Pre-configured IAM roles are available for EKS add-ons in the infrastructure layer:

1. **EBS CSI Driver**:
   ```bash
   terraform output -raw ebs_csi_driver_role_arn
   ```

2. **EFS CSI Driver**:
   ```bash
   terraform output -raw efs_csi_driver_role_arn
   ```

For Kubernetes resources (ArgoCD, Load Balancer Controller), IAM roles are managed in the `kubernetes/` layer:

```bash
cd kubernetes
terraform output -raw aws_load_balancer_controller_role_arn
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

### AWS Load Balancer Controller

**Automatic Installation**

The AWS Load Balancer Controller is automatically installed by the `kubernetes-deploy` pipeline. It uses a custom Helm chart wrapper for better maintainability.

**Architecture**:
```
Infrastructure Layer (terraform-deploy)
└─ OIDC Provider for IRSA

Kubernetes Layer (kubernetes-deploy)
├─ IAM Role (IRSA) ← Created by Terraform
└─ Custom Helm Chart
   ├─ ServiceAccount ← Managed by Helm template
   └─ AWS LB Controller ← Official chart as dependency
```

**Verify Installation**:
```bash
# Check if the controller is running
kubectl get deployment -n kube-system aws-load-balancer-controller-controller

# Check ServiceAccount
kubectl get sa -n kube-system aws-load-balancer-controller -o yaml

# Check controller logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

**Configuration**:

The controller is configured in `kubernetes/environments/{env}/terraform.tfvars`:

```hcl
# Enable/disable installation
install_aws_load_balancer_controller = true

# Chart version
aws_load_balancer_controller_chart_version = "1.14.0"
```

**For more details**, see:
- [Custom Helm Chart README](../kubernetes/charts/aws-load-balancer-controller/README.md)
- [Kubernetes Layer README](../kubernetes/README.md)

### 🚀 Deploy Sample Application with ALB

Deploy the sample NGINX application with an Application Load Balancer:

```bash
# Deploy the unified manifest (includes namespace, deployment, service, and ingress)
kubectl apply -f manifests/complete-deployment.yaml

# Watch for ALB to be provisioned (takes 2-3 minutes)
kubectl get ingress -n sample-app nginx-ingress -w

# Get the ALB DNS name
kubectl get ingress -n sample-app nginx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

For detailed instructions, see `manifests/instructions.txt`.

### Access Your Application

Once the Ingress shows an ADDRESS, you can access your application:

```bash
# Get the URL
ALB_URL=$(kubectl get ingress -n sample-app nginx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Application URL: http://${ALB_URL}"

# Test it
curl http://${ALB_URL}
```

### Exposing Your Own Applications

#### Option 1: Using Ingress (Recommended for HTTP/HTTPS)

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

#### Option 2: Using LoadBalancer Service (Creates NLB)

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

### HTTPS/SSL Configuration

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

### CloudWatch Dashboard

Access the dashboard via AWS Console or CLI:

```bash
aws cloudwatch get-dashboard --dashboard-name cloud-solutions-production-dashboard
```

### View Logs

```bash
# EKS control plane logs
aws logs tail /aws/eks/cloud-solutions-production/cluster --follow

# View specific log types
aws logs tail /aws/eks/cloud-solutions-production-cluster/kube-apiserver --follow
```

### Scaling Nodes Manually

```bash
# Scale the node group
aws eks update-nodegroup-config \
  --cluster-name cloud-solutions-production-cluster \
  --nodegroup-name cloud-solutions-production-node-group \
  --scaling-config desiredSize=3
```

### Cluster Autoscaler

To enable automatic pod-based scaling, install the Cluster Autoscaler:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```

### Deploy Sample Application (Optional)

```bash
# Create a simple nginx deployment
kubectl create deployment nginx --image=nginx:latest
kubectl expose deployment nginx --port=80 --type=LoadBalancer
kubectl get services
```

## 🧹 Cleanup

To destroy all resources in the correct order:

```bash
# 1. Delete Kubernetes resources first (from kubernetes layer)
cd kubernetes
terraform destroy

# 2. Delete all Kubernetes-created AWS resources
kubectl delete ingress --all --all-namespaces
kubectl delete svc --all --all-namespaces
kubectl delete pvc --all --all-namespaces

# 3. Delete infrastructure (from root)
cd ..
terraform destroy
```

## 🔧 Troubleshooting

### Common Issues

#### Unable to connect to cluster

```bash
# Check AWS credentials
aws sts get-caller-identity

# Update kubeconfig
aws eks update-kubeconfig --region <region> --name <cluster-name>

# Verify kubectl context
kubectl config current-context
```

#### Nodes not joining cluster

```bash
# Check node group status
aws eks describe-nodegroup \
  --cluster-name <cluster-name> \
  --nodegroup-name <nodegroup-name>

# Check CloudWatch logs
aws logs tail /aws/eks/<cluster-name>/cluster --follow
```

#### Pods not scheduling

```bash
# Check node resources
kubectl describe nodes

# Check pod events
kubectl describe pod <pod-name>

# Check cluster autoscaler logs
kubectl logs -n kube-system deployment/cluster-autoscaler
```

#### ALB not creating

```bash
# Check Load Balancer Controller logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Check Ingress events
kubectl describe ingress <ingress-name>

# Verify IAM role (from kubernetes layer)
cd kubernetes
terraform output -raw aws_load_balancer_controller_role_arn
```

## ✨ Best Practices

### Resource Quotas

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

### Pod Security

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

### Network Policies

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

### Resource Requests and Limits

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

## 💡 Practical Examples

### Example 1: Complete Cluster Upgrade Workflow

Perform a controlled EKS cluster version upgrade from 1.34 to 1.35:

**1. Check compatibility and plan the upgrade:**

```bash
# Check current version
kubectl version --short

# Check for deprecated APIs
kubectl get all --all-namespaces -o json | jq -r '.items[] | select(.apiVersion | contains("v1beta"))'

# Review AWS EKS version compatibility
aws eks describe-addon-versions --kubernetes-version 1.35
```

**2. Update control plane (in terraform.tfvars):**

```hcl
# environments/production/terraform.tfvars
kubernetes_version = "1.35"  # Changed from 1.34
```

```bash
# Apply control plane upgrade
terraform plan -var-file=environments/production/terraform.tfvars
terraform apply -var-file=environments/production/terraform.tfvars

# Monitor upgrade progress
aws eks describe-cluster --name cloud-solutions-production-cluster --query 'cluster.status'
```

**3. Update node groups:**

```bash
# Cordon existing nodes to prevent new pods
kubectl cordon -l eks.amazonaws.com/nodegroup=cloud-solutions-production-node-group

# Create new node group with updated version (already done by terraform apply)
# Verify new nodes are running
kubectl get nodes -L eks.amazonaws.com/nodegroup

# Drain old nodes gradually
for node in $(kubectl get nodes -l eks.amazonaws.com/nodegroup-image=ami-old -o name); do
  kubectl drain $node --ignore-daemonsets --delete-emptydir-data --grace-period=300
  sleep 60  # Wait between draining nodes
done

# Delete old nodes once all pods are migrated
# (Terraform automatically replaces nodes with new version)
```

**4. Update add-ons:**

```bash
# Update kube-proxy
aws eks update-addon \
  --cluster-name cloud-solutions-production-cluster \
  --addon-name kube-proxy \
  --addon-version v1.35.0-eksbuild.1

# Update CoreDNS
aws eks update-addon \
  --cluster-name cloud-solutions-production-cluster \
  --addon-name coredns \
  --addon-version v1.11.3-eksbuild.1

# Update VPC CNI
aws eks update-addon \
  --cluster-name cloud-solutions-production-cluster \
  --addon-name vpc-cni \
  --addon-version v1.18.0-eksbuild.1
```

**5. Verify cluster health:**

```bash
# Check all pods are running
kubectl get pods --all-namespaces | grep -v Running

# Check node status
kubectl get nodes

# Run a test deployment
kubectl run test-nginx --image=nginx:latest --rm -it --restart=Never -- curl localhost
```

### Example 2: Troubleshooting Pod Scheduling Issues

Debug why pods are stuck in Pending state:

**Scenario: Pods won't schedule due to insufficient resources**

```bash
# Check pod status
kubectl get pods -n production
# NAME                    READY   STATUS    RESTARTS   AGE
# myapp-7d8f9c4b5-abc123  0/1     Pending   0          5m

# Describe the pod to see events
kubectl describe pod myapp-7d8f9c4b5-abc123 -n production
# Events:
#   Type     Reason            Age    Message
#   Warning  FailedScheduling  2m     0/2 nodes are available: 2 Insufficient cpu.

# Check node resources
kubectl top nodes
# NAME                              CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
# ip-10-0-1-100.eu-west-1.compute   950m         95%    1800Mi          90%
# ip-10-0-2-100.eu-west-1.compute   920m         92%    1750Mi          88%

# Check detailed node allocatable resources
kubectl describe nodes | grep -A 5 "Allocated resources"
```

**Solution A: Scale up node group**

```bash
# Increase desired capacity
aws eks update-nodegroup-config \
  --cluster-name cloud-solutions-production-cluster \
  --nodegroup-name cloud-solutions-production-node-group \
  --scaling-config desiredSize=4,minSize=2,maxSize=6

# Watch for new nodes
kubectl get nodes -w
```

**Solution B: Install Cluster Autoscaler**

```yaml
# cluster-autoscaler.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    metadata:
      labels:
        app: cluster-autoscaler
    spec:
      serviceAccountName: cluster-autoscaler
      containers:
      - image: registry.k8s.io/autoscaling/cluster-autoscaler:v1.34.0
        name: cluster-autoscaler
        command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=aws
        - --skip-nodes-with-local-storage=false
        - --expander=least-waste
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/cloud-solutions-production-cluster
```

```bash
kubectl apply -f cluster-autoscaler.yaml

# Monitor autoscaler logs
kubectl logs -n kube-system -l app=cluster-autoscaler -f
```

### Example 3: Implementing Multi-Tenant Namespaces

Set up isolated namespaces for different teams with resource quotas and network policies:

**1. Create team namespace with quotas:**

```yaml
# team-alpha-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: team-alpha
  labels:
    team: alpha
    pod-security.kubernetes.io/enforce: restricted
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-alpha-quota
  namespace: team-alpha
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
    persistentvolumeclaims: "5"
    services.loadbalancers: "2"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: team-alpha-limits
  namespace: team-alpha
spec:
  limits:
  - max:
      cpu: "2"
      memory: 4Gi
    min:
      cpu: "100m"
      memory: 128Mi
    default:
      cpu: "500m"
      memory: 512Mi
    defaultRequest:
      cpu: "200m"
      memory: 256Mi
    type: Container
```

**2. Create network isolation:**

```yaml
# team-alpha-network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: team-alpha-isolation
  namespace: team-alpha
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  # Allow from same namespace
  - from:
    - podSelector: {}
  # Allow from ingress controller
  - from:
    - namespaceSelector:
        matchLabels:
          name: kube-system
      podSelector:
        matchLabels:
          app.kubernetes.io/name: aws-load-balancer-controller
  egress:
  # Allow to same namespace
  - to:
    - podSelector: {}
  # Allow DNS
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - protocol: UDP
      port: 53
  # Allow to internet (via NAT gateway)
  - to:
    - namespaceSelector: {}
```

**3. Create RBAC for team access:**

```yaml
# team-alpha-rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: team-alpha-deployer
  namespace: team-alpha
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: team-alpha-admin
  namespace: team-alpha
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: team-alpha-admin-binding
  namespace: team-alpha
subjects:
- kind: ServiceAccount
  name: team-alpha-deployer
  namespace: team-alpha
roleRef:
  kind: Role
  name: team-alpha-admin
  apiGroup: rbac.authorization.k8s.io
```

**4. Deploy resources:**

```bash
kubectl apply -f team-alpha-namespace.yaml
kubectl apply -f team-alpha-network-policy.yaml
kubectl apply -f team-alpha-rbac.yaml

# Verify quota
kubectl describe resourcequota team-alpha-quota -n team-alpha

# Test resource limits
kubectl run test-pod -n team-alpha --image=nginx --requests=cpu=100m,memory=128Mi --limits=cpu=500m,memory=512Mi
```

### Example 4: Setting Up Persistent Storage with EFS

Deploy an application using EFS for shared persistent storage:

**1. Verify EFS CSI driver is configured:**

```bash
# Check EFS CSI driver IAM role (from infrastructure layer)
terraform output -raw efs_csi_driver_role_arn

# Install EFS CSI driver
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-2.0"

# Verify installation
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-efs-csi-driver
```

**2. Create StorageClass and PersistentVolume:**

```yaml
# efs-storage.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: fs-12345678  # Get from: terraform output efs_file_system_id
  directoryPerms: "700"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-claim
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: efs-sc
  resources:
    requests:
      storage: 5Gi
```

**3. Deploy application using EFS:**

```yaml
# app-with-efs.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shared-storage-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: shared-storage
  template:
    metadata:
      labels:
        app: shared-storage
    spec:
      containers:
      - name: app
        image: nginx:latest
        volumeMounts:
        - name: shared-data
          mountPath: /usr/share/nginx/html
        ports:
        - containerPort: 80
      volumes:
      - name: shared-data
        persistentVolumeClaim:
          claimName: efs-claim
```

**4. Test shared storage:**

```bash
kubectl apply -f efs-storage.yaml
kubectl apply -f app-with-efs.yaml

# Write data from one pod
kubectl exec -it shared-storage-app-xxx -- bash -c "echo 'Hello from EFS' > /usr/share/nginx/html/index.html"

# Verify from another pod
kubectl exec -it shared-storage-app-yyy -- cat /usr/share/nginx/html/index.html
# Output: Hello from EFS
```

### Example 5: Implementing Pod Disruption Budgets for High Availability

Ensure application availability during voluntary disruptions (node drains, upgrades):

**Scenario: Protecting a critical application from having all pods terminated simultaneously**

```yaml
# critical-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: critical-api
  namespace: production
spec:
  replicas: 5
  selector:
    matchLabels:
      app: critical-api
  template:
    metadata:
      labels:
        app: critical-api
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: critical-api
              topologyKey: kubernetes.io/hostname
      containers:
      - name: api
        image: myapp:v1.0.0
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: critical-api-pdb
  namespace: production
spec:
  minAvailable: 3  # At least 3 pods must always be available
  selector:
    matchLabels:
      app: critical-api
```

**Test the PDB:**

```bash
kubectl apply -f critical-app.yaml

# Verify PDB status
kubectl get pdb -n production
# NAME               MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
# critical-api-pdb   3               N/A               2                     1m

# Try to drain a node
kubectl drain ip-10-0-1-100.eu-west-1.compute --ignore-daemonsets --delete-emptydir-data

# PDB will ensure at least 3 pods remain running during the drain
# If draining would violate the PDB, kubectl will wait
```

### Example 6: Cost Optimization with Spot Instances

Deploy workloads using spot instances with proper handling of interruptions:

**1. Create spot instance node group:**

```hcl
# In terraform.tfvars
capacity_type = "SPOT"
node_instance_types = ["t3.medium", "t3a.medium", "t2.medium"]  # Multiple types for better availability
```

**2. Deploy spot-tolerant workload:**

```yaml
# batch-job-spot.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-processing
spec:
  completions: 100
  parallelism: 10
  backoffLimit: 20  # Allow retries for spot interruptions
  template:
    spec:
      restartPolicy: OnFailure
      tolerations:
      - key: "spot"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
      nodeSelector:
        eks.amazonaws.com/capacityType: SPOT
      containers:
      - name: processor
        image: batch-processor:v1.0.0
        command: ["./process.sh"]
```

**3. Handle spot interruptions with node termination handler:**

```bash
# Install AWS Node Termination Handler
helm repo add eks https://aws.github.io/eks-charts
helm install aws-node-termination-handler eks/aws-node-termination-handler \
  --namespace kube-system \
  --set enableSpotInterruptionDraining=true \
  --set enableScheduledEventDraining=true

# Monitor spot interruptions
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-node-termination-handler -f
```

**4. Estimate cost savings:**

```bash
# Before (ON_DEMAND)
# t3.medium x 3 nodes = $0.0416/hr x 3 x 730 hours = ~$91/month

# After (SPOT)
# t3.medium x 3 nodes = $0.0125/hr x 3 x 730 hours = ~$27/month
# Savings: ~$64/month (70% reduction)
```

### Example 7: Debugging Network Connectivity Issues

Troubleshoot pod-to-pod and pod-to-internet connectivity:

**Problem: Pods cannot reach external services**

```bash
# Step 1: Create debug pod
kubectl run debug-pod --image=nicolaka/netshoot -it --rm --restart=Never -- bash

# Inside debug pod:
# Test DNS resolution
nslookup google.com
nslookup kubernetes.default.svc.cluster.local

# Test connectivity to internet
curl -v https://google.com

# Test connectivity to another pod
curl -v http://myapp-service.production.svc.cluster.local

# Check routing
ip route
traceroute 8.8.8.8

# Check firewall rules
iptables -L -n -v
```

**Step 2: Check VPC CNI plugin:**

```bash
# Check CNI plugin logs
kubectl logs -n kube-system -l k8s-app=aws-node --tail=100

# Check IP address allocation
kubectl get pods -o wide --all-namespaces | grep -v Running

# Verify ENI attachment
aws ec2 describe-network-interfaces \
  --filters "Name=attachment.instance-id,Values=$(kubectl get nodes -o jsonpath='{.items[0].spec.providerID}' | cut -d'/' -f5)"
```

**Step 3: Verify security groups:**

```bash
# Get node security group
aws ec2 describe-instances \
  --instance-ids $(kubectl get nodes -o jsonpath='{.items[0].spec.providerID}' | cut -d'/' -f5) \
  --query 'Reservations[0].Instances[0].SecurityGroups[*].GroupId'

# Check security group rules
aws ec2 describe-security-groups --group-ids sg-xxxxx

# Verify NAT gateway is running (for private subnet internet access)
terraform output nat_gateway_ids
aws ec2 describe-nat-gateways --nat-gateway-ids nat-xxxxx
```

**Step 4: Check network policies:**

```bash
# List all network policies
kubectl get networkpolicies --all-namespaces

# Check if network policy is blocking traffic
kubectl describe networkpolicy -n production
```

---

**Built with ❤️ for Cloud Solutions Inc.**
