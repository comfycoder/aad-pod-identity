# Before you begin - make sure you're logged in to Azure using the azure CLI
az login

# Enter your Azure subscription name here
$SUBSCRIPTION_NAME = "Visual Studio Premium with MSDN"

Write-Verbose "Set the default Azure subscription" -Verbose
az account set --subscription "$SUBSCRIPTION_NAME"

$SUBSCRIPTION_ID = $(az account show --query id -o tsv)
Write-Verbose "SUBSCRIPTION_ID: $SUBSCRIPTION_ID" -Verbose

$SUBSCRIPTION_NAME = $(az account show --query name -o tsv)
Write-Verbose "SUBSCRIPTION_NAME: $SUBSCRIPTION_NAME" -Verbose

$USER_NAME = $(az account show --query user.name -o tsv)
Write-Verbose "Service Principal Name or ID: $USER_NAME" -Verbose

$TENANT_ID = $(az account show --query tenantId -o tsv)
Write-Verbose "TENANT_ID: $TENANT_ID" -Verbose

Write-Verbose "Get the directory when the main script is executing" -Verbose
$SCRIPT_DIRECTORY = ($pwd).path
Write-Verbose "SCRIPT_DIRECTORY: $SCRIPT_DIRECTORY" -Verbose

. (Join-Path $SCRIPT_DIRECTORY "az-cli-wrappers.ps1")

. (Join-Path $SCRIPT_DIRECTORY "variables.mine.ps1")

kubectl config get-contexts

# Log in to the cluster with admin access
az aks get-credentials --resource-group "$AKS_RG_NAME" --name "$AKS_NAME" --admin

# Access Kubernetes Dashboard from Cloud Shell (not for local docker kubernetes instance)
az aks browse --resource-group "$AKS_RG_NAME" --name "$AKS_NAME"

# If working locally, run the following command to see the Kubernetes dashboard
# Open a separate PowerShell command line window and run the following:
# kubectl proxy

# Then run the following to view the Kubernetes dashboard
Start-Process "http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy"

