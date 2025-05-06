data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "public" {
  location = var.location
  name     = "rg-kv-aks-integration-${var.prefix}"
  tags     = var.tags
}

##########################################################################
# AKS
##########################################################################

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.prefix}"
  kubernetes_version  = "1.31.2"
  location            = azurerm_resource_group.public.location
  resource_group_name = azurerm_resource_group.public.name
  dns_prefix          = "aks-${var.prefix}"
  node_resource_group = "rg-node-aks-${var.prefix}"

  default_node_pool {
    name                        = "systempool"
    node_count                  = 3
    vm_size                     = "Standard_DS2_v2"
    type                        = "VirtualMachineScaleSets"
    temporary_name_for_rotation = "rotationpool"

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  lifecycle {
    ignore_changes = [
      key_vault_secrets_provider
    ]
  }
}


##########################################################################
# KEYVAULT
##########################################################################

resource "azurerm_key_vault" "public" {
  name                        = "kv-aks-${var.prefix}"
  location                    = azurerm_resource_group.public.location
  resource_group_name         = azurerm_resource_group.public.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = true
  sku_name                    = "standard"
}

##########################################################################
# RBAC
##########################################################################

resource "azurerm_role_assignment" "cli_rbac" {
  scope                = azurerm_key_vault.public.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "azure_portal_rbac" {
  scope                = azurerm_key_vault.public.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = "89ab0b10-1214-4c8f-878c-18c3544bb547"
}

##########################################################################
# SECRETS
##########################################################################

resource "azurerm_key_vault_secret" "connection_string" {
  name         = "ConnectionString"
  value        = "User ID=root;Password=myPassword;Host=localhost;Port=5432;Database=myDataBase;Pooling=true;Min Pool Size=0;Max Pool Size=100;Connection Lifetime=0;"
  key_vault_id = azurerm_key_vault.public.id

  depends_on = [
    azurerm_role_assignment.cli_rbac
  ]
}

resource "null_resource" "enable_keyvault_addon" {
  provisioner "local-exec" {
    command     = "az aks enable-addons --addons azure-keyvault-secrets-provider --name ${azurerm_kubernetes_cluster.aks.name} --resource-group ${azurerm_resource_group.public.name}"
    interpreter = ["pwsh", "-Command"]
  }
}


data "azurerm_user_assigned_identity" "kv_uami" {
  name                = "azurekeyvaultsecretsprovider-${azurerm_kubernetes_cluster.aks.name}"
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group

  depends_on = [null_resource.enable_keyvault_addon]
}
