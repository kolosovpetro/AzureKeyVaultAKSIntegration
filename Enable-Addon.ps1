# Variables

$env:TF_LOG = "WARN"
#$ErrorActionPreference = "Stop"

$ResourceGroup = $( terraform output -raw resource_group_name )

Write-Host "Resource group name: $ResourceGroup" -ForegroundColor Cyan

$AksName = $( terraform output -raw aks_name )

Write-Host "AKS name: $AksName" -ForegroundColor Cyan

$KeyVaultId = $( terraform output -raw key_vault_id )

Write-Host "KeyVault ID: $KeyVaultId" -ForegroundColor Cyan

$AzKeyVaultManagedIdentity = "azurekeyvaultsecretsprovider-$AksName"

Write-Host "Managed Identity name: $AzKeyVaultManagedIdentity" -ForegroundColor Cyan

$NodeResourceGroup = $( terraform output -raw node_resource_group )

Write-Host "Node resource group name: $NodeResourceGroup" -ForegroundColor Cyan

Write-Host "Enabling keyvault integration addon..."

$output = $(az aks enable-addons --addons azure-keyvault-secrets-provider --name $AksName --resource-group $ResourceGroup)

if ($LASTEXITCODE -ne 0)
{
    Write-Host $outputt
    Write-Host "Keyvault integration is enabled already." -ForegroundColor Green
    exit 0;
}

$clientId = $( az identity show --name $AzKeyVaultManagedIdentity --resource-group $NodeResourceGroup --query clientId -o tsv )

Write-Host "Client ID: $clientId" -ForegroundColor Cyan

az role assignment create --assignee $clientId `
    --role "Key Vault Administrator" `
    --scope $KeyVaultId
