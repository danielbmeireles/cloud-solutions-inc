# 📚 Documentation Index <!-- omit in toc -->

Complete documentation for Cloud Solutions Inc. infrastructure.

## 🎯 Quick Start

New to the project? Start here:

1. **[Architecture Overview](ARCHITECTURE.md)** - Understand the infrastructure design
2. **[Bootstrap Guide](BOOTSTRAP.md)** - Set up Terraform remote state backend
3. **[EKS Deployment](EKS.md)** - Deploy the Kubernetes cluster
4. **[Kubernetes Layer](KUBERNETES.md)** - Deploy ArgoCD and ALB controller

## 📑 Documentation Categories

### 🏗️ Architecture & Design

Understand the infrastructure architecture and design decisions.

| Document                            | Description                                                 |
| ----------------------------------- | ----------------------------------------------------------- |
| **[Architecture](ARCHITECTURE.md)** | Two-pipeline architecture, components, and design decisions |
| **[Disclaimer](DISCLAIMER.md)**     | Important notes about AI tools and development process      |

### 🚀 Getting Started

Bootstrap and initial setup guides.

| Document                                    | Description                              |
| ------------------------------------------- | ---------------------------------------- |
| **[Bootstrap](BOOTSTRAP.md)**               | Terraform remote state backend setup     |
| **[Quick Links](../README.md#quick-links)** | Main README with all documentation links |

### ☁️ Infrastructure Deployment

Deploy and manage AWS infrastructure.

| Document                                | Description                                   |
| --------------------------------------- | --------------------------------------------- |
| **[EKS Cluster](EKS.md)**               | EKS deployment, configuration, and operations |
| **[Terraform Reference](TERRAFORM.md)** | Terraform modules and best practices          |

### ☸️ Kubernetes Layer

Deploy and manage Kubernetes resources.

| Document                                              | Description                       |
| ----------------------------------------------------- | --------------------------------- |
| **[Kubernetes Infrastructure](KUBERNETES.md)**        | Kubernetes layer deployment guide |
| **[ArgoCD](ARGOCD.md)**                               | GitOps deployment platform setup  |
| **[AWS Load Balancer Controller](ALB_CONTROLLER.md)** | ALB/NLB provisioning controller   |
| **[Examples](EXAMPLES.md)**                           | Sample application deployment     |

### 🔧 Operations

Day-to-day operations and maintenance.

| Document                                  | Description                             |
| ----------------------------------------- | --------------------------------------- |
| **[Troubleshooting](TROUBLESHOOTING.md)** | Comprehensive troubleshooting guide     |
| **[CI/CD Pipeline](CICD.md)**             | Automated deployment workflows          |
| **[Glossary](GLOSSARY.md)**               | Terms, acronyms, and concepts reference |

### 🧪 Testing & Security

Testing and security validation tools.

| Document                          | Description                               |
| --------------------------------- | ----------------------------------------- |
| **[EKS Testing](EKS_TESTING.md)** | EKS module testing with Terraform tests   |
| **[Security Scanning](CICD.md)**  | Automated Checkov security scans in CI/CD |

## 📖 Documentation by Topic

### Authentication & Security

- [OIDC Setup for GitHub Actions](CICD.md#-aws-authentication-setup)
- [IRSA Configuration](EKS.md#iam-roles-for-service-accounts-irsa)
- [Security Best Practices](EKS.md#-security-best-practices)
- [Post-Deployment Security](ARGOCD.md#-post-deployment-security)
- [Checkov Security Scanning](CICD.md) - Automated security checks in pipelines

### Testing

- [EKS Module Tests](EKS_TESTING.md) - Local Terraform testing guide
- [Running Tests](EKS_TESTING.md#-running-tests) - Test execution commands

### Networking

- [VPC Configuration](ARCHITECTURE.md#infrastructure-components)
- [Load Balancer Setup](ALB_CONTROLLER.md)
- [DNS & SSL/TLS](ARGOCD.md#-custom-domain-setup-with-ssltls)

### Monitoring & Logging

- [Infrastructure Monitoring](ARCHITECTURE.md#-monitoring)
- [EKS Monitoring](EKS.md#-monitoring-and-operations)
- [Kubernetes Monitoring](KUBERNETES.md#-monitoring)
- [CI/CD Monitoring](CICD.md#-monitoring)

### Cost Management

- [ArgoCD Costs](ARGOCD.md#-cost)
- [Infrastructure Costs](ARCHITECTURE.md) - See CloudWatch dashboards

### Troubleshooting

- [Central Troubleshooting Guide](TROUBLESHOOTING.md)
- [EKS Troubleshooting](EKS.md#-troubleshooting)
- [ArgoCD Troubleshooting](ARGOCD.md#-troubleshooting)
- [Kubernetes Troubleshooting](KUBERNETES.md#-troubleshooting)
- [ALB Controller Troubleshooting](ALB_CONTROLLER.md#-troubleshooting)

## 🔍 Find What You Need

### By Task

| I want to...                          | See                                                                |
| ------------------------------------- | ------------------------------------------------------------------ |
| Set up the project for the first time | [Bootstrap](BOOTSTRAP.md)                                          |
| Deploy EKS cluster                    | [EKS Deployment](EKS.md#-deployment)                               |
| Deploy ArgoCD                         | [ArgoCD Deployment](ARGOCD.md#️-deployment)                         |
| Set up custom domain with SSL         | [ArgoCD Custom Domain](ARGOCD.md#-custom-domain-setup-with-ssltls) |
| Configure CI/CD                       | [CI/CD Setup](CICD.md)                                             |
| Test EKS module locally               | [EKS Testing](EKS_TESTING.md#-running-tests)                       |
| Run security scans                    | [Security Scanning](CICD.md) or [EKS Testing](EKS_TESTING.md)     |
| Troubleshoot issues                   | [Troubleshooting Guide](TROUBLESHOOTING.md)                        |
| Understand Terraform modules          | [Terraform Reference](TERRAFORM.md)                                |
| Deploy sample app                     | [Examples](EXAMPLES.md)                                            |
| Monitor infrastructure                | [Monitoring Sections](#monitoring--logging)                        |
| Look up a term or acronym             | [Glossary](GLOSSARY.md)                                            |

### By Component

| Component      | Main Doc                                                       | Module Doc                                           |
| -------------- | -------------------------------------------------------------- | ---------------------------------------------------- |
| **VPC**        | [Architecture](ARCHITECTURE.md)                                | [VPC Module](../modules/vpc/README.md)               |
| **EKS**        | [EKS Guide](EKS.md)                                            | [EKS Module](../modules/eks/README.md)               |
| **KMS**        | [Architecture](ARCHITECTURE.md)                                | [KMS Module](../modules/kms/README.md)               |
| **EFS**        | [Architecture](ARCHITECTURE.md)                                | [EFS Module](../modules/efs/README.md)               |
| **CloudWatch** | [Architecture - Monitoring](ARCHITECTURE.md#-monitoring)       | [CloudWatch Module](../modules/cloudwatch/README.md) |
| **ALB**        | [ALB Controller](ALB_CONTROLLER.md)                            | [ALB Module](../modules/alb/README.md)               |
| **ACM**        | [ArgoCD - SSL/TLS](ARGOCD.md#-custom-domain-setup-with-ssltls) | [ACM Module](../modules/acm/README.md)               |
| **ArgoCD**     | [ArgoCD Guide](ARGOCD.md)                                      | [ArgoCD Module](../modules/argocd/README.md)         |

## 📚 External Resources

### Official Documentation

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Documentation](https://docs.aws.amazon.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Helm Documentation](https://helm.sh/docs/)

### AWS Services

- [Amazon EKS](https://docs.aws.amazon.com/eks/)
- [AWS Certificate Manager](https://docs.aws.amazon.com/acm/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [AWS CloudWatch](https://docs.aws.amazon.com/cloudwatch/)

### Tools

- [terraform-docs](https://terraform-docs.io/) - Documentation generator
- [GitHub Actions](https://docs.github.com/en/actions)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/)

## 🤝 Contributing

When adding or updating documentation:

1. **Follow the emoji style guide** - See existing docs for examples
2. **Add `<!-- omit in toc -->` to main title** - Prevents title in TOC
3. **Include Table of Contents** - Use proper emoji (📑)
4. **Add to this index** - Update relevant sections
5. **Cross-reference related docs** - Help readers find related information
6. **Update terraform-docs** - Regenerate module documentation after code changes

### Regenerating Module Documentation

```bash
# Single module
terraform-docs markdown table --output-file README.md --output-mode inject modules/vpc

# All modules
for dir in modules/*/; do
  terraform-docs markdown table --output-file README.md --output-mode inject "$dir"
done

# Root and kubernetes layers
terraform-docs markdown table --output-file TERRAFORM_ROOT.md --output-mode inject .
terraform-docs markdown table --output-file TERRAFORM_KUBERNETES.md --output-mode inject kubernetes/
```

## ✨ Documentation Standards

### Emoji Guidelines

| Section Type          | Emoji | Example                  |
| --------------------- | ----- | ------------------------ |
| Table of Contents     | 📑     | `## 📑 Table of Contents` |
| Architecture/Overview | 🏗️     | `## 🏗️ Architecture`      |
| Prerequisites         | 📋     | `## 📋 Prerequisites`     |
| Configuration         | ⚙️     | `## ⚙️ Configuration`     |
| Deployment            | 🚀     | `## 🚀 Deployment`        |
| Security              | 🔐     | `## 🔐 Security`          |
| Troubleshooting       | 🔧     | `## 🔧 Troubleshooting`   |
| Monitoring            | 📊     | `## 📊 Monitoring`        |
| Cleanup               | 🧹     | `## 🧹 Cleanup`           |
| Features              | ✨     | `## ✨ Features`          |

### Document Structure

Each documentation file should include:

1. **Title with emoji** and `<!-- omit in toc -->` comment
2. **Brief description** of what the document covers
3. **Table of Contents** with proper links
4. **Main content sections** with appropriate emojis
5. **Related Documentation** links section
6. **Footer** with project attribution

Example:
```markdown
# 🚀 Component Name <!-- omit in toc -->

Brief description of the component.

## 📑 Table of Contents <!-- omit in toc -->

- [Section 1](#section-1)
- [Section 2](#section-2)

## 🏗️ Section 1

Content...

## 📚 Related Documentation

- [Other Doc](OTHER.md)

---

**Built with ❤️ for Cloud Solutions Inc.**
```

---

**Built with ❤️ for Cloud Solutions Inc.**
