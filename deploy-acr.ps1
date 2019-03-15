# Create a Resource Group
az group create --name "$ACR_RG_NAME" --location "eastus2"

# Create a container registry (ACR)
az acr create --resource-group "$ACR_RG_NAME" --name "$ACR_NAME" --sku Basic

#**********************************************************
# Build container locally and run it
#**********************************************************

# Build the containerized application
docker build -f "$WEB_APP_PATH\Dockerfile" -t "$CONTAINER_NAME" .

# Show the new local image
docker images "$CONTAINER_NAME"

#**********************************************************
# Log into your remote private container registry (ACR)
#**********************************************************

# log in to your remote private container registry (ACR)
# az acr login -n "$ACR_NAME" -g "$ACR_RG_NAME"
az acr login -n "$ACR_NAME" 

# Get the login server name for your remote private container registry (ACR)
$LOGIN_SERVER = az acr show -n "$ACR_NAME" --query loginServer --output tsv
Write-Verbose "LOGIN_SERVER: $LOGIN_SERVER" -Verbose

#**********************************************************
# Push image to your remote private container registry (ACR)
#**********************************************************

# Prep image for your private remote container registry (ACR)
docker tag "$CONTAINER_NAME" "$LOGIN_SERVER/$CONTAINER_NAME"

# Show the local newly preped image
docker images "$LOGIN_SERVER/$CONTAINER_NAME"
# You should see only information for you app, which now includes
# your private remote container registry (ACR) name prefix

# Push the locally preped image to your private remote container registry (ACR)
docker push $LOGIN_SERVER/$CONTAINER_NAME

# Queue an image build and push it ro the container registry (ACR)
az acr build -f "$WEB_APP_PATH\Dockerfile" --registry "$ACR_NAME" -t $LOGIN_SERVER/$CONTAINER_NAME .

# View the images in your private remote container registry (ACR)
az acr repository list -n "$ACR_NAME" -o table
# You should see you image in the list

# View the tags for the container repository
az acr repository show-tags -n "$ACR_NAME" --repository "$IMAGE_NAME" -o table
# You should see your image tag in the list

