# Authenticate with Azure Container Registry from Azure Kubernetes Service
# https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-aks


if ("false" -eq $(az group exists -n $AKS_RG_NAME)) {
    Write-Error "AKS Resource Group not found." -ErrorAction Stop
    return 99
}
else {
    Write-Verbose 'AKS Resource Group exists.' -Verbose
}

# Check if azure container registry exists
$ACR = az acr show -n "$ACR_NAME"

if ($null -eq $ACR) {
    Write-Error "Azure Container Registry not found: '$ACR_NAME" -ErrorAction Stop
    return 99
}
else{
    # ACR Reader Access #####################################################################################################
    # Grant app dev group 'Reader' access on ACR
    # Grant cluster SP 'Reader' access on ACR
    Set-Object-ACR-Reader-RBAC -a "$APP_TEAM_AD_GROUP" -r "Reader" -g "$ACR_RG_NAME" -s "$SUBSCRIPTION_ID" -acr "$ACR_NAME" -group $True
    Set-Object-ACR-Reader-RBAC -a "$AKS_SP_APP_ID_URI" -r "Reader" -g "$ACR_RG_NAME" -s "$SUBSCRIPTION_ID" -acr "$ACR_NAME" -group $False
}

# Check if azure AD group exists
$AD_GROUP = az ad group show -g "$APP_TEAM_AD_GROUP"
if ($null -eq $AD_GROUP) {
    Write-Verbose $('Active Directory group not found:  ' + $APP_TEAM_AD_GROUP) -Verbose
    return 99
}
else {
    Write-Verbose 'Active Directory group exists.' -Verbose
}

# Resource Group Access #####################################################################################################
# Grant app dev group 'Reader' access on cluster resource group
# Check if group already has the access, if not grant it
Set-Group-RG-RBAC -a "$APP_TEAM_AD_GROUP" -r "Reader" -g "$AKS_RG_NAME" -s "$SUBSCRIPTION_ID"

# Cluster Read Group Access #####################################################################################################
# Grant app dev group 'Azure Kubernetes Service Cluster User Role' access on AKS cluster
# Check if group already has the access, if not grant it
Set-Group-RG-RBAC -a "$APP_TEAM_AD_GROUP" -r "Azure Kubernetes Service Cluster User Role" -g "$AKS_RG_NAME" -s "$SUBSCRIPTION_ID"

# Cluster SP Access to Parent Resource Group ############################################################################
# Grant the cluster SP Network Contributor to the parent RG to modify vnets, subnets
# Check if group already has the access, if not grant it
Set-SP-RG-RBAC -a "$AKS_SP_APP_ID_URI" -r "Network Contributor" -g "$AKS_RG_NAME" -s "$SUBSCRIPTION_ID"

# Cluster SP Access to Log Analytics ############################################################################
# Grant the cluster SPLog Analytics Contributor to the appropriate Log Analytics resource
# Check if group already has the access, if not grant it
# Set-SP-LogAnalytics-RBAC -a "$AKS_SP_APP_ID_URI" -r "Log Analytics Contributor" -g "$OMS_WORKSPACE_RG_NAME" -s "$SUBSCRIPTION_ID" -w "$OMS_WORKSPACE_NAME"
