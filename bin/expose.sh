BACKEND_DEPLOYMENT_NAME="backend-coworking-space"

# Kubectl expose
kubectl expose deployment $BACKEND_DEPLOYMENT_NAME --type=LoadBalancer --name=publicbackend

PGPASSWORD=DWfdlnyuJg psql --host 127.0.0.1 -U postgres -d postgres -p 5433