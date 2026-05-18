#!/usr/bin/env bash
set -euo pipefail

ACCOUNT="905418181527"
REGION="eu-central-1"
REGISTRY="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Format: "ecr-repo-name:local-directory"
SERVICES=(
  "taskmanager-user-service:user-service"
  "taskmanager-task-service:task-service"
  "taskmanager-api-gateway:api-gateway"
  "taskmanager-frontend-service:frontend-service"
  "taskmanager-notification-service:notification-service"
)

echo "==> Authenticating Docker to ECR"
aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "$REGISTRY"

for entry in "${SERVICES[@]}"; do
  ECR_REPO="${entry%%:*}"   # everything before the colon
  LOCAL_DIR="${entry##*:}"  # everything after the colon

  echo "==> Building ${ECR_REPO}:v1 from ./${LOCAL_DIR}"
  docker buildx build \
    --platform linux/amd64 \
    --push \
    -t "${REGISTRY}/${ECR_REPO}:v1" \
    "${REPO_ROOT}/${LOCAL_DIR}"
  echo "==> Done: ${ECR_REPO}"
done

echo "==> All images pushed to ECR"
