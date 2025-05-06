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

module "aks" {
  source                      = "github.com/kolosovpetro/AzureAKSTerraform.git//modules/aks?ref=AZ400-325"
  aks_name                    = "aks-${var.prefix}"
  default_node_pool_type      = "VirtualMachineScaleSets"
  default_node_pool_vm_size   = "Standard_DS2_v2"
  kubernetes_version          = "1.31.2"
  resource_group_location     = azurerm_resource_group.public.location
  resource_group_name         = azurerm_resource_group.public.name
  system_node_count           = 3
  should_deploy_log_analytics = false
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
    azurerm_role_assignment.cli_rbac,
    azurerm_role_assignment.azure_portal_rbac
  ]
}
