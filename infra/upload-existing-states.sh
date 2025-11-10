#!/bin/bash
set -euo pipefail

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="saynotobadchecksum-terraform-state-${AWS_ACCOUNT_ID}"

echo "Uploading existing Terraform state files to S3..."
echo "Bucket: ${BUCKET_NAME}"

# Upload dev state if exists
if [ -f "environments/dev/terraform.tfstate" ]; then
    echo "Uploading dev state..."
    aws s3 cp environments/dev/terraform.tfstate "s3://${BUCKET_NAME}/dev/terraform.tfstate"
    echo "✅ Dev state uploaded"
else
    echo "⚠️  No dev state file found locally"
fi

# Upload staging state if exists
if [ -f "environments/staging/terraform.tfstate" ]; then
    echo "Uploading staging state..."
    aws s3 cp environments/staging/terraform.tfstate "s3://${BUCKET_NAME}/staging/terraform.tfstate"
    echo "✅ Staging state uploaded"
else
    echo "⚠️  No staging state file found locally"
fi

# Upload prod state if exists
if [ -f "environments/prod/terraform.tfstate" ]; then
    echo "Uploading prod state..."
    aws s3 cp environments/prod/terraform.tfstate "s3://${BUCKET_NAME}/prod/terraform.tfstate"
    echo "✅ Prod state uploaded"
else
    echo "⚠️  No prod state file found locally"
fi

echo ""
echo "✅ State upload complete!"
echo ""
echo "Next steps:"
echo "1. Commit and push the changes"
echo "2. The GitHub workflow will now use the S3 backend"