# If working locally, run the following to see the Kubernetes dashboard
# Open a separate PowerShell command line window and run the following:
# kubectl proxy
# Then run the following to view the Kubernetes dashboard
Start-Process "http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/node?namespace=default"

# Create a role binding for all members of an Azure AD group
kubectl apply -f rbac-aad-group.yaml

# Deploy a test apps
kubectl apply -f azure-vote.yaml

# kubectl apply -f hello-aks.yaml

# kubectl apply -f "C:\srcHelm\HelloAKS\Kubernetes\k8s-ingress-routes.yaml"

# kubectl apply -f "C:\srcHelm\HelloAKS\Kubernetes\k8s-deploy-app.yaml"

kubectl apply -f "helloaks-ingress-routes.yaml"

kubectl apply -f "helloaks-app-deploy.yaml"

kubectl get pods

kubectl get services


kubectl apply -f "keyvault-demo-ingress-routes.yaml"

kubectl apply -f "keyvault-demo-app-deploy.yaml"

kubectl get pods

kubectl get services