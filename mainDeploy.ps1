. (Join-Path $SCRIPT_DIRECTORY "deploy-acr.ps1")

. (Join-Path $SCRIPT_DIRECTORY "deploy-aks-cluster.ps1")

# docker-local-kubernetes only
. (Join-Path $SCRIPT_DIRECTORY "deploy-kubernetes-dashboard.ps1")

# Azure Kubernetes Service with RBAC Enabled
. (Join-Path $SCRIPT_DIRECTORY "deployKubernetesDashboardFix.ps1")

. (Join-Path $SCRIPT_DIRECTORY "deploy-aks-cluster-permissions")

. (Join-Path $SCRIPT_DIRECTORY "generate-tls-cert.ps1")

. (Join-Path $SCRIPT_DIRECTORY "deploy-nginx-ingress.ps1")

. (Join-Path $SCRIPT_DIRECTORY "deploy-apps.ps1")