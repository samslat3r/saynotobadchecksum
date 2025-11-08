#!/usr/bin/env bash
set -euo pipefail

# Deploy web assets to S3 with API configuration injection
#
# Usage: ./scripts/deploy-web.sh <environment>
#   environment: dev, staging, or prod

ENV="${1:-dev}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TF_DIR="${PROJECT_ROOT}/infra/environments/${ENV}"

if [ ! -d "${TF_DIR}" ]; then
    echo "Error: Environment '${ENV}' not found at ${TF_DIR}"
    exit 1
fi

echo "==> Deploying web assets for environment: ${ENV}"

# Get outputs from Terraform
cd "${TF_DIR}"

echo "==> Retrieving Terraform outputs..."
API_BASE_URL=$(terraform output -raw api_base_url 2>/dev/null || echo "")
WEB_BUCKET=$(terraform output -raw web_bucket_name 2>/dev/null || echo "")
PRESIGN_SECRET_ARN=$(terraform output -raw presign_secret_arn 2>/dev/null || echo "")

if [ -z "${API_BASE_URL}" ] || [ -z "${WEB_BUCKET}" ]; then
    echo "Error: Could not retrieve required Terraform outputs"
    echo "  api_base_url: ${API_BASE_URL}"
    echo "  web_bucket_name: ${WEB_BUCKET}"
    exit 1
fi

echo "  API Base URL: ${API_BASE_URL}"
echo "  Web Bucket: ${WEB_BUCKET}"

# Get the presign API key from Secrets Manager
echo "==> Retrieving PRESIGN_API_KEY from Secrets Manager..."
PRESIGN_API_KEY=""
if [ -n "${PRESIGN_SECRET_ARN}" ]; then
    PRESIGN_API_KEY=$(aws secretsmanager get-secret-value \
        --secret-id "${PRESIGN_SECRET_ARN}" \
        --query 'SecretString' \
        --output text 2>/dev/null | jq -r '.PRESIGN_API_KEY' || echo "")
else
    # Fallback: read secret id from Lambda env if Terraform output is not set
    echo "==> Falling back to reading secret from Lambda environment..."
    LAMBDA_NAME="sam-secure-${ENV}-presign"
    SECRET_ID=$(aws lambda get-function-configuration \
        --function-name "${LAMBDA_NAME}" \
        --query 'Environment.Variables.PRESIGN_SECRET_ID' \
        --output text 2>/dev/null || echo "")
    if [ -n "${SECRET_ID}" ] && [ "${SECRET_ID}" != "None" ]; then
        PRESIGN_API_KEY=$(aws secretsmanager get-secret-value \
            --secret-id "${SECRET_ID}" \
            --query 'SecretString' \
            --output text 2>/dev/null | jq -r '.PRESIGN_API_KEY' || echo "")
    fi
fi

if [ -z "${PRESIGN_API_KEY}" ]; then
    echo "Warning: Could not retrieve PRESIGN_API_KEY, using placeholder"
    PRESIGN_API_KEY="REPLACE_WITH_SECRET_KEY"
fi

# Create a temporary build directory
BUILD_DIR=$(mktemp -d)
trap 'rm -rf ${BUILD_DIR}' EXIT

echo "==> Preparing web assets..."
cp -r "${PROJECT_ROOT}/web/"* "${BUILD_DIR}/"

# Replace placeholders in app.js
echo "==> Injecting configuration into app.js..."
sed -i.bak \
    -e "s|REPLACE_WITH_API_BASE_URL|${API_BASE_URL}|g" \
    -e "s|REPLACE_WITH_SECRET_KEY|${PRESIGN_API_KEY}|g" \
    "${BUILD_DIR}/app.js"

rm -f "${BUILD_DIR}/app.js.bak"

# Sync to S3
echo "==> Uploading to S3 bucket: ${WEB_BUCKET}..."
aws s3 sync "${BUILD_DIR}/" "s3://${WEB_BUCKET}/" \
    --delete \
    --exclude "*.bak" \
    --cache-control "public, max-age=3600"

# Set no-cache for index.html and app.js (ensure clients pick up latest config)
echo "==> Setting cache control for index.html..."
aws s3 cp "${BUILD_DIR}/index.html" "s3://${WEB_BUCKET}/index.html" \
    --cache-control "public, max-age=0, must-revalidate" \
    --content-type "text/html" \
    --metadata-directive REPLACE

echo "==> Setting cache control for app.js..."
aws s3 cp "${BUILD_DIR}/app.js" "s3://${WEB_BUCKET}/app.js" \
    --cache-control "public, max-age=0, must-revalidate" \
    --content-type "application/javascript" \
    --metadata-directive REPLACE

echo "==> Deployment complete!"

# Get CloudFront URL
WEBSITE_URL=$(cd "${TF_DIR}" && terraform output -raw website_url 2>/dev/null || echo "")
CLOUDFRONT_ID=$(cd "${TF_DIR}" && terraform output -raw cloudfront_distribution_id 2>/dev/null || echo "")
if [ -n "${WEBSITE_URL}" ]; then
    echo ""
    echo "Website URL: https://${WEBSITE_URL}"
    echo ""
    if [ -n "${CLOUDFRONT_ID}" ]; then
        echo "==> Creating CloudFront invalidation..."
        aws cloudfront create-invalidation --distribution-id "${CLOUDFRONT_ID}" --paths '/*' >/dev/null || true
        echo "CloudFront invalidation requested for distribution ${CLOUDFRONT_ID}"
    else
        echo "Note: If using CloudFront, you may need to create an invalidation:"
        echo "  aws cloudfront create-invalidation --distribution-id <DIST_ID> --paths '/*'"
    fi
fi
