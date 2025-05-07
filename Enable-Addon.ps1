# Variables

$ResourceGroup = $( terraform output -raw resource_group_name )
$AksName = $( terraform output -raw aks_name )
$KeyVaultId = $( terraform output -raw key_vault_id )
$AzKeyVaultManagedIdentity = "azurekeyvaultsecretsprovider-$AksName"
$NodeResourceGroup = $( terraform output -raw node_resource_group )

# Enable keyvault addon in AKS
az aks enable-addons --addons azure-keyvault-secrets-provider --name $AksName --resource-group $ResourceGroup

$clientId = $( az identity show --name $AzKeyVaultManagedIdentity --resource-group $NodeResourceGroup --query clientId -o tsv )

az role assignment create --assignee $clientId `
    --role "Key Vault Administrator" `
    --scope $KeyVaultId
