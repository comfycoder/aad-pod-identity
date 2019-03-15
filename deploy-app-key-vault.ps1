#**********************************************************
# Deploy Azure Key Vault with secrets
#**********************************************************

# Create Azure Key Vault
az keyvault create -n "$APP_KV_NAME" -g "$APP_RG_NAME" -l "$AKS_LOCATION" `
    --enabled-for-deployment true `
    --enabled-for-disk-encryption true `
    --enabled-for-template-deployment

# Create Secret 1
az keyvault secret set --vault-name "$APP_KV_NAME" -n "Secret1" --value "SuparSecretValue1-Production"

# Create Secret 2
az keyvault secret set --vault-name "$APP_KV_NAME" -n "Secret2" --value "SuparSecretValue2-Production"
