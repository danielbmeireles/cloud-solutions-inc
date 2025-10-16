<!-- BEGIN_TF_DOCS -->


## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.ebs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.ebs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | Duration in days before KMS key is deleted after destruction | `number` | `10` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., production, staging) | `string` | n/a | yes |
| <a name="input_node_group_arn"></a> [node\_group\_arn](#input\_node\_group\_arn) | ARN of the EKS Node Group Role | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ebs_key_alias"></a> [ebs\_key\_alias](#output\_ebs\_key\_alias) | Alias of the KMS key for EBS volume encryption |
| <a name="output_ebs_key_arn"></a> [ebs\_key\_arn](#output\_ebs\_key\_arn) | ARN of the KMS key for EBS volume encryption |
| <a name="output_ebs_key_id"></a> [ebs\_key\_id](#output\_ebs\_key\_id) | ID of the KMS key for EBS volume encryption |
| <a name="output_eks_key_alias"></a> [eks\_key\_alias](#output\_eks\_key\_alias) | Alias of the KMS key for EKS secrets encryption |
| <a name="output_eks_key_arn"></a> [eks\_key\_arn](#output\_eks\_key\_arn) | ARN of the KMS key for EKS secrets encryption |
| <a name="output_eks_key_id"></a> [eks\_key\_id](#output\_eks\_key\_id) | ID of the KMS key for EKS secrets encryption |
<!-- END_TF_DOCS -->