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

$env:TF_LOG = "WARN"

$AksName = Invoke-ExternalCommand "terraform output -raw aks_name"

Write-Host "AKS name: $AksName" -ForegroundColor Cyan

$AzKeyVaultManagedIdentity = "azurekeyvaultsecretsprovider-$AksName"
Write-Host "Managed Identity name: $AzKeyVaultManagedIdentity" -ForegroundColor Cyan

$NodeResourceGroup = Invoke-ExternalCommand "terraform output -raw node_resource_group"
Write-Host "Node resource group name: $NodeResourceGroup" -ForegroundColor Cyan

$clientId = Invoke-ExternalCommand "az identity show --name $AzKeyVaultManagedIdentity --resource-group $NodeResourceGroup --query clientId -o tsv"
Write-Host "Client ID: $clientId" -ForegroundColor Cyan

Invoke-ExternalCommand "helm template ./keyvault-csi --set userAssignedIdentityID=$clientId"

Invoke-ExternalCommand "helm install kv-csi-demo ./keyvault-csi --set userAssignedIdentityID=$clientId"

