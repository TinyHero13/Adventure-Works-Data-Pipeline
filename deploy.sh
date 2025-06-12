echo "Starting deployment..."
docker compose run --rm terraform init
docker compose run --rm terraform validate
docker compose run --rm terraform apply -auto-approve
echo "Deployment completed"