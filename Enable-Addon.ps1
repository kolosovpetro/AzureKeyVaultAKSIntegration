function Invoke-ExternalCommand
{
    param (
        [string]$Command
    )

    $output = Invoke-Expression "$Command 2>&1"
    if ($LASTEXITCODE -ne 0)
    {
        throw "Command failed: $output"
    }

    return $output
}

# $ErrorActionPreference = "Stop" # optional

try
{
    $ResourceGroup = Invoke-ExternalCommand "terraform output -raw resource_group_name"
    Write-Host "Resource group name: $ResourceGroup" -ForegroundColor Cyan

    $AksName = Invoke-ExternalCommand "terraform output -raw aks_name"
    Write-Host "AKS name: $AksName" -ForegroundColor Cyan

    $KeyVaultId = Invoke-ExternalCommand "terraform output -raw key_vault_id"
    Write-Host "KeyVault ID: $KeyVaultId" -ForegroundColor Cyan

    $AzKeyVaultManagedIdentity = "azurekeyvaultsecretsprovider-$AksName"
    Write-Host "Managed Identity name: $AzKeyVaultManagedIdentity" -ForegroundColor Cyan

    $NodeResourceGroup = Invoke-ExternalCommand "terraform output -raw node_resource_group"
    Write-Host "Node resource group name: $NodeResourceGroup" -ForegroundColor Cyan

    Write-Host "Enabling keyvault integration addon..."
    try
    {
        Invoke-ExternalCommand "az aks enable-addons --addons azure-keyvault-secrets-provider --name $AksName --resource-group $ResourceGroup"
    }
    catch
    {
        Write-Host "$( $_.Exception.Message )"
        Write-Host "Keyvault integration is likely already enabled." -ForegroundColor Green
        exit 0
    }

    $clientId = Invoke-ExternalCommand "az identity show --name $AzKeyVaultManagedIdentity --resource-group $NodeResourceGroup --query clientId -o tsv"
    Write-Host "Client ID: $clientId" -ForegroundColor Cyan

    Invoke-ExternalCommand "az role assignment create --assignee $clientId --role `"Key Vault Administrator`" --scope $KeyVaultId"
    Write-Host "Role assignment completed." -ForegroundColor Green
}
catch
{
    Write-Error "Script failed: $( $_.Exception.Message )"
    exit 1
}
