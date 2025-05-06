# Identity created by keyvault addon

az identity show --name azurekeyvaultsecretsprovider-aks-d01 --resource-group "MC_rg-kv-aks-integration-d01_aks-d01_northeurope" -o json
az identity show --name azurekeyvaultsecretsprovider-aks-d01 --resource-group "MC_rg-kv-aks-integration-d01_aks-d01_northeurope" --query principalId -o tsv
az identity show --name azurekeyvaultsecretsprovider-aks-d01 --resource-group "MC_rg-kv-aks-integration-d01_aks-d01_northeurope" --query clientId -o tsv


# Get node resource group name

az aks show --name aks-d01 --resource-group "rg-kv-aks-integration-d01" --query "nodeResourceGroup" --output tsv
