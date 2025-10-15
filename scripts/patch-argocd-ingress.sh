#!/bin/bash

# ArgoCD Ingress Patcher
# Removes hostname restriction from ArgoCD ingress to allow access via ALB URL

set -e

# Configuration
NAMESPACE="argocd"
INGRESS_NAME="argocd-server"

echo "=== ArgoCD Ingress Patcher ==="
echo "Namespace: $NAMESPACE"
echo "Ingress: $INGRESS_NAME"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH"
    exit 1
fi

# Check if ingress exists
echo ""
echo "Checking if ArgoCD ingress exists..."
if ! kubectl get ingress "$INGRESS_NAME" -n "$NAMESPACE" > /dev/null 2>&1; then
    echo "Error: ArgoCD ingress '$INGRESS_NAME' not found in namespace '$NAMESPACE'"
    echo "Please ensure ArgoCD is deployed and the ingress is created"
    exit 1
fi
echo "Ingress found"

# Patch the ingress to remove hostname restriction
echo ""
echo "Patching ingress to remove hostname restriction..."
kubectl patch ingress "$INGRESS_NAME" -n "$NAMESPACE" --type='json' -p='[
  {
    "op": "remove",
    "path": "/spec/rules/0/host"
  }
]' 2>/dev/null || echo "Host field may already be removed"

# Get ALB URL
echo ""
echo "Getting ALB URL..."
sleep 2
ALB_URL=$(kubectl get ingress "$INGRESS_NAME" -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

if [ -n "$ALB_URL" ]; then
    echo ""
    echo "=== Patch Complete ==="
    echo "ArgoCD is now accessible at: https://$ALB_URL"
    echo "Note: It may take 1-2 minutes for changes to take effect"
else
    echo ""
    echo "=== Patch Complete ==="
    echo "Ingress patched successfully"
    echo "Run 'kubectl get ingress $INGRESS_NAME -n $NAMESPACE' to get the ALB URL"
fi
echo ""
