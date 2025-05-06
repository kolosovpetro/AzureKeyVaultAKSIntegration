output "connect_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.public.name} --name ${azurerm_kubernetes_cluster.aks.name} --subscription ${data.azurerm_client_config.current.subscription_id}"
}

output "enable_keyvault_addon_command" {
  value = "az aks enable-addons --addons azure-keyvault-secrets-provider --name ${azurerm_kubernetes_cluster.aks.name} --resource-group ${azurerm_resource_group.public.name}"
}

output "key_vault_id" {
  value = azurerm_key_vault.public.id
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "key_vault_uami_client_id" {
  value = data.azurerm_user_assigned_identity.kv_uami.client_id
}
