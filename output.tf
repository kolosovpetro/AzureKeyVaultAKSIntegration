output "connect_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.public.name} --name ${module.aks.name} --subscription ${data.azurerm_client_config.current.subscription_id}"
}

output "enable_keyvault_addon_command" {
  value = "az aks enable-addons --addons azure-keyvault-secrets-provider --name ${module.aks.name} --resource-group ${azurerm_resource_group.public.name}"
}
