#********************************************************************
# NGINX Ingress Controller
# https://kubernetes.github.io/ingress-nginx/
# https://kubernetes.github.io/ingress-nginx/how-it-works/
# https://kubernetes.github.io/ingress-nginx/troubleshooting/
# https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/
# https://kubernetes.github.io/ingress-nginx/examples/
# https://kubernetes.github.io/ingress-nginx/examples/PREREQUISITES/
#********************************************************************

# Create NGINX Namespace
kubectl apply -f nginx-ingress-namespace.yaml

# https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/index.md

# Deploy AKS NGINIX Ingress Mandatory Configuration
# https://kubernetes.github.io/ingress-nginx/deploy/#prerequisite-generic-deployment-command
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml
kubectl apply -f nginx-ingress-mandatory.yaml

# Deploy AKS NGINIX Ingress Controller
# https://kubernetes.github.io/ingress-nginx/deploy/#azure
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/cloud-generic.yaml
kubectl apply -f nginx-ingress-cloud-generic.yaml

# Verify NGINX Ingress Installation
# To check if the ingress controller pods have started, run the following command:
kubectl get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx --watch

# Detect Installed NGINX Ingress Version
# To detect which version of the ingress controller is running, 
# exec into the pod and run nginx-ingress-controller version command
$POD_NAMESPACE = "ingress-nginx"

$POD_NAME = $(kubectl get pods -n $POD_NAMESPACE `
    -l app.kubernetes.io/name=ingress-nginx `
    -o jsonpath='{.items[0].metadata.name}')

kubectl exec -it "$POD_NAME" -n "$POD_NAMESPACE" -- /nginx-ingress-controller --version

kubectl get pods -n "$POD_NAMESPACE" --watch

kubectl get services -n "$POD_NAMESPACE" --watch

kubectl describe services -n "$POD_NAMESPACE"

kubectl get deployments -n "$POD_NAMESPACE"