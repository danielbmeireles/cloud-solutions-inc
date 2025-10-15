# 🔌 AWS Load Balancer Controller <!-- omit in toc -->

This document describes the AWS Load Balancer Controller deployment using a custom wrapper Helm chart.

## 📑 Table of Contents <!-- omit in toc -->

- [🏗️ Overview](#️-overview)
- [🎯 Why a Wrapper Chart](#-why-a-wrapper-chart)
- [🏛️ Architecture](#️-architecture)
- [⚙️ Usage](#️-usage)
- [📝 Configuration](#-configuration)
- [🔐 IAM Role Requirements](#-iam-role-requirements)
- [🔄 Dependencies Management](#-dependencies-management)
- [⬆️ Upgrading](#️-upgrading)
- [🗑️ Uninstalling](#️-uninstalling)
- [🔧 Troubleshooting](#-troubleshooting)
- [🔗 References](#-references)

## 🏗️ Overview

This is a wrapper Helm chart for the official [AWS Load Balancer Controller](https://github.com/aws/aws-load-balancer-controller) chart. The controller automatically provisions AWS Application Load Balancers (ALB) and Network Load Balancers (NLB) from Kubernetes Ingress and Service resources.

## 🎯 Why a Wrapper Chart

Instead of managing the ServiceAccount separately with Terraform and then installing the official chart, this wrapper:

1. ✅ **Manages ServiceAccount with IRSA annotations** as a Helm template
2. ✅ **Uses official chart as dependency** for the controller deployment
3. ✅ **Single source of truth** - everything in Helm/Kubernetes ecosystem
4. ✅ **Easier to maintain** - no mixing of Terraform and Helm resources
5. ✅ **Proper Kubernetes practices** - ServiceAccount is a K8s resource, should be managed by Helm

## 🏛️ Architecture

```
┌────────────────────────────────────────────-─┐
│  This Wrapper Chart                          │
│  ├── ServiceAccount (with IRSA annotations)  │
│  └── Dependency: Official AWS Chart          │
│      └── Controller Deployment               │
└─────────────────────────────────────────────-┘
```

## ⚙️ Usage

### From Terraform

```hcl
resource "helm_release" "aws_load_balancer_controller" {
  name      = "aws-load-balancer-controller"
  chart     = "./charts/aws-load-balancer-controller"
  namespace = "kube-system"

  values = [
    yamlencode({
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.lb_controller.arn
        }
      }
      controller = {
        clusterName = var.cluster_name
        region      = var.aws_region
        vpcId       = var.vpc_id
      }
    })
  ]

  # Important: Update dependencies before install
  dependency_update = true
}
```

### Manual Helm Install

```bash
# 1. Update chart dependencies
helm dependency update

# 2. Install with custom values
helm install aws-load-balancer-controller . \
  --namespace kube-system \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::123456789012:role/AWSLoadBalancerControllerRole \
  --set controller.clusterName=my-cluster \
  --set controller.region=us-east-1 \
  --set controller.vpcId=vpc-12345
```

### With values.yaml

```yaml
# custom-values.yaml
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::123456789012:role/AWSLoadBalancerControllerRole"

controller:
  clusterName: "my-eks-cluster"
  region: "us-east-1"
  vpcId: "vpc-12345"
  replicaCount: 2
```

```bash
helm dependency update
helm install aws-load-balancer-controller . \
  --namespace kube-system \
  -f custom-values.yaml
```

## 📝 Configuration

### ServiceAccount Settings

| Parameter                    | Description                  | Default                        |
| ---------------------------- | ---------------------------- | ------------------------------ |
| `serviceAccount.create`      | Create ServiceAccount        | `true`                         |
| `serviceAccount.name`        | ServiceAccount name          | `aws-load-balancer-controller` |
| `serviceAccount.annotations` | Annotations (including IRSA) | `{}`                           |

### Controller Settings

All settings under `controller.*` are passed directly to the upstream chart. See [official chart values](https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller) for full options.

Key settings:
- `controller.clusterName` (required): EKS cluster name
- `controller.region` (required): AWS region
- `controller.vpcId` (required): VPC ID
- `controller.replicaCount`: Number of replicas (default: 2)
- `controller.resources`: Resource requests/limits

## 🔐 IAM Role Requirements

The ServiceAccount requires an IAM role with the AWS Load Balancer Controller policy attached. This role must:

1. Have a trust relationship with your EKS OIDC provider
2. Be annotated on the ServiceAccount via `eks.amazonaws.com/role-arn`

Example trust policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT:oidc-provider/oidc.eks.REGION.amazonaws.com/id/OIDC_ID"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.REGION.amazonaws.com/id/OIDC_ID:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller",
          "oidc.eks.REGION.amazonaws.com/id/OIDC_ID:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
```

## 🔄 Dependencies Management

The chart uses the official AWS chart as a dependency:

```bash
# List dependencies
helm dependency list

# Update dependencies (download charts)
helm dependency update

# Build dependencies (create charts/ dir with tarballs)
helm dependency build
```

## ⬆️ Upgrading

```bash
# Update dependencies to latest versions
helm dependency update

# Upgrade release
helm upgrade aws-load-balancer-controller . \
  --namespace kube-system \
  -f custom-values.yaml
```

## 🗑️ Uninstalling

```bash
helm uninstall aws-load-balancer-controller --namespace kube-system
```

## 🔧 Troubleshooting

### ServiceAccount Not Found

Ensure `serviceAccount.create: true` and the chart is fully deployed.

### Controller Pods Failing

Check IAM role permissions and OIDC trust policy.

```bash
# Check ServiceAccount
kubectl get sa -n kube-system aws-load-balancer-controller -o yaml

# Check controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller-controller
```

### Dependencies Not Downloading

```bash
# Manually update dependencies
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm dependency update
```

### ALB Not Creating

Check controller logs for errors:

```bash
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller --tail=50
```

Common issues:
- IAM permissions missing
- Subnets missing required tags
- Security groups blocking traffic
- Ingress annotations incorrect

## 🔗 References

- [AWS Load Balancer Controller Docs](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [Official Helm Chart](https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller)
- [IRSA Documentation](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)

---

**Built with ❤️ for Cloud Solutions Inc.**
