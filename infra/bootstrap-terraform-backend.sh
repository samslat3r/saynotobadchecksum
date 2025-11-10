#!/bin/bash
set -euo pipefail

REGION="us-west-2"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="saynotobadchecksum-terraform-state-${AWS_ACCOUNT_ID}"
DYNAMODB_TABLE="saynotobadchecksum-terraform-lock"

echo "Creating Terraform state infrastructure..."
echo "Account: ${AWS_ACCOUNT_ID}"
echo "Bucket: ${BUCKET_NAME}"
echo "Table: ${DYNAMODB_TABLE}"
echo "Region: ${REGION}"

# Create S3 bucket for state storage if it doesn't exist
if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
    echo "✅ S3 bucket already exists: ${BUCKET_NAME}"
else
    echo "Creating S3 bucket: ${BUCKET_NAME}..."
    aws s3api create-bucket \
        --bucket "${BUCKET_NAME}" \
        --region "${REGION}" \
        --create-bucket-configuration LocationConstraint="${REGION}"
    
    # Enable versioning
    aws s3api put-bucket-versioning \
        --bucket "${BUCKET_NAME}" \
        --versioning-configuration Status=Enabled
    
    # Enable encryption
    aws s3api put-bucket-encryption \
        --bucket "${BUCKET_NAME}" \
        --server-side-encryption-configuration '{
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    }
                }
            ]
        }'
    
    # Block public access
    aws s3api put-public-access-block \
        --bucket "${BUCKET_NAME}" \
        --public-access-block-configuration \
            "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
    
    echo "✅ S3 bucket created successfully"
fi

# Create DynamoDB table for state locking if it doesn't exist
if aws dynamodb describe-table --table-name "${DYNAMODB_TABLE}" --region "${REGION}" 2>/dev/null; then
    echo "✅ DynamoDB table already exists: ${DYNAMODB_TABLE}"
else
    echo "Creating DynamoDB table: ${DYNAMODB_TABLE}..."
    aws dynamodb create-table \
        --table-name "${DYNAMODB_TABLE}" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "${REGION}"
    
    # Wait for table to be active
    aws dynamodb wait table-exists \
        --table-name "${DYNAMODB_TABLE}" \
        --region "${REGION}"
    
    echo "✅ DynamoDB table created successfully"
fi

echo ""
echo "✅ Terraform backend infrastructure ready!"
echo ""
echo "Next steps:"
echo "1. Run: cd infra/environments/<env>"
echo "2. Run: terraform init -backend-config=backend.hcl -migrate-state"
echo "3. Answer 'yes' when prompted to migrate the state"