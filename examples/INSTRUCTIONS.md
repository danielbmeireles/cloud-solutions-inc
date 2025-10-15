# Sample NGINX Application - Usage Instructions

This is a sample application for testing the AWS Load Balancer Controller.

## 1. APPLY THE MANIFEST

```bash
kubectl apply -f examples/complete-deployment.yaml
```

## 2. CHECK STATUS

View all created resources:

```bash
kubectl get all -n sample-app
```

Check the Ingress (wait for ADDRESS to appear):

```bash
kubectl get ingress -n sample-app nginx-ingress -w
```

Get the ALB URL:

```bash
kubectl get ingress -n sample-app nginx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## 3. ACCESS THE APPLICATION

Copy the ALB hostname and access via browser:

```
http://<ALB-DNS-NAME>
```

## 4. TROUBLESHOOTING

Check Load Balancer Controller logs:

```bash
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

Check Ingress events:

```bash
kubectl describe ingress -n sample-app nginx-ingress
```

Check pod events:

```bash
kubectl describe pod -n sample-app
```

## 5. CLEANUP

```bash
kubectl delete -f examples/complete-deployment.yaml
```
