# Create AAD Pod Identity K8s Service
kubectl create -f aad-pod-identity-rbac.yaml

# Create User Assigned Managed Identity
az identity create -n "$APP_MSI_NAME" -g "$APP_RG_NAME"

<#
{
  "clientId": "94fb495d-0392-4f9f-9d7b-e3aeb6e03520",
  "clientSecretUrl": "https://control-eastus2.identity.azure.net/subscriptions/75724ec8-0441-4414-afd4-09d9e764414c/resourcegroups/RG-CN-MyApp/providers/Microsoft.ManagedIdentity/userAssignedIdentities/MSI-CN-MyApp/credentials?tid=52034371-b33a-42e9-85c2-78ec57d3d8e0&oid=428b17d4-5332-431b-9de2-dfaf71d7f245&aid=94fb495d-0392-4f9f-9d7b-e3aeb6e03520",
  "id": "/subscriptions/75724ec8-0441-4414-afd4-09d9e764414c/resourcegroups/RG-CN-MyApp/providers/Microsoft.ManagedIdentity/userAssignedIdentities/MSI-CN-MyApp",
  "location": "eastus2",
  "name": "MSI-CN-MyApp",
  "principalId": "428b17d4-5332-431b-9de2-dfaf71d7f245",
  "resourceGroup": "RG-CN-MyApp",
  "tags": {},
  "tenantId": "52034371-b33a-42e9-85c2-78ec57d3d8e0",
  "type": "Microsoft.ManagedIdentity/userAssignedIdentities"
}
#>

# Grant the Managed Identity "Reader" role on the Key Vault
az role assignment create --role "Reader" `
    --assignee $(az identity show --resource-group "$APP_RG_NAME" `
        --name "$APP_MSI_NAME" --query "principalId" --output tsv) `
    --scope $(az keyvault show `
    --resource-group "$APP_RG_NAME" `
    --name "$APP_KV_NAME" `
    --query "id" --output tsv)

# Grant "Get" and "List" permissions on secrets in the Key Vault
az keyvault set-policy -n "$APP_KV_NAME" `
    --secret-permissions get list `
    --spn $(az identity show `
        --resource-group "$APP_RG_NAME" `
        --name "$APP_MSI_NAME" `
        --query "clientId" --output tsv)

# Assign the AKS Service Principal to the "Managed Identity Operator" role for the 
# Managed Identity create in the previous steps
az role assignment create --role "Managed Identity Operator" `
    --assignee "$AKS_SP_APP_ID" `
    --scope $(az identity show --resource-group "$APP_RG_NAME" `
        --name "$APP_MSI_NAME" --query "id" --output tsv)

# Create the AzureIdentity
$MANAGED_IDENTITY_NAME = "$APP_MSI_NAME"

$MANAGED_IDENTITY_ID = az identity show `
    --resource-group "$APP_RG_NAME" `
    --name "$APP_MSI_NAME" `
    --query id --output tsv
Write-Verbose "MANAGED_IDENTITY_ID: $MANAGED_IDENTITY_ID" -Verbose

$CLIENT_ID = az identity show `
    --resource-group "$APP_RG_NAME" `
    --name "$APP_MSI_NAME" `
    --query clientId --output tsv
Write-Verbose "CLIENT_ID: $CLIENT_ID" -Verbose

# awk -v MANAGED_IDENTITY_NAME=`echo $MANAGED_IDENTITY_NAME` -v MANAGED_IDENTITY_ID=`az identity show --resource-group $AKS_RESOURCE_GROUP --name $MANAGED_IDENTITY_NAME --query \"id\" --output tsv` -v CLIENT_ID=`az identity show --resource-group $AKS_RESOURCE_GROUP --name $MANAGED_IDENTITY_NAME --query \"clientId\" --output tsv` '{ sub(/\$MANAGED_IDENTITY_NAME/, MANAGED_IDENTITY_NAME); sub(/\$MANAGED_IDENTITY_ID/, MANAGED_IDENTITY_ID); sub(/\$CLIENT_ID/, CLIENT_ID); print }' aad-pod-identity.template.yaml > aad-pod-identity.yaml

kubectl apply -f aad-pod-identity.yaml

# Create AzureIdentityBinding
awk -v MANAGED_IDENTITY_NAME=`echo $MANAGED_IDENTITY_NAME` -v SELECTOR="aad-demo-app" '{ sub(/\$MANAGED_IDENTITY_NAME/, MANAGED_IDENTITY_NAME); sub(/\$SELECTOR/, SELECTOR); print }' aad-identity-binding.template.yaml > aad-identity-binding.yaml

kubectl apply -f aad-identity-binding.yaml


# OPTIONAL - Test Locally
dotnet user-secrets set "Secret1" "SuparSecretValue1-Development"

dotnet user-secrets set "Secret2" "SuparSecretValue2-Development"

dotnet run


# ACR build the sample app
awk -v KEYVAULT_NAME=`echo $KEYVAULT_NAME` '{ sub(/\$KEYVAULT_NAME/, KEYVAULT_NAME); print }' appsettings.json > tmp && mv tmp appsettings.json

awk -v ACR_NAME=`echo $ACR_NAME` '{ sub(/\$ACR_NAME/, ACR_NAME); print }' keyvault-demo.template.yaml > keyvault-demo.yaml

az acr build --registry "$ACR_NAME" --image keyvault-demo:latest .

az acr build --registry "acrcnaegis" --image "keyvault-demo:latest" .


# Deploy App to AKS
kubectl apply -f ./keyvault-demo.yaml

kubectl get pods
