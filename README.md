# 🔐 AKS Key Vault CSI Integration (Terraform + Helm)

This project provisions an **Azure Kubernetes Service (AKS)** cluster and integrates it with **Azure Key Vault** using the **CSI Secrets Store driver**. It uses **Terraform** for infrastructure provisioning and **Helm** for Kubernetes resource management.

---

## 🚀 Features (v1.0.0 - In Progress)

- Provision AKS cluster using Terraform
- Create and configure an Azure Key Vault with test secrets
- Assign RBAC permissions to managed identities for accessing Key Vault
- Enable the `azure-keyvault-secrets-provider` addon in AKS
- Deploy CSI `SecretProviderClass` using Helm
- Deploy a pod that mounts secrets as volumes
- Deploy a pod that exposes secrets via environment variables
- Scripts for:
    - Enabling CSI addon
    - Managing role assignments
    - Deploying Helm chart
    - Helm validation and linting

---

## 🧰 Prerequisites

- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)
- [PowerShell Core (pwsh)](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)

---

## 🧪 Helm Chart Validation & Linting

To validate your Helm templates before deployment:

```bash
helm lint ./charts/keyvault-csi
helm template --debug ./charts/keyvault-csi
```

## Terraform Modules used

- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret
