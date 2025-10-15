# 📦 Sample Application Examples <!-- omit in toc -->

This document provides instructions for deploying sample applications to test the AWS Load Balancer Controller and EKS infrastructure.

## 📑 Table of Contents <!-- omit in toc -->

- [📋 Prerequisites](#-prerequisites)
- [🚀 Deploy Sample NGINX Application](#-deploy-sample-nginx-application)
- [✅ Verify Deployment](#-verify-deployment)
- [🌐 Access the Application](#-access-the-application)
- [🔧 Troubleshooting](#-troubleshooting)
- [🧹 Cleanup](#-cleanup)
- [📚 Related Documentation](#-related-documentation)

## 📋 Prerequisites

- EKS cluster deployed and running
- AWS Load Balancer Controller installed
- kubectl configured to access the cluster

## 🚀 Deploy Sample NGINX Application

This sample application demonstrates how the AWS Load Balancer Controller automatically creates an Application Load Balancer (ALB) from a Kubernetes Ingress resource.

### Apply the Manifest

```bash
kubectl apply -f examples/complete-deployment.yaml
```

This creates:
- **Namespace**: `sample-app`
- **Deployment**: NGINX web server with 2 replicas
- **Service**: ClusterIP service exposing port 80
- **Ingress**: ALB ingress resource with internet-facing scheme

## ✅ Verify Deployment

### Check All Resources

```bash
kubectl get all -n sample-app
```

### Check Ingress Status

Wait for the ALB to be provisioned (takes 2-3 minutes):

```bash
kubectl get ingress -n sample-app nginx-ingress -w
```

The `ADDRESS` column will show the ALB DNS name when ready.

### Get the ALB URL

```bash
kubectl get ingress -n sample-app nginx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Example output: `k8s-sampleap-nginxing-abc123456.eu-west-1.elb.amazonaws.com`

## 🌐 Access the Application

Copy the ALB hostname from the previous step and access via browser or curl:

```bash
ALB_URL=$(kubectl get ingress -n sample-app nginx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Application URL: http://${ALB_URL}"

# Test with curl
curl http://${ALB_URL}
```

You should see the default NGINX welcome page.

## 🔧 Troubleshooting

### ALB Not Created

**Check Load Balancer Controller logs:**

```bash
kubectl logs -n kube-system deployment/aws-load-balancer-controller --tail=50
```

**Check Ingress events:**

```bash
kubectl describe ingress -n sample-app nginx-ingress
```

Common issues:
- AWS Load Balancer Controller not running
- IAM permissions missing
- Subnets missing required tags:
  - `kubernetes.io/role/elb: 1` (for public subnets)
  - `kubernetes.io/cluster/<cluster-name>: owned` or `shared`

### Pods Not Starting

**Check pod status:**

```bash
kubectl get pods -n sample-app
kubectl describe pod -n sample-app <pod-name>
```

**Check pod logs:**

```bash
kubectl logs -n sample-app <pod-name>
```

### Cannot Access Application

**Check security groups:**
- Verify ALB security group allows inbound traffic on ports 80/443
- Verify node security group allows traffic from ALB

**Check target health:**
```bash
kubectl describe ingress -n sample-app nginx-ingress
```

Look for the `TargetGroups` annotation and check target health in AWS Console.

## 🧹 Cleanup

Remove all sample application resources:

```bash
kubectl delete -f examples/complete-deployment.yaml
```

This will:
- Delete the namespace and all resources
- Trigger automatic deletion of the ALB
- Clean up associated target groups

**Note**: The ALB deletion may take 1-2 minutes to complete.

---

**Built with ❤️ for Cloud Solutions Inc.**
