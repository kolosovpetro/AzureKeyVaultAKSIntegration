# Identity created by keyvault addon

az identity show --name azurekeyvaultsecretsprovider-aks-d01 --resource-group "MC_rg-kv-aks-integration-d01_aks-d01_northeurope" -o json
az identity show --name azurekeyvaultsecretsprovider-aks-d01 --resource-group "MC_rg-kv-aks-integration-d01_aks-d01_northeurope" --query principalId -o tsv
az identity show --name azurekeyvaultsecretsprovider-aks-d01 --resource-group "MC_rg-kv-aks-integration-d01_aks-d01_northeurope" --query clientId -o tsv


# Create role assignment

az role assignment create --assignee "4068e807-4678-4b37-9dbb-0cb386c2dc33" `
    --role "Key Vault Administrator" `
    --scope "/subscriptions/f32f6566-8fa0-4198-9c91-a3b8ac69e89a/resourceGroups/rg-kv-aks-integration-d01/providers/Microsoft.KeyVault/vaults/kv-aks-d01"


# Get node resource group name

az aks show --name aks-d01 --resource-group "rg-kv-aks-integration-d01" --query "nodeResourceGroup" --output tsv
