# Create a Resource Group
az group create --name "$AKS_RG_NAME" --location "eastus2"

# Create AKS Cluster SP
# SP Name:
# SP-AKS-Aegis-Cluster
# App ID:
# 7cd52d42-848e-47e9-a72d-b2bc1f4e51f9
# Object ID:
# bf604718-0b4b-4ada-9b26-22d375022beb
# App ID Uri:
# http://SP-AKS-Aegis-Cluster
# Client Secret:
# Gx0mQZC3ntElKB9MZy0Ig/KFupvF88bktds7+8XkqWk=


# Create an Azure Kubernetes Service Cluster (AKS)
# https://docs.microsoft.com/en-us/azure/aks/aad-integration#create-client-application
az aks create `
  --resource-group "$AKS_RG_NAME" `
  --name "$AKS_NAME" `
  --location "$AKS_LOCATION" `
  --kubernetes-version "$AKS_KUBERNETES_VERSION" `
  --dns-name-prefix "$AKS_DNS_NAME_PREFIX" `
  --generate-ssh-keys `
  --service-principal "$AKS_SP_APP_ID" `
  --client-secret "$AKS_SP_APP_SECRET" `
  --aad-server-app-id "$AAD_SERVER_APP_ID" `
  --aad-server-app-secret "$AAD_SERVER_APP_SECRET" `
  --aad-client-app-id "$AAD_CLIENT_APP_ID" `
  --aad-tenant-id "$AAD_TENANT_ID" `
  --node-count $AKS_AGENT_COUNT `
  --max-pods $AKS_MAX_PODS `
  --node-vm-size "$AKS_AGENT_VM_SIZE" `
  --node-osdisk-size $AKS_DISK_SIZE_GB `
  --enable-addons monitoring


# Log in to the cluster with admin access
az aks get-credentials --resource-group "$AKS_RG_NAME" --name "$AKS_NAME" --admin

# You must create a ClusterRoleBinding before you can correctly access the dashboard
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
