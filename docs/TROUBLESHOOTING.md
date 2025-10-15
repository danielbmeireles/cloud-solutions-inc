# 🔧 Troubleshooting Guide <!-- omit in toc -->

Comprehensive troubleshooting guide for Cloud Solutions Inc. infrastructure.

## 📑 Table of Contents <!-- omit in toc -->

- [🚨 Quick Diagnostic Commands](#-quick-diagnostic-commands)
- [🌐 Network Issues](#-network-issues)
- [☸️ EKS Cluster Issues](#️-eks-cluster-issues)
- [📦 Terraform Issues](#-terraform-issues)
- [🚀 ArgoCD Issues](#-argocd-issues)
- [🔌 AWS Load Balancer Controller Issues](#-aws-load-balancer-controller-issues)
- [🔐 Authentication & Permissions](#-authentication--permissions)
- [💾 State Management Issues](#-state-management-issues)
- [🔒 Certificate & SSL/TLS Issues](#-certificate--ssltls-issues)
- [📊 Monitoring & Logging](#-monitoring--logging)
- [🔄 CI/CD Pipeline Issues](#-cicd-pipeline-issues)
- [📚 Component-Specific Troubleshooting](#-component-specific-troubleshooting)

## 🚨 Quick Diagnostic Commands

Run these commands to quickly assess system health:

```bash
# Check all pods across namespaces
kubectl get pods --all-namespaces | grep -v Running

# Check node health
kubectl get nodes
kubectl top nodes

# Check recent events
kubectl get events --all-namespaces --sort-by='.lastTimestamp' | tail -20

# Check EKS cluster status
aws eks describe-cluster --name <cluster-name> --query 'cluster.status'

# Check Terraform state
terraform state list

# Check CI/CD pipeline status
gh run list --limit 5
```

## 🌐 Network Issues

### Cannot Connect to EKS Cluster

**Symptoms:**
- `kubectl` commands timeout
- `Unable to connect to the server`

**Diagnostics:**
```bash
# Check kubeconfig
kubectl config current-context
kubectl config view

# Test cluster endpoint
aws eks describe-cluster --name <cluster-name> --query 'cluster.endpoint'

# Update kubeconfig
aws eks update-kubeconfig --name <cluster-name> --region <region>
```

**Solutions:**
1. Update kubeconfig with correct region
2. Check AWS credentials are valid
3. Verify VPN/network connectivity if using private endpoint
4. Check security groups allow your IP

### VPC/Subnet Configuration Issues

**Symptoms:**
- Pods can't reach internet
- Load balancers not provisioning

**Diagnostics:**
```bash
# Check VPC configuration
aws ec2 describe-vpcs --vpc-ids <vpc-id>

# Check subnet tags
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>"

# Check route tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<vpc-id>"
```

**Solutions:**
1. Verify subnets have required tags:
   - `kubernetes.io/role/elb: 1` (public subnets)
   - `kubernetes.io/role/internal-elb: 1` (private subnets)
   - `kubernetes.io/cluster/<cluster-name>: owned` or `shared`
2. Check NAT Gateway is running (for private subnets)
3. Verify route tables have correct routes

## ☸️ EKS Cluster Issues

### Pods Stuck in Pending

**Diagnostics:**
```bash
# Check pod status
kubectl describe pod <pod-name> -n <namespace>

# Check node resources
kubectl top nodes
kubectl describe nodes | grep -A 5 "Allocated resources"

# Check pod events
kubectl get events -n <namespace> --field-selector involvedObject.name=<pod-name>
```

**Common Causes:**
1. **Insufficient resources**: Scale node group or use larger instances
2. **ImagePullBackOff**: Check image name and registry permissions
3. **PVC not bound**: Check storage class and PV availability
4. **Node selector mismatch**: Verify labels match available nodes

### Nodes Not Joining Cluster

**Diagnostics:**
```bash
# Check Auto Scaling Group
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names <asg-name>

# Check node IAM role
aws iam get-role --role-name <node-role-name>

# Check CloudWatch logs
aws logs tail /aws/eks/<cluster-name>/cluster --follow
```

**Solutions:**
1. Verify node IAM role has required policies
2. Check user data script in launch template
3. Verify AMI is compatible with EKS version
4. Check security groups allow node-to-control-plane communication

### Detailed Troubleshooting

See: [EKS Documentation - Troubleshooting](EKS.md#-troubleshooting)

## 📦 Terraform Issues

### State Lock Conflicts

**Symptoms:**
- `Error acquiring the state lock`
- `lock info` showing old lock

**Diagnostics:**
```bash
# Check state file
aws s3 ls s3://<bucket>/<key>

# Check for lock file (if using DynamoDB)
aws dynamodb get-item --table-name <table> --key '{"LockID": {"S": "<state-path>"}}'
```

**Solutions:**
```bash
# Force unlock (use carefully!)
terraform force-unlock <lock-id>

# Wait for lock to expire (usually 15 minutes)
# Or verify no other operations are running, then force unlock
```

### State File Corrupted

**Diagnostics:**
```bash
# Verify state file integrity
terraform state list

# Check S3 versioning
aws s3api list-object-versions \
  --bucket <bucket> \
  --prefix <key>
```

**Solutions:**
```bash
# Restore from S3 version
aws s3api get-object \
  --bucket <bucket> \
  --key <key> \
  --version-id <version-id> \
  terraform.tfstate.backup

# Or restore from local backup
cp terraform.tfstate.backup terraform.tfstate
```

### Provider Configuration Errors

**Symptoms:**
- `Error configuring the backend "s3"`
- `Provider produced inconsistent result`

**Solutions:**
1. Verify AWS credentials are configured
2. Check region matches backend configuration
3. Ensure S3 bucket exists and is accessible
4. Verify Terraform version compatibility

### Detailed Troubleshooting

See: [Terraform Documentation](TERRAFORM.md#-usage)

## 🚀 ArgoCD Issues

### Cannot Access ArgoCD UI

**Diagnostics:**
```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Check ingress
kubectl get ingress -n argocd
kubectl describe ingress argocd-server -n argocd

# Check service
kubectl get svc -n argocd argocd-server
```

**Solutions:**
1. **Port forward not working**: Check pod is running
2. **ALB returns 404**: Run `./scripts/patch-argocd-ingress.sh`
3. **DNS not resolving**: Check CNAME record and DNS propagation
4. **Certificate errors**: Verify ACM certificate is validated

### ArgoCD Sync Failures

**Diagnostics:**
```bash
# Check application status
kubectl get applications -n argocd

# View application details
kubectl describe application <app-name> -n argocd

# Check ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
```

**Common Causes:**
1. Git repository authentication issues
2. Invalid Kubernetes manifests
3. Resource quotas exceeded
4. Namespace doesn't exist

### Detailed Troubleshooting

See: [ArgoCD Documentation - Troubleshooting](ARGOCD.md#-troubleshooting)

## 🔌 AWS Load Balancer Controller Issues

### ALB Not Created

**Diagnostics:**
```bash
# Check controller pods
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Check controller logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller --tail=100

# Check ingress events
kubectl describe ingress <ingress-name> -n <namespace>
```

**Common Causes:**
1. Controller not running - check IAM permissions
2. Subnets missing required tags
3. Security groups blocking traffic
4. Invalid ingress annotations

### Unhealthy Targets

**Diagnostics:**
```bash
# Check target group health (from AWS Console or CLI)
aws elbv2 describe-target-health --target-group-arn <arn>

# Check pod health
kubectl get pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace>

# Check service endpoints
kubectl get endpoints <service-name> -n <namespace>
```

**Solutions:**
1. Verify pods are running and ready
2. Check health check path is correct
3. Verify security groups allow ALB → pods traffic
4. Check pod is listening on correct port

### Detailed Troubleshooting

See: [AWS Load Balancer Controller Documentation](AWS_LOAD_BALANCER_CONTROLLER.md#-troubleshooting)

## 🔐 Authentication & Permissions

### AWS Credentials Issues

**Symptoms:**
- `NoCredentialProviders: no valid providers in chain`
- `Access Denied`

**Diagnostics:**
```bash
# Check current AWS identity
aws sts get-caller-identity

# Check credentials
aws configure list

# Test permissions
aws eks describe-cluster --name <cluster-name>
```

**Solutions:**
1. Configure AWS credentials: `aws configure`
2. Check IAM policies attached to user/role
3. Verify MFA token if required
4. Check session token hasn't expired

### IRSA Issues

**Symptoms:**
- Pods can't access AWS services
- `An error occurred (AccessDenied) when calling the X operation`

**Diagnostics:**
```bash
# Check ServiceAccount annotations
kubectl get sa <service-account> -n <namespace> -o yaml

# Check pod IAM role
kubectl describe pod <pod-name> -n <namespace> | grep AWS

# Verify OIDC provider
aws iam list-open-id-connect-providers
```

**Solutions:**
1. Verify ServiceAccount has correct IAM role annotation
2. Check trust relationship in IAM role
3. Verify OIDC provider is configured
4. Check IAM policy permissions

## 💾 State Management Issues

### Remote State Not Found

**Diagnostics:**
```bash
# Check S3 bucket
aws s3 ls s3://<bucket>/<key>

# Verify backend configuration
terraform init -backend-config=<backend-file>
```

**Solutions:**
1. Verify bucket name and key path
2. Check AWS region matches
3. Initialize backend: `terraform init -reconfigure`
4. Verify S3 bucket permissions

### State Drift Detected

**Diagnostics:**
```bash
# Show drift
terraform plan -refresh-only

# Compare state with actual resources
terraform show
```

**Solutions:**
```bash
# Refresh state
terraform apply -refresh-only

# Or import missing resources
terraform import <resource-type>.<name> <resource-id>

# Or remove from state if resource deleted
terraform state rm <resource-address>
```

## 🔒 Certificate & SSL/TLS Issues

### ACM Certificate Not Validating

**Symptoms:**
- Certificate stuck in "PENDING_VALIDATION"

**Diagnostics:**
```bash
# Check certificate status
terraform output acm_certificate_status

# Check DNS validation records
dig <validation-record> CNAME
```

**Solutions:**
1. Verify CNAME record is correct in DNS
2. Wait 30 minutes for DNS propagation
3. Check certificate is in correct region (must match ALB)
4. Ensure no typos in validation record

### Browser Certificate Warnings

**Diagnostics:**
```bash
# Check DNS resolution
nslookup <domain>

# Test certificate
openssl s_client -connect <domain>:443 -servername <domain>
```

**Solutions:**
1. Verify certificate status is "ISSUED"
2. Check domain name matches certificate
3. Clear browser cache
4. Wait for DNS propagation

### Detailed Troubleshooting

See: [ArgoCD Documentation - Certificate Issues](ARGOCD.md#certificate-not-validated)

## 📊 Monitoring & Logging

### Missing Metrics

**Diagnostics:**
```bash
# Check CloudWatch dashboard
aws cloudwatch get-dashboard --dashboard-name <dashboard-name>

# List available metrics
aws cloudwatch list-metrics --namespace AWS/EKS

# Check metric data
aws cloudwatch get-metric-statistics \
  --namespace AWS/EKS \
  --metric-name cluster_failed_node_count \
  --dimensions Name=ClusterName,Value=<cluster-name> \
  --start-time <start> --end-time <end> \
  --period 300 --statistics Average
```

**Solutions:**
1. Verify CloudWatch agent is running
2. Check IAM permissions for CloudWatch
3. Enable Container Insights if needed
4. Verify metric filters are configured

### Log Aggregation Issues

**Diagnostics:**
```bash
# Check log groups
aws logs describe-log-groups

# View recent logs
aws logs tail /aws/eks/<cluster-name>/cluster --follow

# Check FluentBit/CloudWatch agent
kubectl get pods -n amazon-cloudwatch
```

**Solutions:**
1. Verify log groups exist
2. Check pod permissions to write logs
3. Enable control plane logging in EKS
4. Configure log retention policies

## 🔄 CI/CD Pipeline Issues

### GitHub Actions Workflow Failures

**Diagnostics:**
```bash
# List recent runs
gh run list --limit 10

# View specific run
gh run view <run-id>

# Check logs
gh run view <run-id> --log
```

**Common Causes:**
1. OIDC authentication failure - check AWS_ROLE_ARN
2. Terraform validation errors - fix `.tf` files
3. State lock conflict - wait or force unlock
4. Missing secrets/variables - configure in GitHub

### OIDC Authentication Failures

**Diagnostics:**
```bash
# Check OIDC provider
aws iam list-open-id-connect-providers

# Check IAM role trust policy
aws iam get-role --role-name GitHubActionsRole
```

**Solutions:**
1. Verify OIDC provider is configured
2. Check IAM role trust policy matches repository
3. Verify AWS_ROLE_ARN secret is correct
4. Check repository has permission to assume role

### Detailed Troubleshooting

See: [CI/CD Documentation](CICD.md#-monitoring)

## 📚 Component-Specific Troubleshooting

For detailed component-specific troubleshooting, refer to:

| Component | Documentation |
|-----------|---------------|
| **EKS Cluster** | [EKS Troubleshooting](EKS.md#-troubleshooting) |
| **ArgoCD** | [ArgoCD Troubleshooting](ARGOCD.md#-troubleshooting) |
| **AWS Load Balancer Controller** | [ALB Controller Troubleshooting](AWS_LOAD_BALANCER_CONTROLLER.md#-troubleshooting) |
| **Kubernetes Layer** | [Kubernetes Troubleshooting](KUBERNETES.md#-troubleshooting) |
| **Terraform** | [Terraform Best Practices](TERRAFORM.md#-best-practices) |
| **CI/CD** | [CI/CD Monitoring](CICD.md#-monitoring) |

## 🆘 Getting Help

If you've tried the above troubleshooting steps and still have issues:

1. **Check AWS Service Health**: https://status.aws.amazon.com/
2. **Review CloudWatch Logs**: Look for error patterns
3. **Search GitHub Issues**: Check if others have encountered similar problems
4. **Consult AWS Documentation**: https://docs.aws.amazon.com/
5. **Enable Debug Logging**: Set appropriate log levels for detailed output

### Debug Mode

Enable debug logging for deeper investigation:

```bash
# Terraform debug
export TF_LOG=DEBUG
terraform apply

# kubectl verbose output
kubectl get pods -v=8

# ArgoCD debug
kubectl patch configmap argocd-cmd-params-cm -n argocd \
  --patch '{"data":{"server.log.level":"debug"}}'
```

---

**Built with ❤️ for Cloud Solutions Inc.**
