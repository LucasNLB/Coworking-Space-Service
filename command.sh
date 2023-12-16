# Set up Bitnami Repository
helm repo add project3-repo https://charts.bitnami.com/bitnami

# Install PostgreSQL Helm Chart
helm install --set primary.persistence.enabled=false udacity-postgre udacity-pr3/postgresql

# The password can be retrieved with the following command:
export POSTGRES_PASSWORD=$(kubectl get secret --namespace default udacity-postgre-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
echo $POSTGRES_PASSWORD

# To connect to your database run the following command:
kubectl run udacity-postgre-postgresql-client --rm --tty -i --restart='Never' --namespace default --image docker.io/bitnami/postgresql:16.1.0-debian-11-r0 --env="PGPASSWORD=DWfdlnyuJg" --command -- psql --host udacity-postgre-postgresql  -U postgres -d postgres -p 5432

# Connecting Via Port Forwarding
kubectl port-forward --namespace default svc/udacity-postgre-postgresql 5433:5432 & PGPASSWORD=$POSTGRES_PASSWORD psql --host 127.0.0.1 -U postgres -d postgres -p 5433

# Connecting Via a Pod
kubectl exec -it udacity-postgre-postgresql bash 
PGPASSWORD="xDvWjnuc7o" psql postgres://postgres@udacityservice-postgresql:5432/postgres -c \l

kubectl port-forward svc/udacity-postgre-postgresql 5432:5432

kubectl port-forward --namespace default svc/udacity-postgre-postgresql 5432:5432 & PGPASSWORD=$POSTGRES_PASSWORD psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < ./db/1_create_tables.sql
kubectl port-forward --namespace default svc/udacity-postgre-postgresql 5432:5432 & PGPASSWORD=$POSTGRES_PASSWORD psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < ./db/2_seed_users.sql
kubectl port-forward --namespace default svc/udacity-postgre-postgresql 5432:5432 & PGPASSWORD=$POSTGRES_PASSWORD psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < ./db/3_seed_tokens.sql

DB_USERNAME=postgres DB_PASSWORD=xDvWjnuc7o python app.py

# Expose the Backend API to the Internet
kubectl expose deployment backend-coworking-space --type=LoadBalancer --name=publicbackend

kubectl exec --stdin --tty postgres-postgresql-0 -- /bin/bash

ClusterName=udacity-projec3
RegionName=us-east-1
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${ClusterName}'/;s/{{region_name}}/'${RegionName}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl apply -f ./deployment