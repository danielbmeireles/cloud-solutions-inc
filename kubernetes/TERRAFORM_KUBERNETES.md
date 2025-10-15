<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.16.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.0.2 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm_certificate"></a> [acm\_certificate](#module\_acm\_certificate) | ../modules/acm | n/a |
| <a name="module_argocd"></a> [argocd](#module\_argocd) | ../modules/argocd | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.aws_load_balancer_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.aws_load_balancer_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [helm_release.aws_load_balancer_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [terraform_remote_state.infra](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_enabled"></a> [acm\_certificate\_enabled](#input\_acm\_certificate\_enabled) | Enable ACM certificate creation via Terraform for ArgoCD domain | `bool` | `false` | no |
| <a name="input_acm_subject_alternative_names"></a> [acm\_subject\_alternative\_names](#input\_acm\_subject\_alternative\_names) | Additional domain names for the ACM certificate (e.g., for wildcard or multiple subdomains) | `list(string)` | `[]` | no |
| <a name="input_acm_wait_for_validation"></a> [acm\_wait\_for\_validation](#input\_acm\_wait\_for\_validation) | Whether to wait for ACM certificate validation (requires DNS records to be added manually) | `bool` | `false` | no |
| <a name="input_argocd_chart_version"></a> [argocd\_chart\_version](#input\_argocd\_chart\_version) | ArgoCD Helm chart version | `string` | `"8.5.10"` | no |
| <a name="input_argocd_domain"></a> [argocd\_domain](#input\_argocd\_domain) | Domain name for ArgoCD (used for ingress) | `string` | `"argocd.local"` | no |
| <a name="input_argocd_ingress_annotations"></a> [argocd\_ingress\_annotations](#input\_argocd\_ingress\_annotations) | Annotations for ArgoCD ingress | `map(string)` | <pre>{<br/>  "alb.ingress.kubernetes.io/scheme": "internet-facing",<br/>  "alb.ingress.kubernetes.io/target-type": "ip"<br/>}</pre> | no |
| <a name="input_argocd_ingress_class_name"></a> [argocd\_ingress\_class\_name](#input\_argocd\_ingress\_class\_name) | Ingress class name for ArgoCD | `string` | `"alb"` | no |
| <a name="input_argocd_ingress_enabled"></a> [argocd\_ingress\_enabled](#input\_argocd\_ingress\_enabled) | Enable ingress for ArgoCD server | `bool` | `true` | no |
| <a name="input_argocd_server_insecure"></a> [argocd\_server\_insecure](#input\_argocd\_server\_insecure) | Run ArgoCD server without TLS (useful for development) | `bool` | `true` | no |
| <a name="input_argocd_server_service_type"></a> [argocd\_server\_service\_type](#input\_argocd\_server\_service\_type) | Service type for ArgoCD server (ClusterIP, LoadBalancer, or NodePort) | `string` | `"ClusterIP"` | no |
| <a name="input_aws_load_balancer_controller_chart_version"></a> [aws\_load\_balancer\_controller\_chart\_version](#input\_aws\_load\_balancer\_controller\_chart\_version) | AWS Load Balancer Controller Helm chart version | `string` | `"1.14.0"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where resources will be created | `string` | `"us-east-1"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., production, staging, development) | `string` | `"production"` | no |
| <a name="input_install_aws_load_balancer_controller"></a> [install\_aws\_load\_balancer\_controller](#input\_install\_aws\_load\_balancer\_controller) | Whether to install AWS Load Balancer Controller via Helm | `bool` | `true` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name used for resource naming | `string` | `"cloud-solutions"` | no |
| <a name="input_state_bucket"></a> [state\_bucket](#input\_state\_bucket) | S3 bucket name for Terraform state | `string` | `"cloud-solutions-terraform-state"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | ARN of the ACM certificate for ArgoCD (if enabled) |
| <a name="output_acm_certificate_status"></a> [acm\_certificate\_status](#output\_acm\_certificate\_status) | Status of the ACM certificate |
| <a name="output_acm_validation_records"></a> [acm\_validation\_records](#output\_acm\_validation\_records) | DNS validation records to add to Squarespace (CNAME records) |
| <a name="output_argocd_namespace"></a> [argocd\_namespace](#output\_argocd\_namespace) | ArgoCD namespace |
| <a name="output_argocd_server_url"></a> [argocd\_server\_url](#output\_argocd\_server\_url) | ArgoCD server URL |
| <a name="output_aws_load_balancer_controller_installed"></a> [aws\_load\_balancer\_controller\_installed](#output\_aws\_load\_balancer\_controller\_installed) | Whether AWS Load Balancer Controller was installed |
| <a name="output_aws_load_balancer_controller_role_arn"></a> [aws\_load\_balancer\_controller\_role\_arn](#output\_aws\_load\_balancer\_controller\_role\_arn) | IAM role ARN for AWS Load Balancer Controller |
<!-- END_TF_DOCS -->