<!-- BEGIN_TF_DOCS -->


## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_ingress_v1.argocd_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/ingress_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_chart_version"></a> [argocd\_chart\_version](#input\_argocd\_chart\_version) | ArgoCD Helm chart version | `string` | `"7.7.12"` | no |
| <a name="input_argocd_domain"></a> [argocd\_domain](#input\_argocd\_domain) | Domain name for ArgoCD (for ingress) | `string` | `"argocd.local"` | no |
| <a name="input_controller_replicas"></a> [controller\_replicas](#input\_controller\_replicas) | Number of replicas for ArgoCD application controller | `number` | `1` | no |
| <a name="input_controller_resources"></a> [controller\_resources](#input\_controller\_resources) | Resource limits for ArgoCD controller | <pre>object({<br/>    limits = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>    requests = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>  })</pre> | <pre>{<br/>  "limits": {<br/>    "cpu": "500m",<br/>    "memory": "512Mi"<br/>  },<br/>  "requests": {<br/>    "cpu": "100m",<br/>    "memory": "128Mi"<br/>  }<br/>}</pre> | no |
| <a name="input_enable_ha"></a> [enable\_ha](#input\_enable\_ha) | Enable high availability features (pod anti-affinity and disruption budgets) | `bool` | `true` | no |
| <a name="input_ingress_annotations"></a> [ingress\_annotations](#input\_ingress\_annotations) | Annotations for ArgoCD ingress | `map(string)` | `{}` | no |
| <a name="input_ingress_class_name"></a> [ingress\_class\_name](#input\_ingress\_class\_name) | Ingress class name for ArgoCD | `string` | `"alb"` | no |
| <a name="input_ingress_enabled"></a> [ingress\_enabled](#input\_ingress\_enabled) | Enable ingress for ArgoCD server | `bool` | `false` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace for ArgoCD | `string` | `"argocd"` | no |
| <a name="input_repo_server_replicas"></a> [repo\_server\_replicas](#input\_repo\_server\_replicas) | Number of replicas for ArgoCD repo server | `number` | `2` | no |
| <a name="input_repo_server_resources"></a> [repo\_server\_resources](#input\_repo\_server\_resources) | Resource limits for ArgoCD repo server | <pre>object({<br/>    limits = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>    requests = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>  })</pre> | <pre>{<br/>  "limits": {<br/>    "cpu": "500m",<br/>    "memory": "512Mi"<br/>  },<br/>  "requests": {<br/>    "cpu": "100m",<br/>    "memory": "128Mi"<br/>  }<br/>}</pre> | no |
| <a name="input_server_insecure"></a> [server\_insecure](#input\_server\_insecure) | Run server without TLS (useful for development) | `bool` | `true` | no |
| <a name="input_server_replicas"></a> [server\_replicas](#input\_server\_replicas) | Number of replicas for ArgoCD server | `number` | `2` | no |
| <a name="input_server_resources"></a> [server\_resources](#input\_server\_resources) | Resource limits for ArgoCD server | <pre>object({<br/>    limits = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>    requests = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>  })</pre> | <pre>{<br/>  "limits": {<br/>    "cpu": "500m",<br/>    "memory": "256Mi"<br/>  },<br/>  "requests": {<br/>    "cpu": "100m",<br/>    "memory": "128Mi"<br/>  }<br/>}</pre> | no |
| <a name="input_server_service_type"></a> [server\_service\_type](#input\_server\_service\_type) | Service type for ArgoCD server (ClusterIP, LoadBalancer, or NodePort) | `string` | `"ClusterIP"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_hostname"></a> [alb\_hostname](#output\_alb\_hostname) | ALB hostname from ingress (if enabled) |
| <a name="output_argocd_domain"></a> [argocd\_domain](#output\_argocd\_domain) | ArgoCD domain (if ingress enabled) |
| <a name="output_argocd_server_service_name"></a> [argocd\_server\_service\_name](#output\_argocd\_server\_service\_name) | ArgoCD server service name |
| <a name="output_argocd_version"></a> [argocd\_version](#output\_argocd\_version) | ArgoCD Helm chart version |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | ArgoCD namespace |
<!-- END_TF_DOCS -->