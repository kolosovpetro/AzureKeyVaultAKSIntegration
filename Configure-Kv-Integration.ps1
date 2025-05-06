# Enable keyvault addon in AKS

az aks enable-addons --addons azure-keyvault-secrets-provider --name "aks-d01" --resource-group "rg-kv-aks-integration-d01"


# Install CSI driver

# Enable system assigned or managed identity in AKS (in azure portal)

# Create secret provider class and secrets

kubectl apply -f .\csi-provider-class.yaml

# Create pod with volume mount

kubectl apply -f .\pod.yaml

# List secrets

kubectl exec sc-demo-keyvault-csi -- ls /mnt/secrets-store
kubectl exec sc-demo-keyvault-csi -- cat /mnt/secrets-store/ConnectionString
