#**********************************************************
# Azure Container Registry (ACR) Variable
#**********************************************************

$ACR_NAME = "acr"
Write-Verbose "ACR_NAME: $ACR_NAME" -Verbose

$ACR_RG_NAME = "RG-"
Write-Verbose "ACR_RG_NAME: $ACR_RG_NAME" -Verbose

#**********************************************************
# Azure DevFunction App dotnet CLI variables
#**********************************************************

# Enter the name you wish to call your web app project
$WEB_APP_NAME = "MyApp"
Write-Verbose "WEB_APP_NAME: $WEB_APP_NAME" -Verbose

# Enter a local path in which to create your web app
$WEB_APP_PATH = "C:\MyAppPath\$WEB_APP_NAME"
Write-Verbose "WEB_APP_PATH: $WEB_APP_PATH" -Verbose

#**********************************************************
# Docker image, tag, container variables
#**********************************************************

# Enter a name for your docker image
$IMAGE_NAME = "myapp"
Write-Verbose "IMAGE_NAME: $IMAGE_NAME" -Verbose

# Enter a tag to identify your image version
$IMAGE_TAG = "v1.0.0"
Write-Verbose "IMAGE_TAG: $IMAGE_TAG" -Verbose

# Combine the image and tag names to define your container name
$CONTAINER_NAME = $IMAGE_NAME + ":" + $IMAGE_TAG
Write-Verbose "CONTAINER_NAME: $CONTAINER_NAME" -Verbose

#*****************************************************************************
# AKS Cluster Service Principal Info
#*****************************************************************************

$AKS_SP_APP_NAME = "SP-"
Write-Verbose "AKS_SP_APP_NAME: $AKS_SP_APP_NAME" -Verbose

$AKS_SP_APP_ID_URI = "http://$AKS_SP_APP_NAME"
Write-Verbose "AKS_SP_APP_ID_URI: $AKS_SP_APP_ID_URI" -Verbose

$AKS_SP_APP_ID = $(Get-AD-Service-Principal -appIdUri "$AKS_SP_APP_ID_URI" -queryParam "appId")
Write-Verbose "AKS_SP_APP_ID: $AKS_SP_APP_ID" -Verbose

$AKS_SP_APP_SECRET = ""
Write-Verbose "AKS_SP_APP_SECRET: $AKS_SP_APP_SECRET" -Verbose

#**********************************************************
# AKS Cluster Service AAD for RBAC Variables
#**********************************************************

$AAD_SERVER_APP_ID = ""
Write-Verbose "AAD_SERVER_APP_ID: $AAD_SERVER_APP_ID" -Verbose

$AAD_SERVER_APP_SECRET = ""
Write-Verbose "AAD_SERVER_APP_SECRET: $AAD_SERVER_APP_SECRET" -Verbose

$AAD_CLIENT_APP_ID = ""
Write-Verbose "AAD_CLIENT_APP_ID: $AAD_CLIENT_APP_ID" -Verbose

$AAD_TENANT_ID = ""
Write-Verbose "AAD_TENANT_ID: $AAD_TENANT_ID" -Verbose

#**********************************************************
# Azure Kubernetes Service (AKS) Variables
#**********************************************************

$AKS_SHORT_NAME = "MyAKS"
Write-Verbose "AKS_SHORT_NAME: $AKS_SHORT_NAME" -Verbose

$APP_TEAM_AD_GROUP = "R-App-MyTEam-Developers"
Write-Verbose "APP_TEAM_AD_GROUP: $APP_TEAM_AD_GROUP" -Verbose

$ORG = "CN" 
Write-Verbose "ORG: $ORG" -Verbose

$REGION = "EA2"
Write-Verbose "REGION: $REGION" -Verbose

$AZENV = "NP1"
Write-Verbose "AZENV: $AZENV" -Verbose

$AKS_LOCATION = "eastus2"
Write-Verbose "AKS_LOCATION: $AKS_LOCATION" -Verbose

$AKS_NAME = "AKS-$ORG-$REGION-$AZENV-$AKS_SHORT_NAME"
Write-Verbose "AKS_NAME: $AKS_NAME" -Verbose

$AKS_RG_NAME = "RG-"
Write-Verbose "AKS_RG_NAME: $AKS_RG_NAME" -Verbose

$RANDOM_DNS_SUFFIX = Get-Random
$AKS_DNS_NAME_PREFIX = "$AKS_NAME-$RANDOM_DNS_SUFFIX".ToLower()
Write-Verbose "AKS_DNS_NAME_PREFIX: $AKS_DNS_NAME_PREFIX" -Verbose

$AKS_AIS_LOCATION = "eastus"
Write-Verbose "AKS_AIS_LOCATION: $AKS_AIS_LOCATION" -Verbose

$AKS_AGENT_COUNT = 1
Write-Verbose "AKS_AGENT_COUNT: $AKS_AGENT_COUNT" -Verbose

$AKS_AGENT_VM_SIZE = "Standard_DS2_v2"
Write-Verbose "AKS_AGENT_VM_SIZE: $AKS_AGENT_VM_SIZE" -Verbose

$AKS_DISK_SIZE_GB = 0
Write-Verbose "AKS_DISK_SIZE_GB: $AKS_DISK_SIZE_GB" -Verbose

$AKS_MAX_PODS = 30
Write-Verbose "AKS_MAX_PODS: $AKS_MAX_PODS" -Verbose

$AKS_KUBERNETES_VERSION = "1.12.6"
Write-Verbose "AKS_KUBERNETES_VERSION: $AKS_KUBERNETES_VERSION" -Verbose

#**********************************************************
# Azure Key Vault Variables
#**********************************************************

$APP_RG_NAME = "RG-"
Write-Verbose "APP_RG_NAME: $APP_RG_NAME" -Verbose

$APP_KV_NAME = "kv-"
Write-Verbose "APP_KV_NAME: $APP_KV_NAME" -Verbose

$APP_MSI_NAME = "MSI-"
Write-Verbose "APP_MSI_NAME: $APP_MSI_NAME" -Verbose

