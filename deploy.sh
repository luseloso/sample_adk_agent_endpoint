#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
REPO_NAME="agent-backend-repo"
IMAGE_NAME="agent-backend"
TAG="latest"

echo "Using Project ID: $PROJECT_ID"
echo "Region: $REGION"

# 1. Create Artifact Registry Repo (Manual fallback since Terraform is blocked)
echo "Ensuring Artifact Registry Repo exists..."
if ! gcloud artifacts repositories describe $REPO_NAME --location=$REGION --project=$PROJECT_ID > /dev/null 2>&1; then
    echo "Creating repository..."
    gcloud artifacts repositories create $REPO_NAME \
        --repository-format=docker \
        --location=$REGION \
        --description="Agent Backend Repo" \
        --project=$PROJECT_ID
else
    echo "Repository $REPO_NAME already exists."
fi

# 2. Build & Push
REPO_LOCATION="$REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME"
FULL_IMAGE_NAME="$REPO_LOCATION/$IMAGE_NAME:$TAG"

echo "Building Container and Pushing to $FULL_IMAGE_NAME..."
gcloud builds submit ./backend --tag "$FULL_IMAGE_NAME" --project $PROJECT_ID

# 3. Deploy to Cloud Run (Manual fallback since Terraform is blocked)
echo "Deploying to Cloud Run..."
gcloud run deploy agent-backend \
    --image "$FULL_IMAGE_NAME" \
    --region "$REGION" \
    --platform managed \
    --allow-unauthenticated \
    --project "$PROJECT_ID" \
    --set-env-vars ENV_TYPE=production

echo "Done!"
