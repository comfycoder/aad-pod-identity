# Kubernetes Dashboard
# https://github.com/kubernetes/dashboard

# Creating a Sample User for Kubernetes Dashboard
# https://github.com/kubernetes/dashboard/wiki/Creating-sample-user

# If you are working with multiple Kubernetes clusters and different environments 
# you will be familiar with switching contexts. You can view contexts using the 
# kubectl config command:
kubectl config get-contexts

# Set the context to use docker-for-desktop:
kubectl config use-context docker-for-desktop

# Get list of kubernetes dashboard objects
kubectl get secret,sa,role,rolebinding,services,deployments --namespace=kube-system | grep dashboard

# Delete all kubernetes dashboard objects
kubectl delete deployment kubernetes-dashboard --namespace=kube-system 
kubectl delete service kubernetes-dashboard  --namespace=kube-system 
kubectl delete role kubernetes-dashboard-minimal --namespace=kube-system 
kubectl delete rolebinding kubernetes-dashboard-minimal --namespace=kube-system
kubectl delete sa kubernetes-dashboard --namespace=kube-system 
kubectl delete secret kubernetes-dashboard-certs --namespace=kube-system
kubectl delete secret kubernetes-dashboard-key-holder --namespace=kube-system

# Install kubernetes dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

# Create a Kubernetes service account
kubectl apply -f dashboard-adminuser.yaml

# Create a Kubernetes ClusterRoleBinding for the service account
kubectl apply -f clusterrolebinding-adminuser.yaml

# If working locally, run the following command to see the Kubernetes dashboard
# Open a separate PowerShell command line window and run the following:
# kubectl proxy

# Then run the following to view the Kubernetes dashboard
Start-Process "http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy"
