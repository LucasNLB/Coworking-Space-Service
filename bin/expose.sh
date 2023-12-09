BACKEND_DEPLOYMENT_NAME="backend-coworking-space"

# Kubectl expose
kubectl expose deployment $BACKEND_DEPLOYMENT_NAME --type=LoadBalancer --name=publicbackend